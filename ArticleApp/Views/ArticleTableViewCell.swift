import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    private var imageLoadTaskUUID: UUID?
    
    // MARK: - UI Components
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5 // Placeholder color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let abstractLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(articleImageView)
        mainStackView.addArrangedSubview(textStackView)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(abstractLabel)
        textStackView.addArrangedSubview(sectionLabel)
        textStackView.addArrangedSubview(dateLabel)
        
        selectionStyle = .none
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            articleImageView.widthAnchor.constraint(equalToConstant: 80),
            articleImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    func configure(with article: Article) {
        titleLabel.text = article.title
        abstractLabel.text = article.abstract
        sectionLabel.text = article.section
        dateLabel.text = formatDate(article.publishedDate)

        if let mediaURLString = article.media?.first?.mediaMetadata.first(where: { $0.format == "Standard Thumbnail" })?.url,
           let mediaURL = URL(string: mediaURLString) {
            loadImage(from: mediaURL)
        }
    }
    
    func configure(with searchArticle: ArticleSearchDoc) {
        titleLabel.text = searchArticle.headline.main
        abstractLabel.text = searchArticle.snippet
        sectionLabel.text = searchArticle.sectionName ?? "General"
        dateLabel.text = formatSearchDate(searchArticle.pubDate)
        
        if let partialURL = searchArticle.multimedia?.first(where: { $0.subtype == "thumbnail" })?.url,
           let imageURL = URL(string: "https://www.nytimes.com/\(partialURL)") {
            loadImage(from: imageURL)
        }
    }
    
    private func loadImage(from url: URL) {
        imageLoadTaskUUID = ImageLoader.shared.loadImage(from: url) { [weak self] image in
            self?.articleImageView.image = image ?? UIImage(systemName: "photo") // Fallback to system icon
            self?.articleImageView.backgroundColor = image == nil ? .systemGray5 : .clear
        }
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    private func formatSearchDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        abstractLabel.text = nil
        sectionLabel.text = nil
        dateLabel.text = nil
        articleImageView.image = nil
        articleImageView.backgroundColor = .systemGray5
        
        if let uuid = imageLoadTaskUUID {
            ImageLoader.shared.cancelRequest(for: uuid)
            imageLoadTaskUUID = nil
        }
    }
} 