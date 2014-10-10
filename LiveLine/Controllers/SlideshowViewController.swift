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

        self.navigationController?.setToolbarHidden(false, animated: animated)
        self.navigationController?.toolbar.barStyle = .BlackTranslucent
        self.navigationController?.toolbar.barTintColor = nil
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        transitionCoordinator()?.animateAlongsideTransition({ context in
            self.navigationController?.navigationBar.barTintColor = nil
            return
        }, completion: nil)
    }
   
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        slideshowView.stop()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func stopSlideshow(sender: AnyObject) {
        slideshowView.stop()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    @IBAction func startSlideshow(sender: AnyObject) {
        slideshowView.start()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
}
