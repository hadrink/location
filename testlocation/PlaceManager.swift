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
    var regionToMonitorItems = [RegionToMonitor]()
    let callRegion = CallRegion()
    let locationManager = CLLocationManager()
    
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func startMonitoringRegion(regionToMonitor: RegionToMonitor) {
        if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            return
        }
        
        let region = circularRegion(regionToMonitor)
        locationManager.startMonitoringForRegion(region)
    }
    
    func circularRegion(geotification: RegionToMonitor) -> CLCircularRegion {
        
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
        
    }
    
    //-- Call Region
    func createRegion() {
        
        if locationManager.monitoredRegions.count != 0 {
            stopMonitoringRegion()
            regionToMonitorItems.removeAll()
        }
        
        //-- Call region and append regionToMonitorItems
        callRegion.sendForRegion("https://hadrink.herokuapp.com/closeplaces/places/\(latitude)/\(longitude)/10000/", f: {(result: NSDictionary) -> () in
            
            
            if let regionItems = result["listbar"] as? [NSDictionary]  {
                
                for regionItem in regionItems {
                    if var placeProperties = regionItem["properties"] as? [String:AnyObject] {
                        
                        if (placeProperties["name"] != nil) {
                            
                            if var placeLocation = regionItem["loc"] as? [String:AnyObject] {
                                
                                let identifier = NSUUID().UUIDString
                                
                                let placeCoordinate = placeLocation["coordinates"]! as? NSArray
                                
                                let placeLongitude = placeCoordinate!.firstObject as! NSObject
                                let placeLatitude = placeCoordinate!.lastObject as! NSObject
                                
                                let placeLatitudeDegrees = placeLatitude as? Double
                                let placeLongitudeDegrees = placeLongitude as? Double
                                
                                let regionCoordinate = CLLocationCoordinate2D(latitude: placeLatitudeDegrees!, longitude: placeLongitudeDegrees!)
                                
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = true
        
        for (var i : Int = 0; i < locations.count; i++) {
            let newLocation : CLLocation? = locations[i] as CLLocation
            
            print(newLocation?.coordinate.latitude)
            self.latitude = newLocation!.coordinate.latitude
            self.longitude = newLocation!.coordinate.longitude
        }
        
        print("Object before monitoring \(self.locationManager.monitoredRegions.count)")
        
        createRegion()
        
        print("Object monitored \(self.locationManager.monitoredRegions.count)")
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "DidStartMonitoringForRegion"
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        print("DidStartMonitoringForRegion")
        print(region.identifier)
        
        //locationManager.requestStateForRegion(region)
    }
    
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
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Error Monitoring")
        print(region?.identifier)
        
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        let notification = UILocalNotification()
        notification.alertBody = "Did Enter Region"
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        let notification = UILocalNotification()
        notification.alertBody = "Did Exit Region"
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
    }
    
    func stopMonitoringRegion() {

        for regionMonitored in self.locationManager.monitoredRegions {
            if let circularRegion = regionMonitored as? CLCircularRegion {
                self.locationManager.stopMonitoringForRegion(circularRegion)
            }
        }

    }
}
