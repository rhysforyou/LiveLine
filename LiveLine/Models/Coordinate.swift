//
//  Coordinate.swift
//  LiveLine
//
//  Created by Rhys Powell on 8/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Coordinate: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var journey: Journey?
    @NSManaged var photo: Photo?
    
    var locationCoordinate2D: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        }
    }
}
