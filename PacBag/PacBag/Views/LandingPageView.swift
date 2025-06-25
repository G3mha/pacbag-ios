import SwiftUI

struct LandingPageView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var currentFeatureIndex = 0
    @State private var animateHero = false
    
    var isModal: Bool {
        onboardingManager.hasCompletedOnboarding
    }
    
    let features = [
        Feature(
            icon: "suitcase.fill",
            title: "Smart Packing",
            description: "Digital twin of your luggage with intelligent organization and weight tracking"
        ),
        Feature(
            icon: "list.bullet.clipboard",
            title: "Trip Planning",
            description: "Organize multiple trips with customizable packing lists and templates"
        ),
        Feature(
            icon: "folder.badge.gearshape",
            title: "Category Management",
            description: "Advanced categorization with analytics and usage insights"
        ),
        Feature(
            icon: "icloud.fill",
            title: "CloudKit Sync",
            description: "Your data syncs seamlessly across all your devices"
        )
    ]
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    HeroSection(animateHero: $animateHero, onboardingManager: onboardingManager, isModal: isModal)
                
                // Features Section
                FeaturesSection(features: features, currentFeatureIndex: $currentFeatureIndex)
                
                // Screenshots Section
                ScreenshotsSection()
                
                // Stats Section
                StatsSection()
                
                // CTA Section
                CTASection(onboardingManager: onboardingManager, isModal: isModal)
                
                // Footer
                FooterSection()
                }
            }
            
            // Close button for modal presentation
            if isModal {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateHero = true
            }
            startFeatureRotation()
        }
    }
    
    private func startFeatureRotation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut) {
                currentFeatureIndex = (currentFeatureIndex + 1) % features.count
            }
        }
    }
}

struct HeroSection: View {
    @Binding var animateHero: Bool
    let onboardingManager: OnboardingManager
    let isModal: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            // App Icon and Branding
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateHero ? 1.0 : 0.8)
                        .opacity(animateHero ? 1.0 : 0.0)
                    
                    Image(systemName: "suitcase.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .scaleEffect(animateHero ? 1.0 : 0.5)
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 8) {
                    Text("PacBag")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .opacity(animateHero ? 1.0 : 0.0)
                        .offset(y: animateHero ? 0 : 20)
                    
                    Text("Your Digital Travel Companion")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .opacity(animateHero ? 1.0 : 0.0)
                        .offset(y: animateHero ? 0 : 20)
                }
            }
            
            // Hero Description
            VStack(spacing: 20) {
                Text("Transform your travel packing with the ultimate digital luggage manager")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .opacity(animateHero ? 1.0 : 0.0)
                    .offset(y: animateHero ? 0 : 30)
                
                Text("Never forget an item again. Track weight, organize by category, and sync across all your devices.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .opacity(animateHero ? 1.0 : 0.0)
                    .offset(y: animateHero ? 0 : 30)
                
                // CTA Button
                Button(action: { 
                    if isModal {
                        // Just dismiss if showing as modal
                    } else {
                        onboardingManager.completeOnboarding()
                    }
                }) {
                    HStack(spacing: 12) {
                        Text(isModal ? "Explore Features" : "Start Packing Smart")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                }
                .scaleEffect(animateHero ? 1.0 : 0.9)
                .opacity(animateHero ? 1.0 : 0.0)
                .offset(y: animateHero ? 0 : 20)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 60)
        .animation(.easeInOut(duration: 1.0).delay(0.2), value: animateHero)
    }
}

struct FeaturesSection: View {
    let features: [Feature]
    @Binding var currentFeatureIndex: Int
    
    var body: some View {
        VStack(spacing: 40) {
            // Section Header
            VStack(spacing: 16) {
                Text("Powerful Features")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Everything you need for organized travel")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            // Featured Feature (Large)
            FeatureCard(
                feature: features[currentFeatureIndex],
                isLarge: true
            )
            .padding(.horizontal, 24)
            
            // All Features Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(features.indices, id: \.self) { index in
                    FeatureCard(
                        feature: features[index],
                        isLarge: false,
                        isHighlighted: index == currentFeatureIndex
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 60)
        .background(Color(.systemGray6).opacity(0.5))
    }
}

struct FeatureCard: View {
    let feature: Feature
    let isLarge: Bool
    var isHighlighted: Bool = false
    
    var body: some View {
        VStack(spacing: isLarge ? 20 : 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: isHighlighted ? [.blue, .purple] : [.gray.opacity(0.3), .gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: isLarge ? 80 : 50, height: isLarge ? 80 : 50)
                
                Image(systemName: feature.icon)
                    .font(.system(size: isLarge ? 32 : 20))
                    .foregroundColor(isHighlighted ? .white : .primary)
            }
            
            // Content
            VStack(spacing: isLarge ? 12 : 8) {
                Text(feature.title)
                    .font(isLarge ? .title2 : .headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(isLarge ? .body : .caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(isLarge ? nil : 3)
            }
        }
        .padding(isLarge ? 32 : 16)
        .background(Color(.systemBackground))
        .cornerRadius(isLarge ? 20 : 16)
        .shadow(color: .black.opacity(0.1), radius: isLarge ? 15 : 8, x: 0, y: isLarge ? 8 : 4)
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}

struct ScreenshotsSection: View {
    let screenshots = [
        Screenshot(title: "Trip Overview", description: "Manage multiple trips with ease", systemImage: "list.bullet"),
        Screenshot(title: "Smart Categories", description: "Organized packing with analytics", systemImage: "folder.badge.gearshape"),
        Screenshot(title: "Weight Tracking", description: "Never exceed weight limits", systemImage: "scalemass.fill")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // Section Header
            VStack(spacing: 16) {
                Text("See It In Action")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Beautiful, intuitive interface designed for travelers")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            // Screenshots
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(screenshots.indices, id: \.self) { index in
                        ScreenshotCard(screenshot: screenshots[index])
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 60)
    }
}

struct ScreenshotCard: View {
    let screenshot: Screenshot
    
    var body: some View {
        VStack(spacing: 16) {
            // Mock Screenshot
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 200, height: 350)
                
                VStack(spacing: 20) {
                    Image(systemName: screenshot.systemImage)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                                .frame(height: 12)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Description
            VStack(spacing: 8) {
                Text(screenshot.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(screenshot.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 200)
    }
}

struct StatsSection: View {
    let stats = [
        Stat(number: "100%", label: "Free to Use"),
        Stat(number: "∞", label: "Unlimited Trips"),
        Stat(number: "⚡", label: "Lightning Fast"),
        Stat(number: "☁️", label: "Cloud Sync")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Why Choose PacBag?")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 24) {
                ForEach(stats.indices, id: \.self) { index in
                    VStack(spacing: 12) {
                        Text(stats[index].number)
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        
                        Text(stats[index].label)
                            .font(.headline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 60)
        .background(Color(.systemGray6).opacity(0.5))
    }
}

struct CTASection: View {
    let onboardingManager: OnboardingManager
    let isModal: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Ready to Pack Smart?")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Join thousands of travelers who never forget to pack the essentials")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if !isModal {
                Button(action: { onboardingManager.completeOnboarding() }) {
                    HStack(spacing: 16) {
                        Text("Get Started Now")
                            .font(.title2)
                            .fontWeight(.bold)
                    
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(30)
                    .shadow(color: .blue.opacity(0.4), radius: 20, x: 0, y: 10)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        // Subtle breathing animation
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 80)
    }
}

struct FooterSection: View {
    var body: some View {
        VStack(spacing: 20) {
            Divider()
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "suitcase.fill")
                        .foregroundColor(.blue)
                    Text("PacBag")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Text("Your Digital Travel Companion")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Made with ❤️ for travelers")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Supporting Types

struct Feature {
    let icon: String
    let title: String
    let description: String
}

struct Screenshot {
    let title: String
    let description: String
    let systemImage: String
}

struct Stat {
    let number: String
    let label: String
}

#Preview {
    LandingPageView()
}