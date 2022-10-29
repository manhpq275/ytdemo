//
//  YoutubeConstanst.swift
//  AdSpy
//
//  Created by Cu Rua Vui Tinh on 13/05/2022.
//  Copyright © 2022 Cu Rua Vui Tinh. All rights reserved.
//

import Foundation

class YoutubeRequest {
   
    public static let TAB_VIDEOS = "EgZ2aWRlb3M%3D"
    public static let USER_AGENT =
                "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.98 Safari/537.36"
    public static let patClientResponse = "\"INNERTUBE_CONTEXT\"\\s*:\\s*(\\{.+?\\})"
    public static let patDeviceKeyResponse = "\"INNERTUBE_API_KEY\":\""
    private var deviceId = ""
    init(deviceId: String?) {
        self.deviceId = deviceId ?? ""
    }
    func loadMoreUrl() -> URL? { return URL(string: "https://www.youtube.com/youtubei/v1/browse?key=\(self.deviceId)&prettyPrint=false") }
    
    static func toDictionary(body: Any) -> [String:Any] {
        let mirror = Mirror(reflecting: body)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
          guard let label = label else { return nil }
          return (label, value)
        }).compactMap { $0 })
        return dict
      }
    
    static func postAsync(
        url: URL?,
        body: Data,
        userAgent: String = YoutubeRequest.USER_AGENT,
        authorization: String = "",
        mCookies: String = "",
        completionHandler: @escaping (Data?) -> Void)
    {
        guard let url = url else {
            completionHandler(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(userAgent, forHTTPHeaderField: "user-agent")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        if (!authorization.isEmpty) {
            request.addValue(authorization, forHTTPHeaderField: "authorization")
        }
        request.addValue("https://www.youtube.com", forHTTPHeaderField: "origin")
        request.addValue(mCookies, forHTTPHeaderField: "cookie")
        request.httpBody = body
        let session = URLSession.shared
        print(request.cURL(pretty: true))
        session.dataTask(with: request) { (data, response, error) in
            completionHandler(data)
        }.resume()
    }
 
}


extension URLRequest {
public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
