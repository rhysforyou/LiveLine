//
//  RecordJourneyViewController.swift
//  LiveLine
//
//  Created by Rhys Powell on 8/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit
import MapKit

class RecordJourneyViewController: UIViewController {
    var locationManager: CLLocationManager?
    
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
            locationManager?.requestAlwaysAuthorization()
            checkLocationPermissions()
        case .Authorized:
            print("Location monitoring enabled always")
            locationManager?.startUpdatingLocation()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .Follow
        case .AuthorizedWhenInUse:
            print("Location monitoring enabled while in-use")
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
    
    @IBAction func beginRecording(sender: UIBarButtonItem) {
        print("Recording");
    }
}
