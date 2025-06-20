import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Article App"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let articleTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Article Type:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let articleTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.clearSelection()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(searchButton)
        view.addSubview(articleTypeLabel)
        view.addSubview(articleTypeStackView)
        
        setupArticleTypeButtons()
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            searchButton.heightAnchor.constraint(equalToConstant: 50),
            
            articleTypeLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 40),
            articleTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            articleTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            articleTypeStackView.topAnchor.constraint(equalTo: articleTypeLabel.bottomAnchor, constant: 20),
            articleTypeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            articleTypeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupArticleTypeButtons() {
        for articleType in viewModel.articleTypes {
            let button = createArticleTypeButton(for: articleType)
            articleTypeStackView.addArrangedSubview(button)
        }
    }
    
    private func createArticleTypeButton(for articleType: ArticleType) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(articleType.displayName, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.tag = viewModel.articleTypes.firstIndex(of: articleType) ?? 0
        button.addTarget(self, action: #selector(articleTypeButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func setupBindings() {
        viewModel.selectedArticleType
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.updateButtonAppearance()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateButtonAppearance() {
        for (index, subview) in articleTypeStackView.arrangedSubviews.enumerated() {
            guard let button = subview as? UIButton else { continue }
            let articleType = viewModel.articleTypes[index]
            
            if let selectedType = viewModel.selectedArticleType.value, articleType == selectedType {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .systemGray5
                button.setTitleColor(.label, for: .normal)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func searchButtonTapped() {
        let searchVC = SearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func articleTypeButtonTapped(_ sender: UIButton) {
        let selectedType = viewModel.articleTypes[sender.tag]
        viewModel.selectArticleType(selectedType)
        
        let articleListVC = ArticleListViewController()
        articleListVC.configureForMostPopular(type: selectedType)
        navigationController?.pushViewController(articleListVC, animated: true)
    }
} 