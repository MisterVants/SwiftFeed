//
//  RepositoryCell.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    var model: GitHubRepository? {
        didSet {
            guard let repository = model else { return }
            fillView(with: repository)
        }
    }
    
    private let titleLabel = UILabel.makeWithStyle(.subheadline, weight: .bold).lineLimit(2)
    private let authorLabel = UILabel.makeWithStyle(.footnote)
    private let starCountLabel = UILabel.makeWithStyle(.footnote)
    
    private let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(asset: .defaultAvatar)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Style.thumbnailRadius
        return imageView
    }()
    
    private let starIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(asset: .iconStar)?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layoutView()
    }
    
    private func layoutView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(starCountLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(starIcon)
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let avatarConstraints = [
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.default),
            avatarView.widthAnchor.constraint(equalToConstant: Style.thumbnailSize.width),
            avatarView.heightAnchor.constraint(equalToConstant: Style.thumbnailSize.height)]
        
        let titleLabelConstraints = [
            titleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: contentView.layoutMarginsGuide.topAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: Spacing.default),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.small)]
        
        let authorLabelConstraints = [
            authorLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: titleLabel.lastBaselineAnchor, multiplier: 1),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.small),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: authorLabel.lastBaselineAnchor, multiplier: 4)]
        
        let starLabelConstraints = [
            starCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.default),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: starCountLabel.lastBaselineAnchor, multiplier: 1)]
        
        let starIconConstraints = [
            starIcon.centerYAnchor.constraint(equalTo: starCountLabel.centerYAnchor, constant: -1),
            starIcon.trailingAnchor.constraint(equalTo: starCountLabel.leadingAnchor, constant: -Spacing.extraSmall)]
        
        NSLayoutConstraint.activate([
            avatarConstraints,
            titleLabelConstraints,
            authorLabelConstraints,
            starLabelConstraints,
            starIconConstraints
        ].flatMap {$0})
    }
    
    private func fillView(with repository: GitHubRepository) {
        titleLabel.text = repository.name
        authorLabel.text = repository.author
        starCountLabel.text = repository.starCount
        avatarView.image = UIImage(asset: .defaultAvatar)
        
        guard let urlString = repository.avatarUrl else { return }
        ImageLoader.downloadImage(from: URL(string: urlString)) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let image = image, self.model?.avatarUrl == urlString else { return }
                self.avatarView.image = image
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
