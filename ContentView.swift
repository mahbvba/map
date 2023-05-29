import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    @State private var compassHeading: CLLocationDirection = 0.0

    var body: some View {
        VStack {
            TextField("Enter an address", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .foregroundColor(.blue)

            Button("Find address") {
                mapAPI.getLocation(address: text, delta: 0.5)
            }
            .padding()

            Map(coordinateRegion: $mapAPI.region, interactionModes: .all, showsUserLocation: true, annotationItems: mapAPI.locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Image(systemName: "mappin")
                        .foregroundColor(.blue)
                }
            }
            .ignoresSafeArea()
            .overlay(CompassView(heading: compassHeading))

            CompassReader { compassHeading in
                self.compassHeading = compassHeading
            }
        }
    }
}

struct CompassView: View {
    let heading: CLLocationDirection

    var body: some View {
        VStack {
            Spacer()
            Text("Compass Heading: \(Int(heading))°")
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .padding()
        }
    }
}

struct CompassReader: View {
    let onUpdate: (CLLocationDirection) -> Void

    init(onUpdate: @escaping (CLLocationDirection) -> Void) {
        self.onUpdate = onUpdate
    }

    var body: some View {
        EmptyView()
            .onAppear {
                startUpdatingHeading()
            }
            .onDisappear {
                stopUpdatingHeading()
            }
    }

    func startUpdatingHeading() {
        guard CLLocationManager.headingAvailable() else { return }
        let locationManager = CLLocationManager()
        locationManager.startUpdatingHeading()

        let delegate = Delegate(onUpdate: onUpdate)
        locationManager.delegate = delegate
    }

    func stopUpdatingHeading() {
        let locationManager = CLLocationManager()
        locationManager.stopUpdatingHeading()
    }

    class Delegate: NSObject, CLLocationManagerDelegate {
        let onUpdate: (CLLocationDirection) -> Void

        init(onUpdate: @escaping (CLLocationDirection) -> Void) {
            self.onUpdate = onUpdate
        }

        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            let magneticHeading = newHeading.magneticHeading
            onUpdate(magneticHeading >= 0 ? magneticHeading : 360 + magneticHeading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


