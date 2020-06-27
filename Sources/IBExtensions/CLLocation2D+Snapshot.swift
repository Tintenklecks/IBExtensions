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
        size: CGSize = CGSize(width: 600, height: 400),
        mapType: MKMapType = .satelliteFlyover,
        closure: @escaping (UIImage) -> ()) {
        let darkMode: Bool = UIScreen.main.traitCollection.userInterfaceStyle == .dark

        try? FileManager.default.createDirectory(at: FileManager.fileURL(name: "maps", inCache: true), withIntermediateDirectories: true, attributes: nil)
        let imageName = "\(self.latitude.latitudeString) \(self.longitude.longitudeString)  s\(Int(size.width)) \(Int(size.height))  \(darkMode ? "d" : "l")"
        let fileUrl = FileManager.fileURL(name: "maps/\(imageName)", inCache: true)

        if FileManager.default.fileExists(atPath: fileUrl.path),
            let image = UIImage(contentsOfFile: fileUrl.path) {
            closure(image)
            return
        } else {
            self.screenshot(size: size, mapType: mapType) { image in
                if let image = image {
                    if let data = image.jpegData(compressionQuality: 0.9) {
                        try? data.write(to: fileUrl)
                    }

                    closure(image)
                }
            }
        }
    }

    func screenshot(altitude: Double = 100, pitch: CGFloat = 45, size: CGSize = CGSize(width: 300, height: 300), mapType: MKMapType = .satelliteFlyover, closure: @escaping (UIImage?) -> ()) {
        let mapSnapshotOptions = MKMapSnapshotter.Options()

        // Set the region of the map that is rendered.
//        let location = self // Apple HQ
//        let region = MKCoordinateRegion(center: location, latitudinalMeters: 0 , longitudinalMeters: 0)
//        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

//        let userCoordinate = self
//        let eyeCoordinate = self.shift(by: CGPoint(x: 0, y: 0.005))
        // let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 500) // altitude)
//        let mapCamera = MKMapCamera(lookingAtCenter: self, fromDistance: altitude, pitch: pitch, heading: 0)
        let mapCamera = MKMapCamera(lookingAtCenter: self, fromDistance: 1000, pitch: 15, heading: 0)

        mapSnapshotOptions.camera = mapCamera

        mapSnapshotOptions.traitCollection = UIScreen.main.traitCollection

        // Set the size of the image output.
        mapSnapshotOptions.size = size

        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [])
        mapSnapshotOptions.mapType = mapType

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)

        snapShotter.start(with: .main, completionHandler: { snapshot, _ in

            if let snapshot = snapshot {
                let image = UIGraphicsImageRenderer(size: mapSnapshotOptions.size).image { _ in
                    snapshot.image.draw(at: .zero)

                    if let pinImage = UIImage(systemName: "arrow.down.left")?.withTintColor(.white) { // UIImage(named: "positionMarker") {
                        var point = snapshot.point(for: self)

                        if CGRect(origin: .zero, size: mapSnapshotOptions.size).contains(point) {
//                            point.x -= pinImage.size.width / 2
//                            point.y -= pinImage.size.height / 2
//                            point.x -= pinImage.size.width / 2
                            point.y -= pinImage.size.height 
                            pinImage.draw(at: point)
                        }
                    }
                }

                closure(image)

//                var dict: [String: Int] = [:]
//                for _ in 0...100 {
//                    if let hex = image.randomPixelColor().toHex() {
//                        if let count = dict[hex] {
//                            dict[hex] = count + 1
//                        } else {
//                            dict[hex] = 1
//                        }
//                    }
//                }
//                for (_, value) in dict {
//                    if value > 80 {
//                        if altitude < 1000 {
//                            self.screenshot(altitude: altitude + 100, pitch: pitch / 3 * 2, size: size, mapType: mapType, closure: closure)
//                        } else {
//                            closure(nil)
//                        }
//                        return
//                    }
//                }
//                print("***",location.latitude.latitudeString, location.longitude.longitudeString, altitude, pitch)
                //               closure(image)
            }
        })
    }
}
#endif
