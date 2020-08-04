//
//  GitHubSearch.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 04/08/20.
//

import Foundation

protocol SearchAPI {
    func getRepositories(completion: @escaping (Result<[Repository], Error>) -> Void) -> Cancellable
}

class GitHubSearch: SearchAPI {
    
    func getRepositories(completion: @escaping (Result<[Repository], Error>) -> Void) -> Cancellable {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            let repos = self.mockRepos()
            completion(.success(repos))
        }
        return Cancellable()
    }
    
    private func mockRepos() -> [Repository] {
        return (1...30).map { i in
            Repository(name: "name-\(i)", fullName: "fullname-\(i)", starCount: 100 - i, owner: Repository.Owner(username: "user-\(i)", avatarUrlString: nil))
        }
    }
}

class Cancellable {
    
    private(set) var isCancelled = false
    
    func cancel() {
        isCancelled = true
    }
}
