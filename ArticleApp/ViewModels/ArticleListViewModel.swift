import Foundation
import RxSwift
import RxCocoa

class ArticleListViewModel {
    // MARK: - Public Relays
    let articles = BehaviorRelay<[Article]>(value: [])
    let searchArticles = BehaviorRelay<[ArticleSearchDoc]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let isSearchMode = BehaviorRelay<Bool>(value: false)
    let selectedPeriod = BehaviorRelay<Int>(value: 7)

    // MARK: - Private Properties
    private let networkService: NetworkServiceProtocol
    private let disposeBag = DisposeBag()
    private var currentArticleType: ArticleType?

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    // MARK: - Configuration
    func configureForMostPopular(type: ArticleType) {
        self.currentArticleType = type
        self.isSearchMode.accept(false)
        fetchMostPopularData()
    }

    func configureForSearch(query: String) {
        self.currentArticleType = nil
        self.isSearchMode.accept(true)
        fetchSearchData(query: query)
    }

    // MARK: - Actions
    func changePeriod(to newPeriod: Int) {
        guard !isSearchMode.value, currentArticleType != nil else { return }
        selectedPeriod.accept(newPeriod)
        fetchMostPopularData()
    }

    // MARK: - Private Fetching Logic
    private func fetchMostPopularData() {
        guard let type = currentArticleType else { return }

        isLoading.accept(true)
        errorMessage.accept(nil)
        articles.accept([]) // Clear previous results

        networkService.fetchMostPopularArticles(type: type, period: selectedPeriod.value) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading.accept(false)
                switch result {
                case .success(let articles):
                    self?.articles.accept(articles)
                case .failure(let error):
                    self?.errorMessage.accept(error.localizedDescription)
                }
            }
        }
    }

    private func fetchSearchData(query: String) {
        isLoading.accept(true)
        errorMessage.accept(nil)
        searchArticles.accept([]) // Clear previous results

        networkService.searchArticles(query: query, page: 0) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading.accept(false)
                switch result {
                case .success(let articles):
                    self?.searchArticles.accept(articles)
                case .failure(let error):
                    self?.errorMessage.accept(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func clearData() {
        articles.accept([])
        searchArticles.accept([])
        errorMessage.accept(nil)
        isLoading.accept(false)
    }
    
    func getArticleCount() -> Int {
        return isSearchMode.value ? searchArticles.value.count : articles.value.count
    }
} 