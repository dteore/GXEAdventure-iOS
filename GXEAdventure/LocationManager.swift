//
//  LocationManager.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    // Published properties will notify SwiftUI of any changes.
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var userLocation: CLLocation?
    @Published var deviceHeading: CLHeading?
    @Published var smoothedHeading: Double = 0.0

    override init() {
        super.init()
        manager.delegate = self
        // Set higher accuracy for navigation-style features.
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }

    /// Requests "When In Use" location permission from the user.
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Fetches the current authorization status.
    func fetchLocationStatus() {
        authorizationStatus = manager.authorizationStatus
    }
    
    /// Starts tracking the user's location and device heading.
    func startUpdating() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        print("Location Manager: Started location and heading updates.")
    }

    /// Stops tracking the user's location and device heading.
    func stopUpdating() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
        print("Location Manager: Stopped location and heading updates.")
    }

    // MARK: - CLLocationManagerDelegate Methods

    // FIX: Mark delegate methods as nonisolated and dispatch updates to the MainActor.
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            // Start or stop updating based on the new status.
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.startUpdating()
            } else {
                self.stopUpdating()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            // Update the user's location with the latest reading.
            self.userLocation = locations.last
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            self.deviceHeading = newHeading
            // Simple smoothing: average the last few readings or apply a low-pass filter
            // For a more robust solution, consider a proper low-pass filter or Kalman filter
            if self.smoothedHeading == 0.0 {
                self.smoothedHeading = newHeading.trueHeading
            } else {
                self.smoothedHeading = (self.smoothedHeading * 0.9) + (newHeading.trueHeading * 0.1)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Printing to the console is thread-safe.
        print("Location Manager failed with error: \(error.localizedDescription)")
    }
}

