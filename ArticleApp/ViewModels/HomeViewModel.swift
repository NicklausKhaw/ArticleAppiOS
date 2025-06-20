import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    // MARK: - Published Properties (converted to RxSwift)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let selectedArticleType = BehaviorRelay<ArticleType?>(value: nil)
    
    private let networkService = NetworkService.shared
    private let disposeBag = DisposeBag()
    
    var articleTypes: [ArticleType] {
        return ArticleType.allCases
    }
    
    func selectArticleType(_ type: ArticleType) {
        selectedArticleType.accept(type)
    }
    
    func clearSelection() {
        selectedArticleType.accept(nil)
    }
    
    func getArticleTypeDisplayName(_ type: ArticleType) -> String {
        return type.displayName
    }
} 