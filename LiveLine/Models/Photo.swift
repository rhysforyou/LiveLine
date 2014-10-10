//
//  Photo.swift
//  LiveLine
//
//  Created by Rhys Powell on 8/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

    @NSManaged var caption: String?
    @NSManaged var imageData: NSData
    @NSManaged var timestamp: NSDate
    @NSManaged var location: Coordinate
    @NSManaged var journey: Journey
    
    var image: UIImage {
        get {
            return UIImage(data: imageData)
        }
        set(newImage) {
            imageData = UIImagePNGRepresentation(newImage)
        }
    }

}
