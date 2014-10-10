//
//  SlideshowViewController.swift
//  LiveLine
//
//  Created by Rhys Powell on 10/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit

class SlideshowViewController: UIViewController, KASlideShowDelegate {

    var photos: [Photo] = []
    
    @IBOutlet weak var slideshowView: KASlideShow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slideshowView.delay = 3
        slideshowView.transitionDuration = 0.5
        slideshowView.transitionType = .Fade
        slideshowView.imagesContentMode = .ScaleAspectFit
        slideshowView.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        slideshowView.images = NSMutableArray(array: photos.map() {
            $0.image
        })
        slideshowView.start()
    }
}
