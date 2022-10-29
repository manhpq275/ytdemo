//
//  YoutubeChannel.swift
//  AdSpy
//
//  Created by Cu Rua Vui Tinh on 13/05/2022.
//  Copyright © 2022 Cu Rua Vui Tinh. All rights reserved.
//

import Foundation

class YoutubeChannel: YoutubeInstance {
    private var lastChannel : ChannelModel? = nil
    private func processDataRequest(channelID: String, isLoadMore: Bool = false) -> ChannelRequest?{
        guard var client = helper?.client else {
            return nil
        }
        client.setOriginalURL(url: YoutubeRequest.channelOriginalUrl(channelId: channelID))
        let trackingParams = isLoadMore ? helper?.trackingParamsLoadMore : helper?.trackingParamsNewInstance
        guard let trackingParams = trackingParams else {
            return nil
        }
        var channelRequest = ChannelRequest(
            context: Context.init(client: client, user: Context.User.init(lockedSafetyMode: false), request: Context.Request.init(useSSL: true, internalExperimentFlags: [], consistencyTokenJars: []), clickTracking: Context.ClickTracking.init(clickTrackingParams: trackingParams))
        )
        if !isLoadMore {
            channelRequest.browseId = channelID
            channelRequest.params = YoutubeRequest.TAB_VIDEOS
            
        } else {
            channelRequest.continuation = helper?.nextPageToken
        }
        return channelRequest
    }
    
    func getChannelDetail(channelID: String, completionHandler: @escaping (ChannelModel?) -> Void) {
        
        guard let channelRequest = processDataRequest(channelID: channelID) else {
            completionHandler(nil)
            return
        }
        guard let body = try? JSONEncoder().encode(channelRequest) else {
            print("Error: Trying to convert model to JSON data")
            completionHandler(nil)
            return
        }
        let result = String(decoding: body, as: UTF8.self)
        let postData = result.data(using: .utf8)
        YoutubeRequest.postAsync(url: request?.channelUrl(), body: postData!) { (response) in
            guard let data = response else {
                completionHandler(nil)
                return
            }
            guard let dataStr  = String(data: data, encoding: .utf8) else {
                completionHandler(nil)
                return
            }
            
            guard let videosChannelResponse = dataStr.getChannelResponse() else {
                completionHandler(nil)
                return
            }
            self.helper?.trackingParamsLoadMore = videosChannelResponse.getTrackingParamsLoadMore()
            self.helper?.trackingParamsNewInstance = videosChannelResponse.getTrackingParamsSearchNew()
            self.helper?.nextPageToken = videosChannelResponse.getNextPageToken()
            completionHandler(videosChannelResponse.getChanelViewModel())
        }
        
    }
    
    func getVideosChannel(channelID: String, videoIds: [String] = [], isLoadMore: Bool = false, completionHandler: @escaping(([YoutubeModel]) -> ())) {
        guard let channelRequest = processDataRequest(channelID: channelID, isLoadMore: isLoadMore) else {
            completionHandler([])
            return
        }
        guard let body = try? JSONEncoder().encode(channelRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        YoutubeRequest.postAsync(url: request?.channelUrl(), body: body) { (response) in
            guard let data = response else {
                completionHandler([])
                return
            }
            guard let dataStr  = String(data: data, encoding: .utf8) else {
                completionHandler([])
                return
            }
            var youtubeResponse : [YoutubeModel] = []
            
            if (isLoadMore) {
                
                guard let response = dataStr.getVodaTubeLoadMoreResponse() else {
                    completionHandler([])
                    return
                }
                
                response.getVideosChannel(channelDetail: self.lastChannel, shareUrl: self.helper?.baseShareUrl ?? "").forEach { video in
                    if videoIds.isEmpty {
                        youtubeResponse.append(YoutubeModel(video: video))
                    } else {
                        if let videoId = video.videoID {
                            if !videoIds.contains(videoId) {
                                youtubeResponse.append(YoutubeModel(video: video))
                            }
                        }
                        
                    }
                }
                
                if (youtubeResponse.count == 0) {
                    completionHandler([])
                } else {
                    self.helper?.trackingParamsLoadMore = response.getContinueItem()?.continuationEndpoint?.clickTrackingParams
                    self.helper?.nextPageToken = response.getContinueItem()?.continuationEndpoint?.continuationCommand?.token
                    completionHandler(youtubeResponse)
                }
                
            } else {
                guard let channelResponse = dataStr.getChannelResponse() else {
                    completionHandler([])
                    return
                }
                self.lastChannel = channelResponse.getChanelViewModel()
                channelResponse.getVideoModel(channelDetail: self.lastChannel, shareUrl: self.helper?.baseShareUrl ?? "").forEach { video in
                    youtubeResponse.append(YoutubeModel(video: video))
                }
                if (youtubeResponse.count == 0) {
                    completionHandler([])
                } else {
                    self.helper?.trackingParamsLoadMore = channelResponse.getTrackingParamsLoadMore()
                    self.helper?.trackingParamsNewInstance = channelResponse.getTrackingParamsSearchNew()
                    self.helper?.nextPageToken = channelResponse.getNextPageToken()
                    completionHandler(youtubeResponse)
                }
            }
            
            
        }
    }
}
