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
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var myTimer: NSTimer?
    var updateLocationEveryMinute: NSTimer?
    let backgroundTaskName = "task1"
    var application = UIApplication.sharedApplication()
    let userDefault = NSUserDefaults()
    
    override init()  {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationBackgrounded", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func isMultitaskingSupported() -> Bool{
        return UIDevice.currentDevice().multitaskingSupported
    }
    
    func timerMethod(sender: NSTimer){
        
        let backgroundTimeRemaining =
        UIApplication.sharedApplication().backgroundTimeRemaining
        
        if backgroundTimeRemaining == DBL_MAX{
            print("Background Time Remaining = Undetermined")
        } else {
            print("Background Time Remaining = " +
                "\(backgroundTimeRemaining) Seconds")
        }
        
    }
    
    func applicationBackgrounded() {
        if isMultitaskingSupported() == false{
            return
        }
        
        myTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: "timerMethod:",
            userInfo: nil,
            repeats: true)
        
        
        self.backgroundTaskIdentifier =
            application.beginBackgroundTaskWithName(backgroundTaskName,
                expirationHandler: {[weak self] in
                    
                    while(true) {
                        
                    }
                    //-- When background task is finished continue to check if user is within
                    PlaceManager().updateLocationWhenUserIsWithinRegion()
        
                })
    }
    
    func applicationForeground() {
        if backgroundTaskIdentifier != UIBackgroundTaskInvalid{
            endBackgroundTask()
        }
    }
    
    
    func endBackgroundTask(){
        
        let mainQueue = dispatch_get_main_queue()
        
        dispatch_async(mainQueue, {[weak self] in
            if let timer = self?.updateLocationEveryMinute{
                timer.invalidate()
                self!.updateLocationEveryMinute = nil
                UIApplication.sharedApplication().endBackgroundTask(
                    self!.backgroundTaskIdentifier)
                self!.backgroundTaskIdentifier = UIBackgroundTaskInvalid
            }
        })
    }
}
