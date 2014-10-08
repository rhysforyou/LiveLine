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

class RecordJourneyViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager = CLLocationManager()
    var recording: Bool = false
    var activeJourney: Journey? = nil
    
    // Core Data
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recordingIndicator: UIImageView!
    
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
    
    func displayDialog(title: String?, message: String?, dismissable: Bool = true) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if (dismissable) {
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in })
            alertController.addAction(defaultAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
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
    }
    
    @IBAction func toggleRecording(sender: UIBarButtonItem) {
        if (!recording) {
            startLocationMonitoring()
            beginRecording()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .Follow
        } else {
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        for item in locations {
            if let location = item as? CLLocation {
                let coordinate = NSEntityDescription.insertNewObjectForEntityForName("Coordinate", inManagedObjectContext: self.managedObjectContext!) as Coordinate
                coordinate.latitude = location.coordinate.latitude
                coordinate.longitude = location.coordinate.longitude
                coordinate.timestamp = location.timestamp
                coordinate.journey = activeJourney
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Location updates failed: \(error)")
    }
}
