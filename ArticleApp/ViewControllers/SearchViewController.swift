import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    // MARK: - UI Components
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter search term..."
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Search Articles"
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(searchTextField)
        stackView.addArrangedSubview(searchButton)
        
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            searchTextField.heightAnchor.constraint(equalToConstant: 50),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBindings() {
        // Bind searchTextField to viewModel.searchText
        searchTextField.rx.text.orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
        
        // Enable/disable search button
        viewModel.isSearchButtonEnabled
            .observe(on: MainScheduler.instance)
            .bind(to: searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isSearchButtonEnabled
            .map { $0 ? 1.0 : 0.5 }
            .observe(on: MainScheduler.instance)
            .bind(to: searchButton.rx.alpha)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func searchButtonTapped() {
        guard let searchText = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !searchText.isEmpty else {
            return
        }
        
        let articleListVC = ArticleListViewController()
        articleListVC.configureForSearch(query: searchText)
        navigationController?.pushViewController(articleListVC, animated: true)
    }
    
    @objc private func textFieldDidChange() {
        // No longer needed, handled by Rx binding
    }
} 