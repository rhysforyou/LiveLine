//
//  RecordJourneyViewController.swift
//  LiveLine
//
//  Created by Rhys Powell on 8/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class RecordJourneyViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var locationManager = CLLocationManager()
    var recording: Bool = false
    var activeJourney: Journey? = nil
    var polyline: MKPolyline? = nil
    
    var oldToolbarItems: [AnyObject]?
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext? = nil
    
    // Subviews
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recordingIndicator: UIImageView!
    
    // MARK: - View Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLocationPermissions()
    }
    
    func checkLocationPermissions() {
        switch (CLLocationManager.authorizationStatus()) {
        case .Denied, .Restricted:
            displayDialog("Location Monitoring Disabled", message: "LiveLine needs location services to work. Please quit the app and enable them in System Settings → Privacy → Location Services → LiveLine.")
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
            checkLocationPermissions()
        case .Authorized:
            println("Location monitoring enabled always")

        case .AuthorizedWhenInUse:
            println("Location monitoring enabled while in-use")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    // MARK: -
    
    func startLocationMonitoring() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 20
        locationManager.startUpdatingLocation()
    }
    
    func beginRecording() {
        if let context = self.managedObjectContext {
            activeJourney = NSEntityDescription.insertNewObjectForEntityForName("Journey", inManagedObjectContext: context) as? Journey
        }
        
        if (activeJourney != nil) {
            recording = true
        } else {
            println("Unable to create a new Journey instance")
        }
        
        // EXTRACT: Change the toolbar appearance
        self.navigationController?.toolbar.barTintColor = UIColor.redColor()
        self.navigationController?.toolbar.tintColor = UIColor.whiteColor()
        oldToolbarItems = self.toolbarItems
        self.toolbarItems = [
            UIBarButtonItem(image: UIImage(named: "note_icon"), landscapeImagePhone: UIImage(named: "stop_icon"), style: .Plain, target: self, action: Selector("toggleRecording:")),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: Selector("")),
            UIBarButtonItem(image: UIImage(named: "stop_icon"), landscapeImagePhone: UIImage(named: "stop_icon"), style: .Plain, target: self, action: Selector("toggleRecording:")),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: Selector("")),
            UIBarButtonItem(image: UIImage(named: "camera_icon"), landscapeImagePhone: UIImage(named: "stop_icon"), style: .Plain, target: self, action: Selector("takePhoto:"))
        ]
    }
    
    // MARK: - Map Updating
    
    func didAddCoordinate(coordinate: Coordinate) {
        let coordinates = activeJourney?.coordinates.map() { (coordinate: Coordinate) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        if let polylinePoints = coordinates {
            let oldPolyline = polyline
            polyline = MKPolyline(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>(polylinePoints), count: polylinePoints.count)
            self.mapView.addOverlay(polyline)
            if (oldPolyline != nil) {
                mapView.removeOverlay(oldPolyline)
            }
        }
    }
    
    func didAddPhoto(photo: Photo) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = photo.location.locationCoordinate2D
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Interface Actions
    
    @IBAction func toggleRecording(sender: UIBarButtonItem) {
        if (!recording) {
            startLocationMonitoring()
            beginRecording()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .Follow
        } else {
            activeJourney?.title = "Untitled"
            activeJourney?.timestamp = NSDate()
            var error: NSError? = nil
            if (managedObjectContext != nil && !managedObjectContext!.save(&error)) {
                println("Error saving journey: \(error)")
            } else {
                activeJourney = nil
            }
            self.toolbarItems = oldToolbarItems
            recording = false
        }
    }
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera) == false) {
            println("Camera unavailable")
            return
        }
        
        let cameraUI = UIImagePickerController()
        cameraUI.sourceType = .Camera
        cameraUI.delegate = self
        self.presentViewController(cameraUI, animated: true, completion: nil)
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        for item in locations {
            if let location = item as? CLLocation {
                let coordinate = NSEntityDescription.insertNewObjectForEntityForName("Coordinate", inManagedObjectContext: self.managedObjectContext!) as Coordinate
                coordinate.latitude = location.coordinate.latitude
                coordinate.longitude = location.coordinate.longitude
                coordinate.timestamp = location.timestamp
                coordinate.journey = activeJourney
                didAddCoordinate(coordinate)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location updates failed: \(error)")
    }
    
    // MARK: - Map View Delegate
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.redColor()
            renderer.lineWidth = 3.0
            return renderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let point = annotation as? MKPointAnnotation {
            return MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PhotoPin")
        } else {
            return MKPinAnnotationView()
        }
    }
    
    // MARK: - Image Picker Delgate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if (activeJourney != nil && managedObjectContext != nil && activeJourney!.coordinates.count > 0) {
            let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: managedObjectContext!) as Photo
            
            photo.image = image
            photo.timestamp = NSDate()
            photo.journey = activeJourney!
            photo.location = activeJourney!.coordinates.last!
            
            didAddPhoto(photo)
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Utility
    
    func displayDialog(title: String?, message: String?, dismissable: Bool = true) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if (dismissable) {
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in })
            alertController.addAction(defaultAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
