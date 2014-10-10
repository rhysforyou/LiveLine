//
//  PhotoContentViewController.swift
//  LiveLine
//
//  Created by Rhys Powell on 10/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit

class PhotoContentViewController: UIViewController {
    
    var photo: Photo? = nil
    var pageIndex: Int = 0
    var timestampFormatter: NSDateFormatter? = nil

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timestampFormatter = NSDateFormatter()
        timestampFormatter?.dateStyle = .NoStyle
        timestampFormatter?.timeStyle = .ShortStyle
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let thePhoto = self.photo {
            imageView.image = thePhoto.image
            captionLabel.text = thePhoto.caption ?? "(no caption)"
            timestampLabel.text = timestampFormatter?.stringFromDate(thePhoto.timestamp) ?? "(no date)"
        }
    }

}
