//
//  PlaceManager.swift
//  testlocation
//
//  Created by Rplay on 22/02/16.
//  Copyright © 2016 had. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class PlaceManager : NSObject, CLLocationManagerDelegate {
    
    //-- Root constantes
    let request = Request()
    let bgTask = BackgroundTask()
    let userDefault = NSUserDefaults()
    var locationManager : CLLocationManager?
    
    //-- Root variables
    var regionToMonitorItems = [RegionToMonitor]()
    var userWithinPlace = false
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var timer : NSTimer?
    
    //-- Initialize PlaceManager
    override init() {
        super.init()
        
        // Set bool for key inside_region & george_clooney_inside if key doesn't exist
        if userDefault.objectForKey("inside_region") == nil {
            userDefault.setBool(false, forKey: "inside_region")
        }
        
        if userDefault.objectForKey("george_clooney_inside") == nil {
            userDefault.setBool(false, forKey: "george_clooney_inside")
        }
        
        userDefault.synchronize()
        
        self.locationManager = PlaceManager.sharedLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
    }
    
    class func sharedLocationManager()->CLLocationManager? {
        
        struct Static {
            static var _locationManager : CLLocationManager?
        }
        
        objc_sync_enter(self)
        if Static._locationManager == nil {
            Static._locationManager = CLLocationManager()
            Static._locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        
        objc_sync_exit(self)
        return Static._locationManager!
    }
    
    //-- Method to start monitoring a region
    func startMonitoringRegion(regionToMonitor: RegionToMonitor) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            return
        }
        
        let region = circularRegion(regionToMonitor)
        locationManager?.startMonitoringForRegion(region)
        print(region.identifier)
    }
    
    //-- Transform a basic region to a circular region
    func circularRegion(geotification: RegionToMonitor) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    //-- Method called to get 20 places around the user
    func createRegion() {
        
        //-- Check if monitored regions already exist
        if locationManager?.monitoredRegions.count != 0 {
            
            //-- Delete regions and empty the regionToMonitorItems
            stopMonitoringRegion()
            regionToMonitorItems.removeAll()
        }
        
        //-- Call region and append regionToMonitorItems
        request.sendForRegion("https://hadrink.herokuapp.com/closeplaces/places/\(self.latitude)/\(self.longitude)/10000/", f: {(result: NSDictionary) -> () in
            
            //-- We check if listbar object exists
            if let regionItems = result["listbar"] as? [NSDictionary]  {
                
                //-- Loop on each region received
                for regionItem in regionItems {
                    
                    //-- Check if the region contains the "properties" object
                    if var placeProperties = regionItem["properties"] as? [String:AnyObject] {
                        
                        //-- Ignore every places without "name"
                        if (placeProperties["name"] != nil) {
                            
                            if var placeLocation = regionItem["loc"] as? [String:AnyObject] {
                                
                                //-- Create a specific identifier
                                let identifier = placeProperties["name"] as? String
                                
                                //-- Transform coordinates received to CLLocationCoordinate2D
                                let placeCoordinate = placeLocation["coordinates"]! as? NSArray
                                let placeLongitude = placeCoordinate!.firstObject as! NSObject
                                let placeLatitude = placeCoordinate!.lastObject as! NSObject
                                let placeLatitudeDegrees = placeLatitude as? Double
                                let placeLongitudeDegrees = placeLongitude as? Double
                                let regionCoordinate = CLLocationCoordinate2D(latitude: placeLatitudeDegrees!, longitude: placeLongitudeDegrees!)
                                
                                //-- Distance between the user and the place
                                let userCoordinatesDegrees = CLLocation(latitude: self.latitude, longitude:self.longitude)
                                let regionCoordinatesDegrees = CLLocation(latitude: placeLatitudeDegrees!, longitude: placeLongitudeDegrees!)
                                let distanceInMeters = userCoordinatesDegrees.distanceFromLocation(regionCoordinatesDegrees)
                                
                                //-- Append regionToMonitorItems array with a RegionToMonitor object
                                self.regionToMonitorItems.append(RegionToMonitor(coordinate: regionCoordinate, radius: 20, identifier: identifier!, distance: distanceInMeters))
                            } else {
                                print("Object without loc")
                            }
                        } else {
                            print("Object without name")
                        }
                    } else {
                        print("Object without properties")
                    }
                }
            }
        })
        
        //-- filter regions by distance
        regionToMonitorItems.sortInPlace({ $0.distance < $1.distance })
        
        //-- Add only the nearest region
        if regionToMonitorItems.count > 0 && locationManager?.monitoredRegions.count == 0 {
            startMonitoringRegion(regionToMonitorItems.first!)
        }
        
    }
    
    
    //-- Method called when we start updating the location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Did Update Location")
        
        //-- Get Location
        let location = locations.last
        let newLatitude = location?.coordinate.latitude
        let newLongitude = location?.coordinate.longitude
        let insideRegion = userDefault.boolForKey("inside_region")
        
        self.latitude = newLatitude!
        self.longitude = newLongitude!
        
        /*for (var i : Int = 0; i < locations.count; i++) {
            let newLocation : CLLocation? = locations[i] as CLLocation
            let location : CLLocationCoordinate2D = newLocation!.coordinate
            let theAccuracy : CLLocationAccuracy = newLocation!.horizontalAccuracy
            let locationAge : NSTimeInterval = newLocation!.timestamp.timeIntervalSinceNow
            if locationAge > 30.0 {
                continue
            }
            
            // Select only valid location and also location with good accuracy
            if (newLocation != nil) && (theAccuracy > 0) && (theAccuracy < 2000) && !((location.latitude == 0.0) && (location.longitude == 0.0)) {
                self.latitude = location.latitude
                self.longitude = location.longitude
            }
        }*/
            
        
        if !insideRegion {
            print("Object before monitoring \(self.locationManager?.monitoredRegions.count)")
            createRegion()
            print("Object monitored \(self.locationManager?.monitoredRegions.count)")
        } else {
            locationManager?.stopUpdatingLocation()
        }

    }
    
    //-- Method called when the location update failed
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    //-- Method trigger when the region monitoring start correctly
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        if region.identifier == regionToMonitorItems.first?.identifier {

            let notification = UILocalNotification()
            notification.alertBody = "DidStartMonitoring + \(region.identifier)"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
            print("DidStartMonitoringForRegion")
            print(region.identifier)
        
            locationManager?.requestStateForRegion(region)
        }
    }
    
    //-- Method for determinate the state of each region. Trigger by "locationManager.requestStateForRegion(region)"
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        switch state {
        case .Inside:
            let notification = UILocalNotification()
            notification.alertBody = "Inside"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            print("didDetermineState CLRegionState.Inside \(region.identifier)")
            
            //-- We stop monitoring for significant location changes
            locationManager?.stopMonitoringSignificantLocationChanges()
            
            //-- We set true for key inside_region
            userDefault.setBool(true, forKey: "inside_region")
            
            //-- Sync the NSUserDefault
            userDefault.synchronize()
            
            //-- Launch backgroundtask
            bgTask.applicationBackgrounded()
            
            //-- Launch timer to get if user is within
            timerToGetUserIsWithinRegion()
            
        case .Outside:
            let notification = UILocalNotification()
            notification.alertBody = "Outside"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
            print("Outside")
            
            //-- We stop updating location
            locationManager?.stopUpdatingLocation()
            
            //-- We set false for key inside_region
            userDefault.setBool(false, forKey: "inside_region")
            
            //-- We set false for key george_clooney_inside
            userDefault.setBool(false, forKey: "george_clooney_inside")
            
            //-- Sync the new keys
            userDefault.synchronize()
            
            //-- We restart monitoring location changes for refresh regions
            locationManager?.startMonitoringSignificantLocationChanges()
            
            //-- Reset timer
            timer?.invalidate()
            
        case .Unknown:
            let notification = UILocalNotification()
            notification.alertBody = "Unknown"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            print("didDetermineState CLRegionState.Unknown")
            
            //-- We stop updating location
            locationManager?.stopUpdatingLocation()
            
            //-- We set false for key inside_region
            userDefault.setBool(false, forKey: "inside_region")
            
            //-- We set false for key george_clooney_inside
            userDefault.setBool(false, forKey: "george_clooney_inside")
            
            //-- Sync the new keys
            userDefault.synchronize()
            
            //-- We restart monitoring location changes for refresh regions
            locationManager?.startMonitoringSignificantLocationChanges()
            
            //-- Reset timer
            timer?.invalidate()
        }
    }
    
    //-- Method for print errors during the region saving
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Error Monitoring")
        print(region?.identifier)
        print(error.description)
    }
    
    
    //-- Method called when the user did enter in the region
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        //-- We request region state
        if region.identifier == regionToMonitorItems.first?.identifier {
            locationManager?.requestStateForRegion(region)
            
            let notification = UILocalNotification()
            notification.alertBody = "Did Enter Region + \(region.identifier)"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    //-- Method called when the user did exit in the region
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        //-- We request region state
        if region.identifier == regionToMonitorItems.first?.identifier {

            locationManager?.requestStateForRegion(region)
        
            let notification = UILocalNotification()
            notification.alertBody = "Did Exit Region + \(region.identifier)"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    //-- Method for delete regions
    func stopMonitoringRegion() {

        //-- Foreach region already monitored we delete it
        for regionMonitored in self.locationManager!.monitoredRegions {
            if let circularRegion = regionMonitored as? CLCircularRegion {
                print(circularRegion.identifier)
                self.locationManager?.stopMonitoringForRegion(circularRegion)
            }
        }
    }
    
    //-- Method for request state for region
    func requestState() {
        
        //-- Foreach region already monitored we get the state
        for regionMonitored in self.locationManager!.monitoredRegions {
            if let circularRegion = regionMonitored as? CLCircularRegion {
                print(circularRegion.identifier)
                self.locationManager?.requestStateForRegion(circularRegion)
            }
        }
    }
    
    //-- Method for check if user is within place
    func checkUserIsWithinPlace() {
        
        //-- We send the specific request for set the "userWithinPlace" variable
        request.userWithinPlace("https://hadrink.herokuapp.com/usercoordinate/users/976915349020345/\(self.latitude)/\(self.longitude)", f: {(result: NSDictionary) -> () in
            print(result["result"])
            if let resultRequest = result["result"] as? NSDictionary  {
                let success:Bool = resultRequest["success"] as! Bool
                self.userWithinPlace = success
            }
        })
    }
    
    func updateLocationWhenUserIsWithinRegion() {
        let georgeClooneyInside = userDefault.boolForKey("george_clooney_inside")
        let insideRegion = userDefault.boolForKey("inside_region")
        
        let notification3 = UILocalNotification()
        notification3.alertBody = "Launch timer"
        notification3.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification3)
        
        let notification = UILocalNotification()
        notification.alertBody = "Inside region\(insideRegion)"
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)

        let notification2 = UILocalNotification()
        notification2.alertBody = "Inside polygon\(georgeClooneyInside)"
        notification2.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification2)

        
        if !georgeClooneyInside && insideRegion{
            
            let notification = UILocalNotification()
            notification.alertBody = "In Region but place outside"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
            locationManager?.startUpdatingLocation()
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.pausesLocationUpdatesAutomatically = false
            
            //-- We check if user is within place
            checkUserIsWithinPlace()
            
            //-- Stop updating location after check if user is within place
            locationManager?.stopUpdatingLocation()
            
            //-- We set the new value for key george_clooney_inside
            userDefault.setBool(userWithinPlace, forKey: "george_clooney_inside")
            
        } else {
            let notification = UILocalNotification()
            notification.alertBody = "Background task killed"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            
            //-- Reset timer
            //timer?.invalidate()
            
            /*locationManager?.stopUpdatingLocation()
            locationManager?.startMonitoringSignificantLocationChanges()
            BackgroundTask().endBackgroundTask()
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }*/
        }
    }
    
    func timerToGetUserIsWithinRegion() {

        //-- Reset timer
        timer?.invalidate()

        //-- Timer for test user is within polygon
        timer = NSTimer.scheduledTimerWithTimeInterval(20.0,
            target: PlaceManager(),
            selector: "updateLocationWhenUserIsWithinRegion",
            userInfo: nil,
            repeats: true)
    }
}
