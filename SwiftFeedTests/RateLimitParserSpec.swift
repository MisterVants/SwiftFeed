//
//  RateLimitParserSpec.swift
//  SwiftFeedTests
//
//  Created by André Vants Soares de Almeida on 05/08/20.
//

import Quick
import Nimble

@testable import SwiftFeed

final class RateLimitParserSpec: QuickSpec {
    
    override func spec() {
        
        describe("rate limit header parser") {
            
            it("correctly parses valid values") {
                let date = Date()
                let epoch = date.timeIntervalSince1970
                let now = date.timeIntervalSinceNow
                
                let validHeaders = [
                    RateLimitParser.HeaderKey.limit : "\(10)",
                    RateLimitParser.HeaderKey.remaining : "\(9)",
                    RateLimitParser.HeaderKey.resetTime : "\(epoch)"]
                
                let rateLimits = RateLimitParser.parseRateLimitHeaders(from: validHeaders)
                expect(rateLimits).toNot(beNil())
                expect(rateLimits?.limit).to(equal(10))
                expect(rateLimits?.remaining).to(equal(9))
                expect(rateLimits?.resetIntervalInSeconds).to(beCloseTo(now, within: 1))
            }
            
            it("returns no data if headers are abscent") {
                let invalidHeaders = [
                    RateLimitParser.HeaderKey.limit : "",
                    RateLimitParser.HeaderKey.remaining : "",
                    RateLimitParser.HeaderKey.resetTime : ""]
                let rateLimits = RateLimitParser.parseRateLimitHeaders(from: invalidHeaders)
                expect(rateLimits).to(beNil())
            }
            
            it("returns no data if just one value is abscent") {
                var almostValidHeaders = [
                    RateLimitParser.HeaderKey.limit : "\(10)",
                    RateLimitParser.HeaderKey.remaining : "\(9)",
                    RateLimitParser.HeaderKey.resetTime : "\(Date().timeIntervalSince1970)"]
                almostValidHeaders.removeValue(forKey: almostValidHeaders.randomElement()?.key ?? "")
                let rateLimits = RateLimitParser.parseRateLimitHeaders(from: almostValidHeaders)
                expect(rateLimits).to(beNil())
            }
        }
    }
}

