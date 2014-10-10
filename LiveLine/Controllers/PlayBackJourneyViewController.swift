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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "embedPhotos") {
            if let pageController = segue.destinationViewController as? UIPageViewController {
                // TODO: Figure out why I can't do this in the storyboard
                pageController.delegate = self
                pageController.dataSource = self
                
                if let startingController = viewControllerForIndex(0) {
                    pageController.setViewControllers([startingController], direction: .Forward, animated: false, completion: nil)
                }
            }
        }
    }

    // MARK: - Page View Data Source
    
    func viewControllerForIndex(index: Int) -> UIViewController? {
        if (index >= journey?.photos.count) {
            return nil
        }
        
        let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as PhotoContentViewController?
        
        photoViewController?.photo = journey?.photos[index] as? Photo
        photoViewController?.pageIndex = index
        
        return photoViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let photoViewController = viewController as PhotoContentViewController
        let index = photoViewController.pageIndex
        
        if (index == NSNotFound || index <= 0) {
            return nil
        }
        
        return viewControllerForIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let photoViewController = viewController as PhotoContentViewController
        let index = photoViewController.pageIndex
        
        if (index == NSNotFound || index + 1 >= journey?.photos.count) {
            return nil
        }
        
        return viewControllerForIndex(index + 1)
    }
}
