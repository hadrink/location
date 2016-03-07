//
//  AppDelegate.swift
//  testlocation
//
//  Created by Rplay on 22/02/16.
//  Copyright © 2016 had. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let placeManager = PlaceManager()
    let backgroundTask = BackgroundTask()
    //var timertest : NSTimer?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let locationManager = placeManager.locationManager
        locationManager?.requestAlwaysAuthorization()
        
        if launchOptions?[UIApplicationLaunchOptionsLocationKey] != nil {
            
            print("It's a location event")
            let notification = UILocalNotification()
            notification.alertBody = "Location Event"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
            locationManager?.startMonitoringSignificantLocationChanges()
            /*timertest = NSTimer.scheduledTimerWithTimeInterval(20.0,
                target: PlaceManager(),
                selector: "updateLocationWhenUserIsWithinRegion",
                userInfo: nil,
                repeats: true)*/
            
        }
        
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType([.Badge, .Sound, .Alert]), categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIUserNotificationType([.Badge, .Sound, .Alert])
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: nil))
            application.registerForRemoteNotifications()
        }
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //placeManager.locationManager.stopUpdatingLocation()
        
        self.placeManager.locationManager?.startMonitoringSignificantLocationChanges()

        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

