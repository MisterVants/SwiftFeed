//
//  Response.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 04/08/20.
//

import Foundation

enum HTTPStatusCode {
    static func isSuccess(_ statusCode: Int) -> Bool {
        return (200..<300) ~= statusCode
    }
}

struct Response<T: Decodable> {

    /// The final result of the request, containing either a decoded model or an error.
    let result: Result<T, Error>
    
    /// The raw data that returned in a response.
    let data: Data?
    
    /// The request associated with the response.
    let request: URLRequest?
    
    /// The response that returned from the URL load request as a URLResponse.
    let urlResponse: URLResponse?
    
    /// The response that returned from the URL load request as a HTTPURLResponse.
    var httpResponse: HTTPURLResponse? {
        urlResponse as? HTTPURLResponse
    }
    
    /// All HTTP header fields associated with the response.
    var httpHeaders: [AnyHashable : Any] {
        httpResponse?.allHeaderFields ?? [:]
    }
    
    init(request: URLRequest? = nil, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.request = request
        self.urlResponse = response
        self.result = Self.validate(data, response, error).flatMap { data -> Result<T, Error> in
            if let rawData = data as? T {
                return .success(rawData)
            }
            return Self.decode(data)
        }
    }
}

extension Response {

    private static func validate(_ data: Data?, _ urlResponse: URLResponse?, _ error: Error?) -> Result<Data, Error> {
        if let error = error {
            if (error as NSError).code == NSURLErrorCancelled {
                return .failure(NetworkError.dataTaskCancelled)
            }
            return .failure(NetworkError.dataTaskError(error))
        }
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            return .failure(NetworkError.noResponse)
        }
        guard HTTPStatusCode.isSuccess(httpResponse.statusCode) else {
            return .failure(NetworkError.badStatusCode(httpResponse.statusCode))
        }
        guard let validData = data else {
            return .failure(NetworkError.responseDataNil)
        }
        return .success(validData)
    }

    private static func decode<T: Decodable>(_ data: Data) -> Result<T, Error> {
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch let jsonError {
            return .failure(NetworkError.jsonDecodeFailed(jsonError, data))
        }
    }
}
