//
//  LiveLine.swift
//  LiveLine
//
//  Created by Rhys Powell on 9/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Journey: NSManagedObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var distance: NSNumber
    @NSManaged var title: String
    @NSManaged var coordinates: NSOrderedSet
    @NSManaged var photos: NSOrderedSet

    var coordinatesArray: [Coordinate] {
        get {
            return coordinates.array as [Coordinate]
        }
    }
    
    var photosArray: [Photo] {
        get {
            return photos.array as [Photo]
        }
    }
    
    func sumDistances() {
        let locations = coordinatesArray.map() { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        var lastLocation = locations.last
        var distance = 0
        
        for location in locations {
            distance += Int(location.distanceFromLocation(lastLocation!))
            lastLocation = location
        }
        
        self.distance = distance
    }
}
