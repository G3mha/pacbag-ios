import Foundation
import UIKit

class IconSetupManager {
    static let shared = IconSetupManager()
    
    private init() {}
    
    // MARK: - Icon Files Management
    
    func createIconsFromDownloadedFiles() {
        // Path to where icon.kitchen files might be
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let iconsPath = documentsPath.appendingPathComponent("icons")
        
        // Create icons directory if it doesn't exist
        try? FileManager.default.createDirectory(at: iconsPath, withIntermediateDirectories: true)
        
        // Expected icon sizes for iOS
        let iconSizes: [String: CGFloat] = [
            "icon-20": 20,
            "icon-29": 29,
            "icon-40": 40,
            "icon-58": 58,
            "icon-60": 60,
            "icon-76": 76,
            "icon-80": 80,
            "icon-87": 87,
            "icon-120": 120,
            "icon-152": 152,
            "icon-167": 167,
            "icon-180": 180,
            "icon-1024": 1024
        ]
        
        // Check what we're looking for
        for (filename, _) in iconSizes {
            let iconPath = iconsPath.appendingPathComponent("\(filename).png")
            _ = FileManager.default.fileExists(atPath: iconPath.path)
        }
    }
    
    // MARK: - Copy Icons to App Bundle
    
    func copyIconsToBundle() {
        guard let bundlePath = Bundle.main.resourcePath else {
            return
        }
        
        let appIconPath = "\(bundlePath)/AppIcon.appiconset"
        
        // Create AppIcon.appiconset directory
        do {
            try FileManager.default.createDirectory(
                atPath: appIconPath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            return
        }
        
        // Create Contents.json
        createContentsJSON(at: appIconPath)
    }
    
    private func createContentsJSON(at path: String) {
        let contentsJSON = """
        {
          "images" : [
            {
              "filename" : "icon-40.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "20x20"
            },
            {
              "filename" : "icon-60.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "20x20"
            },
            {
              "filename" : "icon-58.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "29x29"
            },
            {
              "filename" : "icon-87.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "29x29"
            },
            {
              "filename" : "icon-80.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "40x40"
            },
            {
              "filename" : "icon-120.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "40x40"
            },
            {
              "filename" : "icon-120.png",
              "idiom" : "iphone",
              "scale" : "2x",
              "size" : "60x60"
            },
            {
              "filename" : "icon-180.png",
              "idiom" : "iphone",
              "scale" : "3x",
              "size" : "60x60"
            },
            {
              "filename" : "icon-1024.png",
              "idiom" : "ios-marketing",
              "scale" : "1x",
              "size" : "1024x1024"
            }
          ],
          "info" : {
            "author" : "xcode",
            "version" : 1
          }
        }
        """
        
        let contentsPath = "\(path)/Contents.json"
        
        do {
            try contentsJSON.write(toFile: contentsPath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write Contents.json: \(error)")
        }
    }
    
    // MARK: - Setup App Icons on Launch
    
    func setupAppIcons() {
        createIconsFromDownloadedFiles()
        
        // Generate a fallback icon if needed
        _ = AppIconManager.shared.generateAppIcon()
    }
}