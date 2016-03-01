//
//  ViewController.swift
//  testlocation
//
//  Created by Rplay on 22/02/16.
//  Copyright © 2016 had. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let placeManager = PlaceManager()
    //let locationManager = placeManager.locationManager

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createRegion(sender: UIButton) {
        placeManager.requestState()
        self.placeManager.locationManager.startUpdatingLocation()
    }

    @IBAction func displayRegion(sender: AnyObject) {
        //-- Foreach region already monitored we delete it
        for regionMonitored in self.placeManager.locationManager.monitoredRegions {
            if let circularRegion = regionMonitored as? CLCircularRegion {
                print(circularRegion.identifier)
            }
        }
    }
}

