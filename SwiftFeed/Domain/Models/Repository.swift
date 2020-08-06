//
//  Repository.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import Foundation

/**
 A structure representing a GitHub repository, directly codable from the API's response data.
 */
struct Repository: Codable {
    
    /**
     The name of the repository.
     */
    let name: String
    
    /**
     The full name of the repository. For example: `apple/swift-package-manager`
     */
    let fullName: String
    
    /**
     The number of stars of the repository.
     */
    let starCount: Int
    
    /**
     A value providing information about the owner of the repository.
     */
    let owner: Owner
    
    private enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case starCount = "stargazers_count"
        case owner
    }
    
    /**
     A structure representing the owner of a GitHub repository.
     */
    struct Owner: Codable {
        
        /**
         The displayed username of the repository owner.
         */
        let username: String
        
        /**
         A URL string pointing to the user profile avatar image.
         */
        let avatarUrlString: String?
        
        /**
         A URL pointing to the user's profile avatar image.
         */
        var avatarUrl: URL? {
            guard let urlString = avatarUrlString else { return nil }
            return URL(string: urlString)
        }
        
        private enum CodingKeys: String, CodingKey {
            case username = "login"
            case avatarUrlString = "avatar_url"
        }
    }
}
