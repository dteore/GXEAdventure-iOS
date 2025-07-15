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
    @Published var smoothedHeading: Double = 0.0 // NEW: Smoothed heading for stable UI

    // Factor for the low-pass filter. A higher value means more smoothing.
    private let smoothingFactor: Double = 0.9

    override init() {
        super.init()
        manager.delegate = self
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

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.startUpdating()
            } else {
                self.stopUpdating()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.userLocation = locations.last
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            self.deviceHeading = newHeading
            
            let currentHeading = newHeading.trueHeading
            
            // Apply a low-pass filter to smooth the heading value.
            // This averages the new value with the previous smoothed value.
            var newSmoothedHeading = self.smoothedHeading
            if abs(currentHeading - newSmoothedHeading) > 180 {
                if newSmoothedHeading < 180 {
                    newSmoothedHeading += 360
                } else {
                    newSmoothedHeading -= 360
                }
            }
            
            newSmoothedHeading = (newSmoothedHeading * self.smoothingFactor) + (currentHeading * (1.0 - self.smoothingFactor))
            
            // Ensure the heading stays within the 0-360 range.
            self.smoothedHeading = newSmoothedHeading.truncatingRemainder(dividingBy: 360)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
    }
}

