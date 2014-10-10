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
    
    @IBOutlet weak var mapView: MKMapView!
    weak var pageController: UIPageViewController? = nil
    
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
                }
            }
        }
    }
    
    func addJourneyPathToMap() {
        let locationCoordinates: [CLLocationCoordinate2D] = journey?.coordinatesArray.map() { $0.locationCoordinate2D } ?? []
        journeyPolyline = MKPolyline(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>(locationCoordinates), count: locationCoordinates.count)
        mapView.addOverlay(journeyPolyline)
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
            annotationView.image = UIImage(named: "photo_pin")
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let photoMarker = view.annotation as MKPointAnnotation
        if let index = find(photoMarkers, photoMarker) {
            scrollToPageAtIndex(index)
        }
    }
}
