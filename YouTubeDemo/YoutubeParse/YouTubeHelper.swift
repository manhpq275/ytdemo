//
//  YouTubeHelper.swift
//  AdSpy
//
//  Created by Cu Rua Vui Tinh on 13/05/2022.
//  Copyright © 2022 Cu Rua Vui Tinh. All rights reserved.
//

import Foundation

class YouTubeHelper {
    public var deviceKey: String?
    public var nextPageToken: String?
    public var trackingParamsLoadMore: String?
    public var trackingParamsNewInstance: String?
    private var SAPISID: String?
    public var baseShareUrl = ""
    
    func getCookies() -> String? {
        return UserDefaults.standard.value(forKey: "COOKIES") as? String
    }
    
    func setCookies(cookies: String?) {
        if cookies == nil {
            UserDefaults.standard.removeObject(forKey: "COOKIES")
        } else {
            UserDefaults.standard.set(cookies, forKey: "COOKIES")
        }
    }
    
    func getSAPISID() -> String {
        guard let cookies = getCookies() else {
            return ""
        }
        let cookieArray = cookies.components(separatedBy: ";")
        for item in cookieArray {
            if (item.contains(YouTubeConstanst.SAPISID_KEY)){
                return item.components(separatedBy: "=")[1]
            }
        }
        return ""
    }
    func getClient() -> Client? {
        guard let client = UserDefaults.standard.value(forKey: "CLIENT") as? String
        else {
            return nil
        }
        do {
            let basicJSONData = client.data(using: .utf8)!
            let dict = try JSONDecoder().decode(Client.self, from: basicJSONData)
            return dict
            
        } catch {
            print("Error during ecoding: \(error)")
        }
        return nil
    }
    
    func setClient(client: Client?) {
        UserDefaults.standard.removeObject(forKey: "CLIENT")
        guard let client = client else {
            return
        }

            do {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(client)
                let json = String(data: jsonData, encoding: String.Encoding.utf8)

                UserDefaults.standard.set(json, forKey: "CLIENT")
                
            } catch {
                print("Error during ecoding: \(error)")
                UserDefaults.standard.removeObject(forKey: "CLIENT")
            }
    }
}

