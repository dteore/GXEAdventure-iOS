import Foundation
import CoreLocation

class GeocodingService {
    private let geocoder = CLGeocoder()

    func geocodeAddress(_ address: String) async -> CLLocationCoordinate2D? {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            return placemarks.first?.location?.coordinate
        } catch {
            print("Geocoding error: \(error)")
            return nil
        }
    }
}
