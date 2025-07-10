//
//  LocationManager.swift
//  AdventureApp
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2023 YourCompany. All rights reserved.
//

import Foundation
import CoreLocation // Import CoreLocation framework for location services

// CLLocationManagerDelegate is used to receive updates from the Core Location framework.
// ObservableObject allows this class to be observed by SwiftUI views using @StateObject or @ObservedObject.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // CLLocationManager is the primary object that you use to start and stop the delivery of location-related events.
    private let locationManager = CLLocationManager()

    // @Published properties automatically announce when they change, triggering SwiftUI view updates.
    @Published var authorizationStatus: CLAuthorizationStatus? // Current authorization status (e.g., authorized, denied, notDetermined)
    @Published var lastKnownLocation: CLLocation? // The most recently reported location.

    override init() {
        super.init()
        // Set the delegate to this class to receive location manager callbacks.
        locationManager.delegate = self
        // Set the desired accuracy of location data. kCLLocationAccuracyBest is highest accuracy.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Set the distance filter to indicate how far the device must move before an update event is generated.
        // A value of kCLDistanceFilterNone (0) sends updates regardless of distance.
        locationManager.distanceFilter = kCLDistanceFilterNone
        // Fetch the initial authorization status
        fetchLocationStatus()
    }

    // MARK: - Permission Request
    // This method is called to request "When In Use" location authorization from the user.
    func requestLocationPermission() {
        // requestWhenInUseAuthorization is suitable for apps that use location services only when the app is in use.
        // This will present a system alert to the user.
        locationManager.requestWhenInUseAuthorization()
    }

    // This method fetches and updates the current location authorization status.
    func fetchLocationStatus() {
        authorizationStatus = locationManager.authorizationStatus // Update the published status.
    }


    // MARK: - CLLocationManagerDelegate Methods

    // This delegate method is called when the app's authorization status for location services changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus // Update the published status.

        // Perform actions based on the new authorization status.
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // If authorized, start updating location.
            // Note: For actual location usage, you'd typically start/stop updates based on app needs.
            // For permission demo, simply starting here.
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // Location access denied or restricted. Handle accordingly (e.g., show an alert).
            manager.stopUpdatingLocation() // Stop updating if denied
        case .notDetermined:
            // Authorization status is not yet determined, typically on first launch before user responds.
            break
        @unknown default:
            // Handle future cases not known at the time of compilation.
            break
        }
    }

    // This delegate method is called when new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get the most recent location from the array.
        guard let location = locations.last else { return }
        lastKnownLocation = location // Update the published last known location.
        // In a real app, you might process this location or stop updates if only one update is needed.
        // manager.stopUpdatingLocation() // Uncomment if you only need a single update.
    }

    // This delegate method is called when the location manager encounters an error.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                // User denied location access.
                break
            case .locationUnknown:
                // Location data is currently unavailable.
                break
            default:
                break
            }
        } else {
        }
    }
}

