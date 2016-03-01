//
//  CallRegionAPI.swift
//  testlocation
//
//  Created by Rplay on 22/02/16.
//  Copyright © 2016 had. All rights reserved.
//

import Foundation

class Request {
    
    func sendForRegion(url: String, f: (NSDictionary) -> ()) {
        
        do {
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = "POST"
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(["object":"object"], options: .PrettyPrinted)
            var response: NSURLResponse?
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? NSDictionary
            f(json!)
            
        }
            
        catch let err as NSError {
            print(err)
        }
        
    }
    
    func userWithinPlace(url: String, f: (NSDictionary) -> ()) {
        do {
            print(url)
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = "POST"
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(["object":"object"], options: .PrettyPrinted)
            var response: NSURLResponse?
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? NSDictionary
            f(json!)
        }
        catch let err as NSError {
            print(err)
        }
    }
}