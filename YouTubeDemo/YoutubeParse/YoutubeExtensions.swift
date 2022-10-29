//
//  StringExtensions.swift
//  AdSpy
//
//  Created by Cu Rua Vui Tinh on 3/31/22.
//  Copyright © 2022 Cu Rua Vui Tinh. All rights reserved.
//

import Foundation

protocol Serializable {
    var properties:Array<String> { get }
    func valueForKey(key: String) -> Any?
    func toDictionary() -> [String:Any]
}

extension Serializable {
    func toDictionary() -> [String:Any] {
        var dict:[String:Any] = [:]

        for prop in self.properties {
            if let val = self.valueForKey(key: prop) as? String {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Int {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Double {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Array<String> {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Serializable {
                dict[prop] = val.toDictionary()
            } else if let val = self.valueForKey(key: prop) as? Array<Serializable> {
                var arr = Array<[String:Any]>()

                for item in (val as Array<Serializable>) {
                    arr.append(item.toDictionary())
                }

                dict[prop] = arr
            }
        }

        return dict
    }
}

extension String {
    func getYoutubeKey() -> String {
        let tmp = self.components(separatedBy: YoutubeRequest.patDeviceKeyResponse)[1]
        return tmp.components(separatedBy: "\",\"")[0]
    }
    
    func getTimeByText() -> Int {
        let split = self.components(separatedBy: ":")
        if (split.count == 1) {
            return 0
        }
        var time = Int(split.last ?? "0") ?? 0
        if (split.count == 3) {
            time = time + (Int(split.first ?? "0") ?? 0) * 3600 + (Int(split[2]) ?? 0) * 60
        } else {
            time = time + (Int(split.first ?? "0") ?? 0) * 60
        }
        
        return time
        
    }
    func getLoadMoreResponse() -> YoutubeHistoriesReponse? {
        do {
            let basicJSONData = self.data(using: .utf8)!
            let dict = try JSONDecoder().decode(YoutubeHistoriesReponse.self, from: basicJSONData)
            return dict
            
        } catch {
            print("Error during ecoding: \(error)")
        }
        return nil
    }
    
    func getInitResponse() -> YoutubeHistoriesReponse? {
        do {
            let json = self
                .components(separatedBy: "var ytInitialData = ")[1]
                .components(separatedBy: ";</script>")[0]
            let basicJSONData = json.data(using: .utf8)!
            let dict = try JSONDecoder().decode(YoutubeHistoriesReponse.self, from: basicJSONData)
            return dict
            
        } catch {
            print("Error during ecoding: \(error)")
        }
        return nil
    }
    
    func getClient() -> InitYoutubeclient? {
        do {
            let jsonInit = self.components(separatedBy: "{window.ytplayer={};\nytcfg.set(")[1]
                .components(separatedBy: "); ")[0];
            let basicJSONData = jsonInit.data(using: .utf8)!
            let dict = try JSONDecoder().decode(InitYoutubeclient.self, from: basicJSONData)
            return dict
            
        } catch {
            print("Error during ecoding: \(error)")
        }
        return nil
            
    }
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
