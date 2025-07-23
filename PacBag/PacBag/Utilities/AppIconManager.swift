import UIKit

class AppIconManager {
    static let shared = AppIconManager()
    
    private init() {}
    
    // MARK: - Primary Icon Setup (Programmatic Bundle Creation)
    
    func configureAppIcons() {
        // This sets up alternate icons that can be switched programmatically
        setupAlternateIcons()
    }
    
    // MARK: - Alternate Icons
    
    private func setupAlternateIcons() {
        // Check if alternate icons are supported
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
    }
    
    func setAlternateIcon(named iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        
        UIApplication.shared.setAlternateIconName(iconName) { _ in
            // Icon change completed
        }
    }
    
    var currentIconName: String? {
        return UIApplication.shared.alternateIconName
    }
}

// MARK: - Dynamic Icon Generation

extension AppIconManager {
    
    // Generate app icon programmatically
    func generateAppIcon() -> UIImage? {
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let icon = renderer.image { context in
            // Background
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add luggage icon (using SF Symbols)
            if let suitcaseIcon = UIImage(systemName: "suitcase.fill") {
                let iconSize = CGSize(width: 600, height: 600)
                let iconRect = CGRect(
                    x: (size.width - iconSize.width) / 2,
                    y: (size.height - iconSize.height) / 2,
                    width: iconSize.width,
                    height: iconSize.height
                )
                
                UIColor.white.setFill()
                suitcaseIcon.draw(in: iconRect)
            }
            
            // Add app name
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 80, weight: .bold)
            ]
            
            let text = "PacBag"
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: size.height - 150,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return icon
    }
    
    // Save generated icon to documents directory
    func saveGeneratedIcon() -> URL? {
        guard let icon = generateAppIcon() else { return nil }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let iconURL = documentsPath.appendingPathComponent("AppIcon.png")
        
        if let data = icon.pngData() {
            do {
                try data.write(to: iconURL)
                return iconURL
            } catch {
                print("Failed to write icon data: \(error)")
            }
        }
        
        return nil
    }
}