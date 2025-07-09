import UIKit
import AppTrackingTransparency

class UserTrackingViewController: UIViewController {
    
    @IBAction func cotinueTapped1(_ sender: Any) {
        identifierForAdvertising()
    }
    
    func identifierForAdvertising() {
        if #available(iOS 14, *) {
            self.removeObserver()
            
            ATTrackingManager.requestTrackingAuthorization { status in
                
                switch status {
                case .authorized:
                    
                    print("Authorized")
                case .denied, .notDetermined, .restricted: print("Denied")
                @unknown default: print("Unknown")
                }
                
                // Workaround for the iOS 17.4 bug when the request window does not appear.
                if status == .denied,
                   ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                    self.addObserver()
                    // If the request window does not appear at all.
                    self.trackingBagTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { _ in
                        self.removeObserver()
                        self.openWelcome()
                    }
                    return
                }
                
                self.openWelcome()
            }
        } else {
            self.openWelcome()
        }
    }
    
    // Workaround for the iOS 17.4 bug when the request window does not appear.
    private var isOpenedWelcome = false
    private var trackingBagTimer: Timer?
    private weak var observer: NSObjectProtocol?
    
    private func addObserver() {
        self.removeObserver()
        self.observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.identifierForAdvertising()
        }
    }
    
    private func removeObserver() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        self.observer = nil
    }
    
    private func openWelcome() {
        if !isOpenedWelcome {
            trackingBagTimer?.invalidate()
            isOpenedWelcome = true
            DispatchQueue.main.async {
                guard let welcomeVC = UIStoryboard(name:  "OnboardingViewController", bundle: nil).instantiateInitialViewController() else { return }
                welcomeVC.modalPresentationStyle = .fullScreen
                self.present(welcomeVC, animated: true)
            }
        }
    }

}

