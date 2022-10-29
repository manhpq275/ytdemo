//
//  YoutubeSearch.swift
//  AdSpy
//
//  Created by Cu Rua Vui Tinh on 13/05/2022.
//  Copyright © 2022 Cu Rua Vui Tinh. All rights reserved.
//

import Foundation

class YoutubeSearch: YoutubeInstance {
    private var lastRecentSearchResult = [YoutubeModel]()
    private func processDataRequest(keyword: String, isLoadMore: Bool = false) -> SearchRequest?{
        guard var client = helper?.client else {
            return nil
        }
        client.setOriginalURL(url: YoutubeRequest.searchOriginalUrl(keyword: keyword))
        let trackingParams = isLoadMore ? helper?.trackingParamsLoadMore : helper?.trackingParamsNewInstance
        guard let trackingParams = trackingParams else {
            return nil
        }
        var searchRequest = SearchRequest(
            context: Context.init(client: client, user: Context.User.init(lockedSafetyMode: false), request: Context.Request.init(useSSL: true, internalExperimentFlags: [], consistencyTokenJars: []), clickTracking: Context.ClickTracking.init(clickTrackingParams: trackingParams))
        )
        if !isLoadMore {
            searchRequest.query = keyword
        } else {
            searchRequest.continuation = helper?.nextPageToken
        }
        return searchRequest
    }
    
    private func processQuerySuggestion(keyword: String) -> String?{
        guard let client = helper?.client else {
            return nil
        }
        guard let keywordEncode = keyword.encodeUrl() else {
            return nil
        }
        let result = "?client=youtube&hl=\(client.hl ?? "en" )&gl=\(client.gl ?? "vn")&gs_rn=64&gs_ri=youtube&ds=yt&q=\(keywordEncode)&xhr=t&xssi=t"
        
        return result
    }
    
    func suggestionSearch(keyword: String, completionHandler: @escaping ([String]) -> Void) {
        
        guard let query = processQuerySuggestion(keyword: keyword) else {
            completionHandler([])
            return
        }
        
        YoutubeRequest.getAsync(url: request?.suggestionSearchUrl(query: query), completionHandler: {
            (response) in
            guard let data = response else {
                completionHandler([])
                return
            }
            
            guard let dataStr  = String(data: data, encoding: .utf8) else {
                completionHandler([])
                return
            }
            
            let prettyStr = dataStr.replacingOccurrences(of: ")]}'\n[", with: "[")
            do {
                let basicJSONData = prettyStr.data(using: .utf8)!
                var result: [String] = []
                guard let jsonArray = try JSONSerialization.jsonObject(with: basicJSONData, options : .allowFragments) as? [Any] else {
                    print("bad json")
                    completionHandler([])
                    return
                }
                guard let items = jsonArray[1] as? [Any] else {
                    completionHandler([])
                    return
                }
                if items.count > 2 {
                    for i in 0...(items.count - 1) {
                        if i < 10 {
                            guard let itemArray = items[i] as? [Any]  else {
                                continue
                            }
                            guard let itemResult = itemArray[0] as? String  else {
                                continue
                            }
                            result.append(itemResult)
                            print(itemResult) // use the json here
                        }
                        
                    }
                } else {
                    for item in items {
                        guard let itemArray = item as? [Any]  else {
                            continue
                        }
                        guard let itemResult = itemArray[0] as? String  else {
                            continue
                        }
                        result.append(itemResult)
                        print(itemResult) // use the json here
                        
                    }
                }
                
                completionHandler(result)
                return
            } catch {
                print("Error during ecoding: \(error)")
                completionHandler([])
                return
            }
            
        })
    }
    
    func searchChanelByVideoId(videoId: String, completionHandler: @escaping ([ChannelModel]) -> Void) {
        var timestamp = NSDate().timeIntervalSince1970

        print("===========searchChanelByVideoId: ", timestamp)
        let videoModel = lastRecentSearchResult.first { item in
            item.video != nil && item.video?.videoID == videoId
        }
        let channel = lastRecentSearchResult.first { item in
            item.channel != nil && item.channel?.channelID == videoModel?.video?.channelID
        }
        
        guard let channelDetail = channel?.channel else {
            search(keyword: videoId, isLoadMore: false) { result in
                if (result.count > 0){
                    if (result.first?.video != nil){
                        self.searchChannel(channelName: (result.first?.video?.channelName) ?? "", channelID: (result.first?.video?.channelID) ?? "") { listChannel in
                            completionHandler(listChannel)
                        }
                    } else {
                        completionHandler([])
                    }
                } else {
                    completionHandler([])
                }
            }
            timestamp = NSDate().timeIntervalSince1970

            print("===========searchChanelByVideoId End: ",timestamp)
            return
        }
        var result : [ChannelModel] = []
        result.append(channelDetail)
        completionHandler(result)
        timestamp = NSDate().timeIntervalSince1970
        print("===========searchChanelByVideoId End: ",timestamp)

    }
    
    func searchChannel(channelName: String, channelID: String, completionHandler: @escaping ([ChannelModel]) -> Void) {
        
        var keyword = channelName
        if channelName.isEmpty && !channelID.isEmpty {
            keyword = channelID
        }
        guard let searchRequest = processDataRequest(keyword: keyword) else {
            completionHandler([])
            return
        }
        guard let body = try? JSONEncoder().encode(searchRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        let result = String(decoding: body, as: UTF8.self)
        let postData = result.data(using: .utf8)
        YoutubeRequest.postAsync(url: request?.searchUrl(), body: postData!) { (response) in
            guard let data = response else {
                completionHandler([])
                return
            }
            guard let dataStr  = String(data: data, encoding: .utf8) else {
                completionHandler([])
                return
            }
            
            guard let videosChannelResponse = dataStr.getSearchReponse() else {
                completionHandler([])
                return
            }
            self.helper?.trackingParamsLoadMore = videosChannelResponse.getTrackingParamsLoadMore()
            self.helper?.trackingParamsNewInstance = videosChannelResponse.getTrackingParamsSearchNew()
            self.helper?.nextPageToken = videosChannelResponse.getNextPageToken()
            completionHandler(videosChannelResponse.getChannels(channelID: channelID))
        }
        
    }
    
    func search(keyword: String, isLoadMore: Bool = false, completionHandler: @escaping(([YoutubeModel]) -> ())) {
        guard let searchRequest = processDataRequest(keyword: keyword, isLoadMore: isLoadMore) else {
            completionHandler([])
            return
        }
        guard let body = try? JSONEncoder().encode(searchRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        YoutubeRequest.postAsync(url: request?.searchUrl(), body: body) { (response) in
            guard let data = response else {
                completionHandler([])
                return
            }
            guard let dataStr  = String(data: data, encoding: .utf8) else {
                completionHandler([])
                return
            }
            
            guard let videosChannelResponse = dataStr.getSearchReponse() else {
                completionHandler([])
                return
            }
            var youtubeResponse : [YoutubeModel] = []
            let channels = videosChannelResponse.getChannels(channelID: "")
            
            // SonHT: reduce number of channels to 1
            channels.forEach{ channel in
                self.lastRecentSearchResult.append(YoutubeModel(channel: channel))
            }
            
            if let channel = channels.first {
                youtubeResponse.append(YoutubeModel(channel: channel))
            }
            
            videosChannelResponse.getVideoModel(channelDetail: nil, shareUrl: self.helper?.baseShareUrl ?? "").forEach { video in
                let videoModel = YoutubeModel(video: video)
                youtubeResponse.append(videoModel)
                self.lastRecentSearchResult.append(videoModel)
            }
            
            if (youtubeResponse.count == 0) {
                if isLoadMore {
                    completionHandler([])
                } else {
                    self.search(keyword: "vodaplay", completionHandler: completionHandler)
                }
            } else {
                self.helper?.trackingParamsLoadMore = videosChannelResponse.getTrackingParamsLoadMore()
                self.helper?.trackingParamsNewInstance = videosChannelResponse.getTrackingParamsSearchNew()
                self.helper?.nextPageToken = videosChannelResponse.getNextPageToken()
                completionHandler(youtubeResponse)
            }
            
        }
    }
}
