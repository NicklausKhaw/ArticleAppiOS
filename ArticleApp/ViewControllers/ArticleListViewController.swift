import UIKit
import RxSwift
import RxCocoa

class ArticleListViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No articles found"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private let viewModel = ArticleListViewModel()
    private let disposeBag = DisposeBag()
    private var currentQuery: String?
    private var currentArticleType: ArticleType?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        setupTableView()
    }
    
    // MARK: - Configuration
    func configureForMostPopular(type: ArticleType) {
        currentArticleType = type
        title = type.displayName
        viewModel.configureForMostPopular(type: type)
        setupPeriodButton()
    }
    
    func configureForSearch(query: String) {
        currentQuery = query
        title = "Search Results"
        navigationItem.rightBarButtonItem = nil
        viewModel.configureForSearch(query: query)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    private func setupPeriodButton() {
        viewModel.selectedPeriod
            .asObservable()
            .subscribe(onNext: { [weak self] period in
                guard let self = self else { return }
                
                let createAction = { (title: String, days: Int) -> UIAction in
                    return UIAction(title: title, state: period == days ? .on : .off) { _ in
                        self.viewModel.changePeriod(to: days)
                    }
                }

                let oneDay = createAction("1 Day", 1)
                let sevenDays = createAction("7 Days", 7)
                let thirtyDays = createAction("30 Days", 30)

                let menu = UIMenu(title: "Time Period", options: .displayInline, children: [oneDay, sevenDays, thirtyDays])
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"), menu: menu)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupBindings() {
        viewModel.isLoading
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.articles
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            })
            .disposed(by: disposeBag)
        
        viewModel.searchArticles
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .asObservable()
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.getArticleCount() == 0
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ArticleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getArticleCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        
        if viewModel.isSearchMode.value {
            let searchArticle = viewModel.searchArticles.value[indexPath.row]
            cell.configure(with: searchArticle)
        } else {
            let article = viewModel.articles.value[indexPath.row]
            cell.configure(with: article)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Here you could navigate to a detail view controller
        // For now, we'll just show an alert with the article title
        let title: String
        if viewModel.isSearchMode.value {
            title = viewModel.searchArticles.value[indexPath.row].headline.main
        } else {
            title = viewModel.articles.value[indexPath.row].title
        }
        
        let alert = UIAlertController(title: "Article Selected", message: title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 