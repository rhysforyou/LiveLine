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
import CoreLocation

class PlayBackJourneyViewController: UIViewController, MKMapViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var journey: Journey? = nil
    var journeyPolyline: MKPolyline? = nil
    var photoMarkers: [MKPointAnnotation] = []
    var selectedMarker: MKAnnotationView? = nil
    var nextPage: Int? = nil
    var hasAddedFirstMarker = false
    
    @IBOutlet weak var mapView: MKMapView!
    weak var pageController: UIPageViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Slideshow", style: .Plain, target: self, action: Selector("showSlideshow:"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addJourneyPathToMap()
        addPhotoMarkersToMap()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "embedPhotos") {
            if let pageController = segue.destinationViewController as? UIPageViewController {
                // TODO: Figure out why I can't do this in the storyboard
                pageController.delegate = self
                pageController.dataSource = self
                self.pageController = pageController
                
                if let startingController = viewControllerForIndex(0) {
                    pageController.setViewControllers([startingController], direction: .Forward, animated: false, completion: nil)
                } else {
                    let noContentView = storyboard?.instantiateViewControllerWithIdentifier("NoPhotoView") as UIViewController
                    pageController.setViewControllers([noContentView], direction: .Forward, animated: false, completion: nil)
                }
            }
        } else if (segue.identifier == "showSlideshow") {
            if let slideshowController = segue.destinationViewController as? SlideshowViewController {
                slideshowController.photos = journey?.photosArray ?? []
            }
        }
    }
    
    func addJourneyPathToMap() {
        let locationCoordinates: [CLLocationCoordinate2D] = journey?.coordinatesArray.map() { $0.locationCoordinate2D } ?? []
        journeyPolyline = MKPolyline(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>(locationCoordinates), count: locationCoordinates.count)
        mapView.addOverlay(journeyPolyline)
        
        let boundingRect = mapView.mapRectThatFits(journeyPolyline!.boundingMapRect)
        mapView.setVisibleMapRect(boundingRect, edgePadding: UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0), animated: true)
    }
    
    func addPhotoMarkersToMap() {
        let photoLocations: [CLLocationCoordinate2D] = journey?.photosArray.map() { $0.location.locationCoordinate2D } ?? []
        photoMarkers = photoLocations.map() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = $0
            self.mapView.addAnnotation(annotation)
            return annotation
        }
    }

    @IBAction func showSlideshow(sender: AnyObject) {
        self.performSegueWithIdentifier("showSlideshow", sender: self)
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
    
    func scrollToPageAtIndex(index: Int) {
        if let viewController = viewControllerForIndex(index) {
            pageController?.setViewControllers([viewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if (journey?.photos.count == 0) { return nil }
        
        let photoViewController = viewController as PhotoContentViewController
        let index = photoViewController.pageIndex
        
        if (index == NSNotFound || index <= 0) {
            return nil
        }
        
        return viewControllerForIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if (journey?.photos.count == 0) { return nil }
        
        let photoViewController = viewController as PhotoContentViewController
        let index = photoViewController.pageIndex
        
        if (index == NSNotFound || index + 1 >= journey?.photos.count) {
            return nil
        }
        
        return viewControllerForIndex(index + 1)
    }
    
    // MARK: - Page View Delegate
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        let photoController = pendingViewControllers.first? as PhotoContentViewController?
        nextPage = photoController?.pageIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if (completed && nextPage != nil) {
            mapView.setCenterCoordinate(photoMarkers[nextPage!].coordinate, animated: true)
            
            if let newMarker: MKAnnotationView = mapView.viewForAnnotation(photoMarkers[nextPage!]) {
                if let oldMarker = selectedMarker {
                    oldMarker.image = UIImage(named: "photo_pin")
                }
                
                selectedMarker = newMarker
                selectedMarker?.image = UIImage(named: "photo_pin_selected")
            }
        }
    }
    
    // MARK: - Map View Delegate
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.liveLineRedColor()
            renderer.lineWidth = 3.0
            return renderer
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let point = annotation as? MKPointAnnotation {
            let annotationView = MKAnnotationView(annotation: point, reuseIdentifier: "PhotoPin")
            if (hasAddedFirstMarker) {
                annotationView.image = UIImage(named: "photo_pin")
            } else {
                selectedMarker = annotationView
                selectedMarker?.image = UIImage(named: "photo_pin_selected")
                hasAddedFirstMarker = true
            }
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let photoMarker = view.annotation as MKPointAnnotation
        
        if let oldMarker = selectedMarker {
            oldMarker.image = UIImage(named: "photo_pin")
        }
        
        selectedMarker = view
        selectedMarker?.image = UIImage(named: "photo_pin_selected")
        
        mapView.setCenterCoordinate(photoMarker.coordinate, animated: true)
        
        if let index = find(photoMarkers, photoMarker) {
            scrollToPageAtIndex(index)
        }
    }
}
