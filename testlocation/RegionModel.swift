//
//  RegionModel.swift
//  testlocation
//
//  Created by Rplay on 22/02/16.
//  Copyright © 2016 had. All rights reserved.
//

import Foundation
import CoreLocation

class RegionToMonitor: NSObject {
    var coordinate:CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var distance : Double
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, distance: Double) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.distance = distance
    }
}
