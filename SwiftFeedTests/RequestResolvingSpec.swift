//
//  RequestResolvingSpec.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Quick
import Nimble

@testable import SwiftFeed

fileprivate struct AnyEndpoint: Endpoint {
    let path: String
    let parameters: [String : String]
    let method: HTTPMethod
    
    static func makeEmpty() -> Endpoint {
        AnyEndpoint(path: "", parameters: [:], method: .get)
    }
}

final class RequestResolvingSpec: QuickSpec {
    
    override func spec() {
        
        let validURL = "https://api.github.com/"
        
        // Its definitely NOT a good practice to use emojis in any code.
        // An empty string would just do as an invalid URL for the test.
        // This is here just for the laughs :)
        let invalidURL = "😬"
        
        describe("request resolving") {
            
            it("resolves against valid URL") {
                let request = Request(baseURL: validURL, endpoint: AnyEndpoint.makeEmpty())
                expect { try request.asURL() }.toNot(throwError())
                expect { try request.asURLRequest() }.toNot(throwError())
            }
            
            it("fails against invalid URL") {
                let request = Request(baseURL: invalidURL, endpoint: AnyEndpoint.makeEmpty())
                expect { try request.asURL() }.to(throwError())
                expect { try request.asURLRequest() }.to(throwError())
            }
            
            context("search endpoint") {
                
                context("repositories") {
                    
                    it("resolves for no parameters") {
                        let endpoint: SearchEndpoint = .repositories(
                            matching: nil,
                            sort: nil,
                            order: nil,
                            pagination: nil)
                        let request = Request(baseURL: validURL, endpoint: endpoint)
                        expect {
                            expect(try request.asURL().query).to(beNil())
                        }.toNot(throwError())
                        expect { try request.asURLRequest() }.toNot(throwError())
                    }
                    
                    it("resolves for full parameters") {
                        let endpoint: SearchEndpoint = .repositories(
                            matching: "queryParam",
                            sort: "sortParam",
                            order: "orderParam",
                            pagination: Pagination(
                                index: 999,
                                itemsPerPage: 100))
                        let request = Request(baseURL: validURL, endpoint: endpoint)
                        expect {
                            expect(try request.asURL().query).toNot(beNil())
                        }.toNot(throwError())
                        expect { try request.asURLRequest() }.toNot(throwError())
                    }
                }
            }
        }
    }
}
