//
//  Youtube.swift
//  AdSpy
//
//  Created by Cu Rua Vui Tinh on 3/31/22.
//  Copyright © 2022 Cu Rua Vui Tinh. All rights reserved.
//

import Foundation


class YoutubeInstance {
    var helper: YouTubeHelper? = nil
    var request: YoutubeRequest? = nil
    //'APIService' cannot be constructed because it has no accessible initializers
//    var baseUrl = APIService.getHomeHashtag(param: [:]).baseURL.appendingPathComponent("api/v3/get_url_share")
    //https://apidev.canvasee.com
    private var isinitialized = false
    func isInitialized() -> Bool{
        return isinitialized
    }
    init(completionHandler: @escaping (Bool) -> Void){
        helper = YouTubeHelper()
        getShareUrl()
        YoutubeRequest.getAsync(url: URL(string: "https://www.youtube.com")) { (response) in
            guard let data = response else {
                completionHandler(false)
                return
            }
            guard let dataStr  = String(data: data, encoding: .utf8) else {
                completionHandler(false)
                return
            }
            self.helper?.deviceKey = dataStr.getYoutubeKey()
            self.helper?.client = dataStr.getClient()?.innertubeContext.client
            self.helper?.trackingParamsNewInstance = dataStr.getInitResponse()?.getTrackingParams()
            self.request = YoutubeRequest(deviceId: self.helper?.deviceKey)
            self.isinitialized = true
            completionHandler(true)
        }
    }
//    func getChannelVideos(channelId: String, nextpageToken: String?){
//        let url = "https://www.youtube.com/channel/" + channelId + "/videos"
//        let helper = YouTubeHelper()
//        let session = URLSession.shared
//        session.dataTask(with: URL(string: url)!) { (data, response, error) in
//            guard let data = data else { return }
//            guard let dataStr  = try? String(data: data, encoding: .utf8) else {
//                return
//            }
//            helper.deviceKey = dataStr.getYoutubeKey()
//            helper.client = dataStr.getClient()?.client
//            guard let videosChannelResponse  = try? dataStr.getVideosChannelResponse() else {
//                return
//            }
//            helper.trackingParams = videosChannelResponse.trackingParams ?? ""
//            let channelDetail = videosChannelResponse.getChanelViewModel()
//            let xxx =  videosChannelResponse.getVideoModel(channelDetail: channelDetail)
//            return
//        }.resume()
//    }
}
