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
            print("Location monitoring disabled")
        case .NotDetermined:
            locationManager?.requestAlwaysAuthorization()
            locationManager?.startUpdatingLocation()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .Follow
        case .Authorized:
            print("Location monitoring enabled always")
        case .AuthorizedWhenInUse:
            print("Location monitoring enabled while in-use")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    @IBAction func beginRecording(sender: UIBarButtonItem) {
        print("Recording");
    }
}
