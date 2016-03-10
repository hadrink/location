//
//  BackgroundTask.swift
//  testBackground
//
//  Created by Rplay on 04/03/16.
//  Copyright © 2016 had. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class BackgroundTask : NSObject {
    
    let backgroundTaskName = "task1"
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var application = UIApplication.sharedApplication()
    
    //-- Method for check if mulitask is supported
    func isMultitaskingSupported() -> Bool{
        return UIDevice.currentDevice().multitaskingSupported
    }
    
    //-- Method for launch background task when user is inside
    func applicationBackgrounded() {
        
        //-- We check if mulitask is supported
        if isMultitaskingSupported() == false{
            return
        }
        
        //-- Launch background task
        self.backgroundTaskIdentifier = application.beginBackgroundTaskWithName(backgroundTaskName, expirationHandler: {[weak self] in
                
        })
    }
    
    //-- Method allowing to cancel background task
    func endBackgroundTask(){
        let mainQueue = dispatch_get_main_queue()
        dispatch_async(mainQueue, {[weak self] in
            UIApplication.sharedApplication().endBackgroundTask(self!.backgroundTaskIdentifier)
            self!.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        })
    }
}
