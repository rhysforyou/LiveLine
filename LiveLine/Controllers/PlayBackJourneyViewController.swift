//
//  PlayBackJourneyViewController.swift
//  LiveLine
//
//  Created by Rhys Powell on 10/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PlayBackJourneyViewController: UIViewController, MKMapViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var journey: Journey? = nil
    var photoIndex: Int = 0

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "embedPhotos") {
            if let pageController = segue.destinationViewController as? UIPageViewController {
                // TODO: Figure out why I can't do this in the storyboard
                pageController.delegate = self
                pageController.dataSource = self
                
                
                var controllers: [AnyObject] = []
                if let startingController = viewControllerForIndex(0) {
                    controllers.append(startingController)
                }
                pageController.setViewControllers(controllers, direction: .Forward, animated: false, completion: nil)
            }
        }
    }

    // MARK: - Page View Data Source
    
    func viewControllerForIndex(index: Int) -> UIViewController? {
        let viewController: UIViewController? = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as UIViewController?
        return viewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = photoIndex
        photoIndex--
        return viewControllerForIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = photoIndex
        photoIndex++
        return viewControllerForIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return journey?.photos.count ?? 5
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return photoIndex
    }
}
