//
//  VodaVideo.swift
//  canvasee_ios
//
//  Created by Cu Rua Vui Tinh on 21/09/2022.
//  Copyright © 2022 Canvasee Vietnam. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import CommonCrypto

class VodaVideo: NSObject {
    private var helper: VodaTubeHelper? = nil

    override init(){
        super.init()
        helper = VodaTubeHelper()
    }
    
    private func getAuthorization() -> String {
        let currentTime = Int(NSDate().timeIntervalSince1970)
        guard let sapisid = self.helper?.getSAPISID() else {
            return ""
        }
        if sapisid.isEmpty {
            return ""
        }
        let contentHash = "\(currentTime) \(sapisid) \(VodaTubeConstanst.origin)"
        let authorizationHash = getHash(input: contentHash)
        return "SAPISIDHASH \(currentTime)_\(authorizationHash)"
    }
    
    private func getHash(input: String) -> String {
        let data = Data(input.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    func getSyncYoutube() -> Bool {
        if self.helper?.getCookies() != nil {
            return true
        }
        return false
    }
    
    func getNextVideos(videoId: String, completionHandler: @escaping ([VideoModel]) -> Void){
        var headers: [String:String] = [:]
        headers["cache-control"] = "max-age=0"
        if let cookies = self.helper?.getCookies() {
            headers["cookie"] = cookies
            headers["user-agent"] = helper?.getClient()?.userAgent ?? YoutubeRequest.USER_AGENT
            
            if (!getAuthorization().isEmpty){
                headers["authorization"] =  getAuthorization()
            }
            
        }
        YoutubeRequest.getAsync(url: URL(string: VodaTubeConstanst.watchUrl + videoId)!, headers: headers) {
            (response) in
            guard let data = response else {
                completionHandler([])
                return
            }
            guard let dataStr  = String(data: data, encoding: .utf8) else {
                completionHandler([])
                return
            }
            
            guard let initResponse = dataStr.getInitVodaTubeResponse() else {
                completionHandler([])
                return
            }
            
            var contents = initResponse.contents?.twoColumnWatchNextResults?.secondaryResults?.secondaryResults?.results?.filter({ item in
                item.compactVideoRenderer != nil
            }).map({ item in
                item.compactVideoRenderer
            })
            
            if (contents == nil || contents?.count == 0) {
                contents = initResponse.contents?.twoColumnWatchNextResults?.secondaryResults?.secondaryResults?.results?.last?.itemSectionRenderer?.contents?.filter({ item in
                    item.compactVideoRenderer != nil
                }).map({ item in
                    item.compactVideoRenderer
                })
            }
            
            guard let contents = contents else {
                completionHandler([])
                return
            }
           
            var resultList: [VideoModel] = []
            for content in contents {
                guard let video = content else {
                    continue
                }
                var result = VideoModel()
                let channelObject = video.ownerText?.runs?.first
                let channelId = channelObject?.navigationEndpoint?.browseEndpoint?.browseID
                let channelName = channelObject?.text
                let channelAvatar = video.channelThumbnailSupportedRenderers?.channelThumbnailWithLinkRenderer?.thumbnail?.thumbnails?.first?.url
                result.channelID = channelId
                result.channelImage = channelAvatar
                result.channelName = channelName
                result.time = 0
                result.id = -1
                result.publishedVideoAt = video.publishedTimeText?.simpleText
                result.thumbnail = video.thumbnail?.thumbnails?.last?.url
                result.title = video.title?.runs?.first?.text
                result.videoID = video.videoID
                result.views = video.viewCountText?.simpleText
                resultList.append(result)
            }
            completionHandler(resultList)
        }
    }
}
