//
//  File.swift
//  
//
//  Created by Ingo Böhme on 26.07.20.
//

import Foundation

public extension FileManager {
    static func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsDirectory = paths.first else {
            // Fallback to temporary directory if documents directory is not accessible
            return FileManager.default.temporaryDirectory
        }
        return documentsDirectory
    }

    static func cacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheDirectory = paths.first else {
            // Fallback to temporary directory if cache directory is not accessible
            return FileManager.default.temporaryDirectory
        }
        return cacheDirectory
    }

    static func fileURL(name: String, inCache: Bool = false) -> URL {
        if inCache {
            return self.cacheDirectory().appendingPathComponent(name)
        } else {
            return self.documentsDirectory().appendingPathComponent(name)
        }
    }
}

