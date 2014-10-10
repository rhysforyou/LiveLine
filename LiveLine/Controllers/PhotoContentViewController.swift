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

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = photo?.image
    }

}
