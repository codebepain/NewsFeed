//
//  NewsCell.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import UIKit

final class CategoryLabel: UILabel {
    private let horizontalPadding: CGFloat = 12
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + (horizontalPadding * 2),
            height: 24
        )
    }
}

final class NewsCell: UICollectionViewCell {

    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray4
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let categoryLabel: CategoryLabel = {
        let label = CategoryLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.layer.cornerRadius = 12
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.gray.cgColor
        label.textAlignment = .center
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(newsImageView)
        contentView.addSubview(containerStackView)
        contentView.addSubview(categoryLabel)
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(dateLabel)
        containerStackView.addArrangedSubview(descriptionLabel)
        
        let aspectRatioConstraint = newsImageView.heightAnchor.constraint(
            equalTo: newsImageView.widthAnchor,
            multiplier: 9.0/16.0
        )
        aspectRatioConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            newsImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            newsImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            aspectRatioConstraint,
            
            containerStackView.topAnchor.constraint(equalTo: newsImageView.bottomAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryLabel.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 12),
            categoryLabel.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        containerStackView.setCustomSpacing(12, after: newsImageView)
        containerStackView.setCustomSpacing(4, after: titleLabel)
        containerStackView.setCustomSpacing(12, after: descriptionLabel)
    }
    
    func configure(
        with item: NewsCellModel,
        imageLoader: ImageLoaderProtocol
    ) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        dateLabel.text = item.publishedDate
        categoryLabel.text = item.category
        
        if let url = item.imageURL {
            newsImageView.img.setImage(from: url, using: imageLoader)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.img.cancel()
        newsImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        descriptionLabel.text = nil
        categoryLabel.text = nil
    }
}
