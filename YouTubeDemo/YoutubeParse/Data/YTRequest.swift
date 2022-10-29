//
//  YTRequest.swift
//  YouTubeDemo
//
//  Created by Cu Rua Vui Tinh on 21/10/2022.
//

import Foundation

struct YTRequest: Codable {
    var context: Context?
    var continuation: String?
}

struct Context: Codable {
    var client: Client?
    var user: Context.User?
    var request: Context.Request?
    var clickTracking: Context.ClickTracking?
    struct User: Codable {
        var lockedSafetyMode: Bool?
    }

    struct Request: Codable {
        var useSSL: Bool
        let internalExperimentFlags, consistencyTokenJars: [Int]

        enum CodingKeys: String, CodingKey {
            case useSSL = "useSsl"
            case internalExperimentFlags, consistencyTokenJars
        }
    }

    struct ClickTracking: Codable {
        var clickTrackingParams: String
        
    }
}

