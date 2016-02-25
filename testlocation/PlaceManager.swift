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
    let locationManager = CLLocationManager()
    let userDefault = NSUserDefaults()
    
    //-- Root variables
    var regionToMonitorItems = [RegionToMonitor]()
    var userWithinPlace = Bool()
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    
    //-- Initialize PlaceManager
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Set bool for key inside_region & george_clooney_inside if key doesn't exist
        if userDefault.objectForKey("inside_region") == nil {
            userDefault.setBool(false, forKey: "inside_region")
        }
        
        if userDefault.objectForKey("george_clooney_inside") == nil {
            userDefault.setBool(false, forKey: "george_clooney_inside")
        }
        
        userDefault.synchronize()
    }
    
    //-- Method to start monitoring a region
    func startMonitoringRegion(regionToMonitor: RegionToMonitor) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            return
        }
        
        let region = circularRegion(regionToMonitor)
        locationManager.startMonitoringForRegion(region)
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
        if locationManager.monitoredRegions.count != 0 {
            
            //-- Delete regions and empty the regionToMonitorItems
            stopMonitoringRegion()
            regionToMonitorItems.removeAll()
        }
        
        //-- Call region and append regionToMonitorItems
        request.sendForRegion("https://hadrink.herokuapp.com/closeplaces/places/\(latitude)/\(longitude)/10000/", f: {(result: NSDictionary) -> () in
            
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
                                let identifier = NSUUID().UUIDString
                                
                                //-- Transform coordinates received to CLLocationCoordinate2D
                                let placeCoordinate = placeLocation["coordinates"]! as? NSArray
                                let placeLongitude = placeCoordinate!.firstObject as! NSObject
                                let placeLatitude = placeCoordinate!.lastObject as! NSObject
                                let placeLatitudeDegrees = placeLatitude as? Double
                                let placeLongitudeDegrees = placeLongitude as? Double
                                let regionCoordinate = CLLocationCoordinate2D(latitude: placeLatitudeDegrees!, longitude: placeLongitudeDegrees!)
                                
                                //-- Append regionToMonitorItems array with a RegionToMonitor object
                                self.regionToMonitorItems.append(RegionToMonitor(coordinate: regionCoordinate, radius: 50, identifier: identifier))
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
        
        //-- Create monitoring regions
        for regionToMonitorItem in self.regionToMonitorItems {
            if locationManager.monitoredRegions.count <= 20 {
                startMonitoringRegion(regionToMonitorItem)
            }
        }

    }
    
    //-- Method called when we start updating the location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //-- Get Value for key inside_region & george_clooney_inside
        let insideRegion = userDefault.boolForKey("inside_region")
        let georgeClooneyInside = userDefault.boolForKey("george_clooney_inside")
        
        //-- Get Location
        for (var i : Int = 0; i < locations.count; i++) {
            let newLocation : CLLocation? = locations[i] as CLLocation
            self.latitude = newLocation!.coordinate.latitude
            self.longitude = newLocation!.coordinate.longitude
        }
        
        //-- Check if user is region inside and place outside
        if insideRegion && !georgeClooneyInside {
            
            //-- We stop the updating location
            locationManager.stopUpdatingLocation()
            
            //-- We check if user is within place
            checkUserIsWithinPlace()
            
            //-- We set the new value for key george_clooney_inside
            userDefault.setBool(userWithinPlace, forKey: "george_clooney_inside")
        
        //-- Else we create regions
        } else {
            print("Object before monitoring \(self.locationManager.monitoredRegions.count)")
            createRegion()
            print("Object monitored \(self.locationManager.monitoredRegions.count)")
        }
        
    }
    
    //-- Method called when the location update failed
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    //-- Method trigger when the region monitoring start correctly
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "DidStartMonitoringForRegion"
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        print("DidStartMonitoringForRegion")
        print(region.identifier)
        
        locationManager.requestStateForRegion(region)
    }
    
    //-- Method for determine the state of each region. Trigger by "locationManager.requestStateForRegion(region)"
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        //print("didDetermineState \(state)");
        
        switch state {
        case .Inside:
            let notification = UILocalNotification()
            notification.alertBody = "Inside"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            print("didDetermineState CLRegionState.Inside \(region.identifier)")
        case .Outside:
            let notification = UILocalNotification()
            notification.alertBody = "Outside"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        case .Unknown:
            let notification = UILocalNotification()
            notification.alertBody = "Unknown"
            notification.soundName = "Default"
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            print("didDetermineState CLRegionState.Unknown")
        }
    }
    
    //-- Method for print errors during the region saving
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Error Monitoring")
        print(region?.identifier)
        print(error.description)
    }
    
    func timerWithStartUpdating() {
        
        //-- We get the bool for key george_clooney_inside
        let georgeClooneyInside = userDefault.boolForKey("george_clooney_inside")
        
        //-- If george is place outside we start updating location and we create an alarm until george is outside
        if !georgeClooneyInside {
            locationManager.startUpdatingLocation()
            let timerWithStartUpdating : Selector = "timerWithStartUpdating"
            NSTimer.scheduledTimerWithTimeInterval(60*5, target: self, selector: timerWithStartUpdating, userInfo: nil, repeats: false)
        }
    }
    
    //-- Method called when the user did enter in the region
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        let notification = UILocalNotification()
        notification.alertBody = "Did Enter Region"
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        //-- We stop monitoring for significant location changes
        locationManager.stopMonitoringSignificantLocationChanges()
        
        //-- We set true for key inside_region
        userDefault.setBool(true, forKey: "inside_region")
        
        //-- Sync the NSUserDefault
        userDefault.synchronize()
        
        //-- We create a updating location timer
        timerWithStartUpdating()
        
    }
    
    //-- Method called when the user did exit in the region
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "Did Exit Region"
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        //-- We stop updating location
        locationManager.stopUpdatingLocation()
        
        //-- We set false for key inside_region
        userDefault.setBool(false, forKey: "inside_region")
        
        //-- We set false for key george_clooney_inside
        userDefault.setBool(false, forKey: "george_clooney_inside")
        
        //-- Sync the new keys
        userDefault.synchronize()
        
        //-- We restart monitoring location changes for refresh regions
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    //-- Method for delete regions
    func stopMonitoringRegion() {
        
        //-- Foreach region already monitored we delete it
        for regionMonitored in self.locationManager.monitoredRegions {
            if let circularRegion = regionMonitored as? CLCircularRegion {
                self.locationManager.stopMonitoringForRegion(circularRegion)
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
}
