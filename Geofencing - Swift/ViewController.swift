//
//  ViewController.swift
//  Geofencing - Swift
//
//  Created by Kaytee on 3/15/17.
//  Copyright © 2017 Kaytee. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    // Initialize location manager
    let locationManager = CLLocationManager()
    var geofencesArray = [CLCircularRegion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the location manager delegate
        self.locationManager.delegate = self;
        
        // Request always authorization is required to monitor geofences
        self.locationManager.requestAlwaysAuthorization()
        
        // Instantiate geofences
        self.configureGeofences();
    }
    
    func configureGeofences() {
        
        let canvsGeofence = CLCircularRegion(center: CLLocationCoordinate2DMake(28.540342, -81.381518), radius: 100, identifier: "canvs")
        
        let guamGeofence = CLCircularRegion(center: CLLocationCoordinate2DMake(13.4443, 144.7937), radius: 100, identifier: "guam")
        
        geofencesArray = [canvsGeofence, guamGeofence]
        
        // Start monitoring geofences; up to 20 can be monitored at one time
        self.startMonitoring(geofences: geofencesArray)
    }
    
    func startMonitoring(geofences: [CLCircularRegion]) {
        
        for geofence in geofences {
            self.locationManager.startMonitoring(for: geofence)
        }
    }
    
    
    // MARK: Location Manager Delegate Functions
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Start updating location after user authorizes location services
        if status == .authorizedAlways { self.locationManager.startUpdatingLocation() }
        
        if status ==  .denied { self.presentLocationServicesDeniedAlert() }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Monitoring \(region.description)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error \(error)")
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Did Enter \(region.description)")
        
        view.backgroundColor = UIColor.red
        self.presentWelcomeAlert()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Did Exit \(region.description)")
        view.backgroundColor = UIColor.blue
        self.presentGoodbyeAlert()
    }
    
    
    // MARK: Already inside geofence
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let currentLocation = locations.last {
            
            let radius = CLLocationDistance(100)
            
            let currentRegion = CLCircularRegion(center: currentLocation.coordinate, radius: radius, identifier: "currentRegion")
            
            for geofenceLocation in geofencesArray {
                
                if currentRegion.contains(geofenceLocation.center) {
                    view.backgroundColor = UIColor.red
                    self.presentWelcomeAlert()
                    
                    // Stop updating to prevent looping behavior
                    self.locationManager.stopUpdatingLocation()
                    
                    // You can call startUpdatingLocation again later, but it is not necessary
                    
                }
            }
        }
    }
    
    // MARK: Alerts
    
    func presentWelcomeAlert() {
        let alertController = UIAlertController(title: "Welcome!", message: "You have entered a geofence", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: {
        })
        
    }
    
    func presentGoodbyeAlert() {
        let alertController = UIAlertController(title: "Goodbye!", message: "You have exited a geofence", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: {
        })
    }
    
    // MARK: User denies location services
    
    func presentLocationServicesDeniedAlert () {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "Location services are required for geofencing. Go to app settings to turn location service on.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        let goToSettingsAction = UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString) as! URL
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        })
        
        alertController.addAction(okAction)
        alertController.addAction(goToSettingsAction)
        
        self.present(alertController, animated: true, completion: {
        })
        
    }
}

