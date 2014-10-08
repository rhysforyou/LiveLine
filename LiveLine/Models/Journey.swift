//
//  LiveLine.swift
//  LiveLine
//
//  Created by Rhys Powell on 8/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import Foundation
import CoreData

class Journey: NSManagedObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var distance: NSNumber
    @NSManaged var title: String
    @NSManaged var coordinates: Array<Coordinate>
    @NSManaged var photos: Array<Photo>

}
