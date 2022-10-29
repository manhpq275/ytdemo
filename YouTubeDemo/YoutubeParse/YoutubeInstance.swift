//
//  YoutubeInstance.swift
//  YouTubeDemo
//
//  Created by Cu Rua Vui Tinh on 21/10/2022.
//

import Foundation
import UIKit
import WebKit
import CommonCrypto

protocol YoutubeDelegate: NSObject {
    func isInit()
    func isLogin()
}

class YoutubeInstance: NSObject, WKNavigationDelegate  {
    private var helper: YouTubeHelper? = nil
    private var request: YoutubeRequest? = nil
    private var initResponse: YoutubeHistoriesReponse? = nil
    private var mWebview: WKWebView? = nil
    private var firstVideos: [VideoModel] = []
    private weak var delegate: YoutubeDelegate? = nil
    
    init(webview: WKWebView, delegate: YoutubeDelegate?){
        super.init()
        helper = YouTubeHelper()
        mWebview = webview
        self.delegate = delegate
        reloadWeb()
    }
  
    func reloadWeb(){
        mWebview?.load(URLRequest(url: URL(string: YouTubeConstanst.BaseUrl)!))
    }
    func loginYoutube() {
        mWebview?.load(URLRequest(url: URL(string: YouTubeConstanst.LoginUrl)!))
    }
    
  
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        if (mWebview?.url?.absoluteString.contains(YouTubeConstanst.BaseUrl) == false) {
            if (mWebview?.url?.absoluteString.contains("myaccount.google.com") == true){
                self.delegate?.isLogin()
            }
        } else {
            self.mWebview?.getCookies(for: "youtube.com", result: { cookie in
                self.helper?.setCookies(cookies: cookie)
            })
            self.mWebview?.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML", completionHandler: { (value: Any?, error: Error?) -> Void in
                if error != nil {
                    //Error logic
                    return
                }
                
                self.initResponse = (value as? String)?.getInitResponse()
                self.helper?.deviceKey = (value as? String)?.getYoutubeKey()
                self.helper?.setClient(client: (value as? String)?.getClient()?.innertubeContext.client)
                self.request = YoutubeRequest(deviceId: (self.helper?.deviceKey))
                if let initResponse = self.initResponse {
                    self.saveLoadMore(resultObject: initResponse, isLoadMore: false)
                    self.saveLastRecent(lastRecent: initResponse.getVideos(isLoadMore: false))
                    self.delegate?.isInit()
                }
                if (self.firstVideos.isEmpty) {
                    self.delegate?.isInit()
                }
            })
        }
    }
    
    private func saveLoadMore(resultObject: YoutubeHistoriesReponse, isLoadMore: Bool){
        guard let continueItem = resultObject.getContinueItem(isLoadMore: isLoadMore) else {
            return
        }
        self.helper?.trackingParamsLoadMore = continueItem.continuationEndpoint?.clickTrackingParams
        self.helper?.nextPageToken = continueItem.continuationEndpoint?.continuationCommand?.token
    }
    func getVideos(isLoadMore: Bool, completionHandler: @escaping ([VideoModel]) -> Void) {
        if (isLoadMore) {
            self.loadMore { response in
                //self.saveLastRecent(lastRecent: response)
                completionHandler(response)
                return
            }
            return
        } else {
            completionHandler(self.firstVideos)
        }
    }
    
    private func saveLastRecent(lastRecent: [VideoModel]) {
        self.firstVideos = lastRecent
    }
    
    private func processDataRequest() -> YTRequest?{
        guard var client = helper?.getClient() else {
            return nil
        }
        client.setOriginalURL(url: YouTubeConstanst.BaseUrl)
        
        guard let trackingParams = helper?.trackingParamsLoadMore else {
            return nil
        }
        
        var channelRequest = YTRequest(
            context: Context.init(client: client, user: Context.User.init(lockedSafetyMode: false), request: Context.Request.init(useSSL: true, internalExperimentFlags: [], consistencyTokenJars: []), clickTracking: Context.ClickTracking.init(clickTrackingParams: trackingParams))
        )
        
        channelRequest.continuation = helper?.nextPageToken
        return channelRequest
    }
    
    private func loadMore(completionHandler: @escaping ([VideoModel]) -> Void) {
        guard let channelRequest = processDataRequest() else {
            completionHandler([])
            return
        }
        guard let body = try? JSONEncoder().encode(channelRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        YoutubeRequest.postAsync(
            url: request?.loadMoreUrl(),
            body: body,
            userAgent: self.helper?.getClient()?.userAgent ?? YoutubeRequest.USER_AGENT,
            authorization: getAuthorization(),
            mCookies: self.helper?.getCookies() ?? "") { (response) in
                guard let data = response else {
                    completionHandler([])
                    return
                }
                guard let dataStr  = String(data: data, encoding: .utf8) else {
                    completionHandler([])
                    return
                }
                
                guard let response = dataStr.getLoadMoreResponse() else {
                    completionHandler([])
                    return
                }
                let videos = response.getVideos(isLoadMore: true)
                var result: [VideoModel] = []
                result.append(contentsOf: videos)
                if (result.count == 0) {
                    completionHandler([])
                } else {
                    self.saveLoadMore(resultObject: response, isLoadMore: true)
                    completionHandler(result)
                }
                
            }
    }
    
    private func getAuthorization() -> String {
        let currentTime = Int(NSDate().timeIntervalSince1970)
        guard let sapisid = self.helper?.getSAPISID() else {
            return ""
        }
        if sapisid.isEmpty {
            return ""
        }
        let contentHash = "\(currentTime) \(sapisid) \(YouTubeConstanst.origin)"
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
    func logOut(completionHandler: @escaping () -> Void) {
        self.helper?.setCookies(cookies: nil)
        self.mWebview?.clearCookies { data in
            completionHandler()
        }
    }
}
