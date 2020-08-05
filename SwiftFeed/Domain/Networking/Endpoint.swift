//
//  Endpoint.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

/**
 A protocol to abstract an endpoints for an API
 */
protocol Endpoint {
    /**
     The target's endpoint's path.
     */
    var path: String { get }
    
    /**
     A list of parameters to be sent on the request.
     */
    var parameters: [String:String] { get }
    
    /**
     The HTTP method for the request.
     */
    var method: HTTPMethod { get }
}
