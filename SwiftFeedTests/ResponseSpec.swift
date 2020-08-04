//
//  ResponseSpec.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 04/08/20.
//

import Quick
import Nimble

@testable import SwiftFeed

final class ResponseSpec: QuickSpec {

    override func spec() {
        
        let validStringData = try! JSONEncoder().encode("data")
        let testUrl = URL(string: "https://httpbin.org/")!
        let request = URLRequest(url: testUrl)
        
        let successResponse = HTTPURLResponse(url: testUrl, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        let failureResponse = HTTPURLResponse(url: testUrl, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: nil)
        
        describe("network response") {
            
            context("error cases") {
                it("init with error should result in an error") {
                    let response: Response<String> = Response(request: request, error: NSError.wildcard)
                    expect(response.request).toNot(beNil())
                    expect { try response.result.get() }.to(throwError())
                }
                
                it("init with no response should result in an error") {
                    let response: Response<String> = Response(request: request, data: validStringData, response: nil, error: nil)
                    expect { try response.result.get() }.to(throwError(NetworkError.noResponse))
                }
                
                it("init with bad response should result in an error") {
                    let response: Response<String> = Response(request: request, response: failureResponse, error: nil)
                    expect { try response.result.get() }.to(throwError())
                    expect((response.result.failure as? NetworkError)?.isBadStatusCodeError) == true
                }
                
                it("init with nil data should result in an error") {
                    let response: Response<String> = Response(request: request, data: nil, response: successResponse, error: nil)
                    expect { try response.result.get() }.to(throwError(NetworkError.responseDataNil))
                }
                
                it("init with invalid data should result in an error") {
                    let response: Response<Int> = Response(request: request, data: validStringData, response: successResponse, error: nil)
                    expect { try response.result.get() }.to(throwError())
                    expect((response.result.failure as? NetworkError)?.isJsonDecodeError) == true
                }
            }
            
            context("success cases") {
                it("init with valid decodable data should result in success") {
                    let response: Response<String> = Response(request: request, data: validStringData, response: successResponse, error: nil)
                    let decoded = try? response.result.get()
                    expect(decoded).toNot(beNil())
                }
            }
        }
    }
}
