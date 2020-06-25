//

import CoreLocation
import Foundation
import MapKit

public extension FileManager {
    static func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func cacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    static func fileURL(name: String, inCache: Bool = false) -> URL {
        if inCache {
            return self.cacheDirectory().appendingPathComponent(name)
        } else {
            return self.documentsDirectory().appendingPathComponent(name)
        }
    }
}

#if os(iOS)

public extension CLLocationCoordinate2D {
    
    static func clearCachedImages() {
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: FileManager.fileURL(name: "maps", inCache: true))

    }
    
    
    func mkMapImage(
        radius: Double = 500,
        size: CGSize = CGSize(width: 600, height: 400),
        mapType: MKMapType = .satelliteFlyover,
        closure: @escaping (UIImage) -> ()) {
        let darkMode: Bool = UIScreen.main.traitCollection.userInterfaceStyle == .dark

        try? FileManager.default.createDirectory(at: FileManager.fileURL(name: "maps", inCache: true), withIntermediateDirectories: true, attributes: nil)
        let imageName = "\(self.latitude.latitudeString) \(self.longitude.longitudeString)  r\(Int(radius)) s\(Int(size.width)) \(Int(size.height))  \(darkMode ? "d" : "l")"
        let fileUrl = FileManager.fileURL(name: "maps/\(imageName)", inCache: true)

        if FileManager.default.fileExists(atPath: fileUrl.path),
            let image = UIImage(contentsOfFile: fileUrl.path) {
            closure(image)
            return
        } else {
            self.screenshot(radius: radius, size: size, mapType: mapType) { image in
                if let image = image {
                    if let data = image.jpegData(compressionQuality: 0.9) {
                        try? data.write(to: fileUrl)
                    }

                    closure(image)
                }
            }
        }
    }

    func screenshot(radius meter: Double, size: CGSize = CGSize(width: 300, height: 300), mapType: MKMapType = .satellite, closure: @escaping (UIImage?) -> ()) {
        let mapSnapshotOptions = MKMapSnapshotter.Options()

        // Set the region of the map that is rendered.
        let location = self // Apple HQ
        let region = MKCoordinateRegion(center: location, latitudinalMeters: meter, longitudinalMeters: meter)
        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
//        let camera = MKMapCamera(lookingAtCenter: self, fromDistance: 1000, pitch: 400, heading: 0)
//        mapSnapshotOptions.camera = camera

        mapSnapshotOptions.traitCollection = UIScreen.main.traitCollection


        // Set the size of the image output.
        mapSnapshotOptions.size = size

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [])
        mapSnapshotOptions.mapType = mapType
//        mapSnapshotOptions.showsPointsOfInterest = true

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start(with: .main, completionHandler: { snapshot, _ in
            closure(snapshot?.image)
        })
    }
}
#endif
