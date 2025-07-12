import XCTest
@testable import IBExtensions
import SwiftUI
import UIKit

final class IBExtensionsTests: XCTestCase {
    
    func testColorHexInitialization() {
        // Test valid hex colors
        let redColor = Color(hex: "#FF0000")
        let greenColor = Color(hex: "00FF00")
        let blueColor = Color(hex: "#0000FF")
        
        // Test invalid hex colors don't crash
        let invalidColor = Color(hex: "INVALID")
        XCTAssertNotNil(invalidColor)
        
        // Test empty hex string
        let emptyColor = Color(hex: "")
        XCTAssertNotNil(emptyColor)
    }
    
    func testDateExtensions() {
        let date = Date()
        
        // Test startOfDay
        let startOfDay = date.startOfDay
        XCTAssertNotNil(startOfDay)
        
        // Test date formatting
        let shortDate = date.shortDate
        XCTAssertFalse(shortDate.isEmpty)
        
        let longDate = date.longDate
        XCTAssertFalse(longDate.isEmpty)
    }
    
    func testStringDateExtensions() {
        // Test valid ISO8601 date
        let validISOString = "2023-12-25T10:30:00Z"
        let date = validISOString.iso8601Date
        XCTAssertNotNil(date)
        
        // Test invalid date string
        let invalidString = "not a date"
        let invalidDate = invalidString.iso8601Date
        XCTAssertNil(invalidDate)
        
        // Test sorted date format
        let sortedDateString = "2023-12-25"
        let sortedDate = sortedDateString.dateFromSortedDateFormat
        XCTAssertNotNil(sortedDate)
    }
    
    func testDoubleExtensions() {
        let testValue: Double = 123.456789
        
        // Test string formatting
        let formattedString = testValue.string(digits: 2)
        XCTAssertTrue(formattedString.contains("."))
        
        // Test time string
        let timeString = testValue.timeString()
        XCTAssertFalse(timeString.isEmpty)
    }
    
    func testFileManagerExtensions() {
        // Test document directory access
        let documentsURL = FileManager.documentsDirectory()
        XCTAssertNotNil(documentsURL)
        
        // Test cache directory access
        let cacheURL = FileManager.cacheDirectory()
        XCTAssertNotNil(cacheURL)
        
        // Test file URL creation
        let fileURL = FileManager.fileURL(name: "test.txt")
        XCTAssertEqual(fileURL.lastPathComponent, "test.txt")
    }
    
    func testImageExtensions() {
        // Test image creation and scaling
        let image = UIImage(systemName: "star") ?? UIImage()
        let scaledImage = image.resize(targetSize: CGSize(width: 50, height: 50))
        XCTAssertNotNil(scaledImage)
        
        // Test image rotation
        let rotatedImage = image.rotate(angle: 90)
        XCTAssertNotNil(rotatedImage)
    }

    static var allTests = [
        ("testColorHexInitialization", testColorHexInitialization),
        ("testDateExtensions", testDateExtensions),
        ("testStringDateExtensions", testStringDateExtensions),
        ("testDoubleExtensions", testDoubleExtensions),
        ("testFileManagerExtensions", testFileManagerExtensions),
        ("testImageExtensions", testImageExtensions),
    ]
}
