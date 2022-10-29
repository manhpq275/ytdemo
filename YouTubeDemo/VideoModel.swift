//
//  VideoModel.swift
//  YouTubeDemo
//
//  Created by Cu Rua Vui Tinh on 20/10/2022.
//

import Foundation

struct VideoModel {
    var id: Int? = nil
    var time: Int? = nil
    var videoID: String? = nil
    var title: String? = nil
    var thumbnail: String? = nil
    var views: String? = nil
    var channelID: String? = nil
    var channelImage: String? = nil
    var channelName: String? = nil
    var channelNumberFollower: String? = nil
    var publishedVideoAt: String? = nil
    var type: Int? = 0
    var pickName: String? = nil
    var isSaveRoom: Int? = nil
    var statusPublished: Int? = nil
    var existEvent: Int? = nil
    var shareUrl: String? = nil
}

struct ChannelModel {
    var id: Int? = nil
    var videoID: String? = nil
    var content: String? = nil
    var created: Int? = nil
    var linkRoom: String? = nil
    var channelID: String? = nil
    var isFavorite: Int? = nil
    var channelModelDescription: String? = nil
    var slug: String? = nil
    
    // V3
    var channelName: String? = nil
    var channelNumberFollower: String? = nil
    var channelImage: String? = nil
    var views: String? = nil
    var publishedVideoAt: String? = nil
    
    var isSaveRoom: Int? = nil
    
    var channelSubscribe: String? = nil
    var createdAtView: String? = nil
    var statusRegister: String? = nil
    
    var isSaveChannel: Int? = nil
    
    var videoCount: String? = nil

}

