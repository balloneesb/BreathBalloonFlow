import UIKit
import AppTrackingTransparency

final class AppRouter {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            showUserTracking()
        } else {
            showOnboarding()
        }
    }

    private func showUserTracking() {
        let storyboard = UIStoryboard(name: "UserTrackingViewController", bundle: nil)
        guard let trackingVC = storyboard.instantiateInitialViewController() as? UserTrackingViewController else {
            fatalError("Failed to create UserTrackingViewController")
        }
        window.rootViewController = trackingVC
        window.makeKeyAndVisible()
    }

    private func showOnboarding() {
        let storyboard = UIStoryboard(name: "OnboardingViewController", bundle: nil)
        guard let onboardingVC = storyboard.instantiateInitialViewController() as? OnboardingViewController else {
            fatalError("Failed to create OnboardingViewController")
        }
        window.rootViewController = onboardingVC
        window.makeKeyAndVisible()
    }
} 