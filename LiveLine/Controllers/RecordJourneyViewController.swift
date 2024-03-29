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
    @IBOutlet weak var userTrackingButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.toolbar.barStyle = UIBarStyle.Default
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        recordingIndicator.hidden = !recording
    }
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showHistory") {
            if let pastJourneysController = segue.destinationViewController as? PastJourneysViewController {
                pastJourneysController.managedObjectContext = managedObjectContext
            }
        }
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
        self.navigationController?.toolbar.barTintColor = UIColor.liveLineRedColor()
        self.navigationController?.toolbar.tintColor = UIColor.liveLineWhiteColor()
        oldToolbarItems = self.toolbarItems
        self.toolbarItems = [
            UIBarButtonItem(image: UIImage(named: "settings_icon"), landscapeImagePhone: UIImage(named: "settings_icon"), style: .Plain, target: self, action: Selector("showAbout:")),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: Selector("")),
            UIBarButtonItem(image: UIImage(named: "stop_icon"), landscapeImagePhone: UIImage(named: "stop_icon"), style: .Plain, target: self, action: Selector("toggleRecording:")),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: Selector("")),
            UIBarButtonItem(image: UIImage(named: "camera_icon"), landscapeImagePhone: UIImage(named: "camera_icon"), style: .Plain, target: self, action: Selector("takePhoto:"))
        ]
    }
    
    // MARK: - Map Updating
    
    func didAddCoordinate(coordinate: Coordinate) {
        let coordinates = activeJourney?.coordinatesArray.map() { (coordinate: Coordinate) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(
                latitude: coordinate.latitude.doubleValue,
                longitude: coordinate.longitude.doubleValue
            )
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
            activeJourney?.sumDistances()
            
            let titleInputAlert = UIAlertController(title: "Title", message: "Enter a title for the journey", preferredStyle: .Alert)
            titleInputAlert.addTextFieldWithConfigurationHandler() {
                $0.autocapitalizationType = .Sentences
                $0.placeholder = "Title"
            }
            titleInputAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                if let titleTextField = titleInputAlert.textFields?.first as? UITextField {
                    self.activeJourney?.title = titleTextField.text
                }
                
                var error: NSError? = nil
                if (self.managedObjectContext != nil && !self.managedObjectContext!.save(&error)) {
                    println("Error saving journey: \(error)")
                } else {
                    self.activeJourney = nil
                }
                
                self.toolbarItems = self.oldToolbarItems
                self.navigationController?.toolbar.barTintColor = UIColor.liveLineWhiteColor()
                self.navigationController?.toolbar.tintColor = UIColor.liveLineRedColor()
                
                self.recording = false
            }))
            
            presentViewController(titleInputAlert, animated: true, completion: nil)
        }
        
        recordingIndicator.hidden = !recording
    }
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera) == false) {
            println("Camera unavailable")
            return
        }
        
        let cameraUI = UIImagePickerController()
        cameraUI.sourceType = .Camera
        cameraUI.allowsEditing = true
        cameraUI.delegate = self
        presentViewController(cameraUI, animated: true, completion: nil)
    }
    
    @IBAction func trackUser(sender: UIButton) {
        if (mapView.userTrackingMode == .Follow) {
            mapView.setUserTrackingMode(.None, animated: true)
            userTrackingButton.setImage(UIImage(named: "location_button_disabled"), forState: .Normal)
            userTrackingButton.setImage(UIImage(named: "location_button_enabled"), forState: .Highlighted)
        } else {
            mapView.setUserTrackingMode(.Follow, animated: true)
            userTrackingButton.setImage(UIImage(named: "location_button_enabled"), forState: .Normal)
            userTrackingButton.setImage(UIImage(named: "location_butto_disabledn"), forState: .Highlighted)
        }
    }
    
    @IBAction func showAbout(sender: AnyObject) {
        self.performSegueWithIdentifier("showAbout", sender: self)
    }
    
    @IBAction func unwindFromAbout(segue: UIStoryboardSegue) {
        
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
        } else if let userLocation = annotation as? MKUserLocation {
            return nil
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        switch(mode) {
        case .Follow, .FollowWithHeading:
            userTrackingButton.setImage(UIImage(named: "location_button_enabled"), forState: .Normal)
            userTrackingButton.setImage(UIImage(named: "location_butto_disabledn"), forState: .Highlighted)
        case .None:
            userTrackingButton.setImage(UIImage(named: "location_button_disabled"), forState: .Normal)
            userTrackingButton.setImage(UIImage(named: "location_button_enabled"), forState: .Highlighted)
        }
    }
    
    // MARK: - Image Picker Delgate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if (activeJourney != nil && managedObjectContext != nil && activeJourney!.coordinates.count > 0) {
            let photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: managedObjectContext!) as Photo
            
            photo.image = image
            photo.timestamp = NSDate()
            photo.journey = activeJourney!
            photo.location = activeJourney!.coordinates.lastObject as Coordinate
            
            let captionAlert = UIAlertController(title: "Photo Caption", message: "Add a caption to the photo", preferredStyle: .Alert)
            captionAlert.addTextFieldWithConfigurationHandler({ (textField: UITextField!) -> Void in
                textField.placeholder = "Caption"
                textField.autocapitalizationType = .Sentences
            })
            captionAlert.addAction(UIAlertAction(title: "Skip", style: .Cancel, handler: nil))
            captionAlert.addAction(UIAlertAction(title: "Add Caption", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                if let captionField = captionAlert.textFields?.first? as? UITextField {
                    photo.caption = captionField.text
                }
            }))
            
            picker.dismissViewControllerAnimated(true) { () -> Void in
                self.presentViewController(captionAlert, animated: true, completion: nil)
                self.didAddPhoto(photo)
            }
            
        }
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
