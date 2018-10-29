//
//  RequestModelBeautifier.swift
//  Wormholy-iOS
//
//  Created by Paolo Musolino on 18/04/18.
//  Copyright © 2018 Wormholy. All rights reserved.
//

import UIKit

class RequestModelBeautifier: NSObject {
    
    static func overview(request: RequestModel) -> NSMutableAttributedString{
        let url = NSMutableAttributedString().bold("URL ").normal(request.url + "\n")
        let method = NSMutableAttributedString().bold("Method ").normal(request.method + "\n")
        let responseCode = NSMutableAttributedString().bold("Response Code ").normal((request.code != 0 ? "\(request.code)" : "-") + "\n")
        let requestStartTime = NSMutableAttributedString().bold("Request Start Time ").normal((request.date.stringWithFormat(dateFormat: "MMM d yyyy - HH:mm:ss") ?? "-") + "\n")
        let duration = NSMutableAttributedString().bold("Duration ").normal(request.duration?.formattedMilliseconds() ?? "-" + "\n")
        let final = NSMutableAttributedString()
        for attr in [url, method, responseCode, requestStartTime, duration]{
            final.append(attr)
        }
        return final
    }
    
    static func header(_ headers: [String: String]?) -> NSMutableAttributedString{
        guard let headerDictionary = headers else {
            return NSMutableAttributedString(string: "-")
        }
        let final = NSMutableAttributedString()
        for (key, value) in headerDictionary {
            final.append(NSMutableAttributedString().bold(key).normal(" " + value + "\n"))
        }
        return final
    }
    
    static func body(_ body: Data?, splitLength: Int? = nil, completion: @escaping (String) -> Void){
        DispatchQueue.global().async {
            completion(RequestModelBeautifier.body(body, splitLength: splitLength))
            return
        }
    }
    
    static func body(_ body: Data?, splitLength: Int? = nil) -> String{
        guard let theBody = body else {
            return "-"
        }
        
        if let data = splitLength != nil ? String(data: body!, encoding: .utf8)?.characters(n: splitLength!) : String(data: body!, encoding: .utf8){
            if let json = try? JSONSerialization.jsonObject(with: theBody, options: .allowFragments) {
                return "\(json as AnyObject)"
            }
            return data
        }
        
        return "-"
    }
    
    static func txtExport(request: RequestModel) -> String{
        
        var txt: String = ""
        txt.append("*** Overview *** \n")
        txt.append(overview(request: request).string + "\n\n")
        txt.append("*** Request Header *** \n")
        txt.append(header(request.headers).string + "\n\n")
        txt.append("*** Request Body *** \n")
        txt.append(body(request.httpBody) + "\n\n")
        txt.append("*** Response Header *** \n")
        txt.append(header(request.responseHeaders).string + "\n\n")
        txt.append("*** Response Body *** \n")
        txt.append(body(request.dataResponse) + "\n\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n\n\n\n")
        return txt
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
        append(normal)
        return self
    }
}
