//
//  GitHubRepository.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Foundation

/**
 A model representing a GitHub repository, containing data ready to be displayed on UI.
 */
class GitHubRepository {
    
    /**
     The name of the repository.
     */
    let name: String
    
    /**
     The username of the author of the repository.
     */
    let author: String
    
    /**
     The ammount of stars the repository have, formatted in the style `0.000.000`.
     */
    let starCount: String?
    
    /**
     The URL string for the avatar picture of the repository's author.
     */
    let avatarUrl: String?
    
    init(serviceModel: Repository) {
        self.name = serviceModel.name
        self.author = serviceModel.owner.username
        self.avatarUrl = serviceModel.owner.avatarUrlString
        self.starCount = NumberFormatter.customDefault.string(from: serviceModel.starCount)
    }
}
