//
//  InitYoutubeClient.swift
//  AdSpy
//
//  Created by Cu Rua Vui Tinh on 15/05/2022.
//  Copyright © 2022 Cu Rua Vui Tinh. All rights reserved.
//

import Foundation

struct InitYoutubeclient: Codable {
    let innertubeAPIKey: String
    let innertubeContext: InnertubeContext

    enum CodingKeys: String, CodingKey {
        case innertubeAPIKey = "INNERTUBE_API_KEY"
        case innertubeContext = "INNERTUBE_CONTEXT"
    }
}

// MARK: - InnertubeContext
struct InnertubeContext: Codable {
    var client: Client?
}

import Foundation
// MARK: - Client
struct Client: Codable {
    var hl, gl, remoteHost, deviceMake: String?
    var deviceModel, visitorData, userAgent, clientName: String?
    var clientVersion, osName, osVersion: String?
    var originalURL: String?
    var playerType: String?
    var screenPixelDensity: Int?
    var platform, clientFormFactor: String?
    var configInfo: ConfigInfo?
    var screenDensityFloat: Int?
    var userInterfaceTheme, timeZone, browserName, browserVersion: String?

    enum CodingKeys: String, CodingKey {
        case hl, gl, remoteHost, deviceMake, deviceModel, visitorData, userAgent, clientName, clientVersion, osName, osVersion
        case originalURL = "originalUrl"
        case playerType, screenPixelDensity, platform, clientFormFactor, configInfo, screenDensityFloat, userInterfaceTheme, timeZone, browserName, browserVersion
    }
    
    mutating func setOriginalURL(url: String?) {
        originalURL = url
    }
}

// MARK: - ConfigInfo
struct ConfigInfo: Codable {
    var appInstallData: String?
}
