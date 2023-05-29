import Foundation
import MapKit

// Address Data Model
struct Address: Codable {
    let data: [Datum]
}

struct Datum: Codable {
    let latitude, longitude: Double
    let name: String?
}

// Our Pin Locations
struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

class MapAPI: ObservableObject {
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "Enter your own API_KEY"
    
    @Published var region: MKCoordinateRegion
    @Published var coordinates: [Double] = []
    @Published var locations: [Location] = []
    
    init() {
        // Default Info
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
        
        self.locations.insert(Location(name: "Pin", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)), at: 0)
    }
    
    // API request
    func getLocation(address: String, delta: Double) {
        let pAddress = address.replacingOccurrences(of: " ", with: "%20")
        let urlString = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            guard let newCoordinates = try? JSONDecoder().decode(Address.self, from: data) else {
                print("Failed to decode data")
                return
            }
            
            if newCoordinates.data.isEmpty {
                print("Could not find address...")
                return
            }
            
            // Set the new data
            DispatchQueue.main.async {
                let details = newCoordinates.data[0]
                let lat = details.latitude
                let lon = details.longitude
                
                self.coordinates = [lat, lon]
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                
                let newLocation = Location(name: details.name ?? "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                self.locations.removeAll()
                self.locations.insert(newLocation, at: 0)
                
                print("Successfully loaded location! \(details.name ?? "")")
            }
        }.resume()
    }
}
