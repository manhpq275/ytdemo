//
//  ViewController.swift
//  YouTubeDemo
//
//  Created by Cu Rua Vui Tinh on 20/10/2022.
//

import UIKit
import WebKit
class ViewController: UIViewController, YoutubeDelegate {

    @IBOutlet weak var mWebView: WKWebView!
    
    @IBOutlet weak var tvResult: UITextView!
    var youtubeInstance: YoutubeInstance? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        youtubeInstance =  YoutubeInstance(webview: mWebView, delegate: self)
        mWebView.navigationDelegate = youtubeInstance
    }
    @IBAction func Login(_ sender: Any) {
        youtubeInstance?.loginYoutube()
    }
    @IBAction func loadMoreAsync(_ sender: Any) {
        youtubeInstance?.getVideos(isLoadMore: true) { [weak self]  result in
            self?.processVideos(videos: result, isLoadMore: true)
        }
    }
    func isInit(){
        youtubeInstance?.getVideos(isLoadMore: false) { [weak self] result in
            self?.processVideos(videos: result, isLoadMore: false)
        }
    }
    func isLogin() {
        youtubeInstance?.reloadWeb()
    }

    func processVideos(videos: [VideoModel], isLoadMore: Bool) {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                var videoInfos = isLoadMore ? "LoadMore Completed============" : ""
                for video in videos {
                    videoInfos.append(contentsOf: "\nvideoId: \(video.videoID ?? "")")
                    videoInfos.append(contentsOf: "\ntitle: \(video.title ?? "")")
                    videoInfos.append(contentsOf: "\npublished Time: \(video.publishedVideoAt ?? "")")
                    videoInfos.append(contentsOf: "\nchannel name: \(video.channelName ?? "")")
                    videoInfos.append(contentsOf: "\nchannel Id: \(video.channelID ?? "")")
                    videoInfos.append(contentsOf: "\n============================")
                }
                self.tvResult.text = videoInfos
            }
        }
    }
}

