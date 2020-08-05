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
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let starCountLabel = UILabel()
    
    private let avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder-avatar")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    
    private let starIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "octicon-star")?.withRenderingMode(.alwaysTemplate)
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
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80)]
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16 * 5)]
        
        let authorLabelConstraints = [
            authorLabel.topAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)]
        
        let starLabelConstraints = [
            starCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            starCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)]
        
        let starIconConstraints = [
            starIcon.centerYAnchor.constraint(equalTo: starCountLabel.centerYAnchor, constant: -2),
            starIcon.trailingAnchor.constraint(equalTo: starCountLabel.leadingAnchor, constant: -4)]
        
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
