import SwiftUI
import CoreLocation
import CoreLocationUI
import MapKit

struct DelegateToContinuationsView: View {

    @StateObject
    private var locationManager = LocationManager()

    @State
    private var location = "N/A"

    @State
    private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        VStack {
            Text(location)
            
            Map(coordinateRegion: $region)
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .padding()

            LocationButton {
                Task {
                    if let location = try? await locationManager.requestLocation() {
                        region.center = location
                        self.location = "\(location)"
                    } else {
                        location = "Unknown Location"
                    }
                }
            }
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    DelegateToContinuationsView()
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations.first?.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
    }
    
    func requestLocation() async throws -> CLLocationCoordinate2D? {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }
}
