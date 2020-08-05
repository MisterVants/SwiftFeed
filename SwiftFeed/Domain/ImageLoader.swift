//
//  ImageLoader.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import UIKit

enum ImageLoader {
    static func downloadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            let response = Response<Data>(data: data, response: response, error: error)
            if let data = try? response.result.get() {
                completion(UIImage(data: data))
            }
        }.resume()
    }
}
