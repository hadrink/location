//
//  ViewController.swift
//  testlocation
//
//  Created by Rplay on 22/02/16.
//  Copyright © 2016 had. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
        self.placeManager.locationManager.startMonitoringSignificantLocationChanges()
    }

}

