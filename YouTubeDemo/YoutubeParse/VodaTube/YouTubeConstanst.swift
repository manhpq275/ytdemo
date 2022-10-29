//
//  YouTubeConstanst.swift
//  YouTubeDemo
//
//  Created by Cu Rua Vui Tinh on 21/10/2022.
//

import Foundation
import UIKit
import WebKit

class YouTubeConstanst {
    public static let origin = "https://www.youtube.com"
    public static let BaseUrl = "https://www.youtube.com/feed/history/?app=desktop"
    
    public static let LoginUrl = "https://accounts.google.com/ServiceLogin?service=youtube&amp;uilel=3&amp;passive=true&amp;continue=https%3A%2F%2Fwww.youtube.com%2Fsignin%3Faction_handle_signin%3Dtrue%26app%3Dm%26hl%3Den%26next%3Dhttps%253A%252F%252Fm.youtube.com%252F%2523&amp;hl=vi"
    public static let SAPISID_KEY = "SAPISID"
}

extension WKWebView {
    private var httpCookieStore: WKHTTPCookieStore  {
        return WKWebsiteDataStore.default().httpCookieStore
    }
    
    func getCookies(for domain: String, cookieName: String, result: @escaping (String) -> Void) {
        getCookies(for: domain) { data in
            let cookieArray = data.components(separatedBy: ";")
            for item in cookieArray {
                if (item.contains(cookieName)){
                    result(item.components(separatedBy: "=")[1])
                }
            }
        }
    }
    func getCookies(for domain: String, result: @escaping (String) -> Void) {
        var values = ""
        httpCookieStore.getAllCookies { cookies in
            let lastDomainCookie = cookies.reversed().first { $0.domain.contains(domain)}
            for cookie in cookies {
                if cookie.domain.contains(domain) {
                    values.append(cookie.name)
                    values.append("=")
                    values.append(cookie.value)
                    if (lastDomainCookie?.value != cookie.value){
                        values.append("; ")
                    }
                }
            }
            result(values)
        }
    }
    
    func clearCookies(completed: @escaping (Bool) -> Void) {
        self.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                self.httpCookieStore.delete(cookie)
            }
            completed(true)
        }
    }
}
