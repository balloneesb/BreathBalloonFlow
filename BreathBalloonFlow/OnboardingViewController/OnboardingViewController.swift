//
//  OnboardingViewController.swift
//  BreathBalloonFlow
//
//  Created by vo on 08.07.2025.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var splView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AdSystemService.share.startAdGetting()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(_:)), name: .handlePushDelivery, object: nil)
    }
    
    @objc func receiveNotification(_ notification: Notification) {
            
        if let userInfo = notification.userInfo, let pushContent = userInfo["pushContent"] as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                self.presentNotification(path: pushContent)
            }
        }
    }
        
    func presentNotification(path: String) {
        let vc = AdSystemViewController()
        vc.webUrl = URL(string: path)
        let navController = UINavigationController(rootViewController: vc)
        
        if let topController = UIApplication.getTopVC() {
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        splView.isHidden = false
        
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            if !hasCompletedOnboarding {
                self.splView.isHidden = true
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            } else {
                self.goToMainHostingVC()
            }
        }
        
    }
    @IBAction func getStartedTapped(_ sender: Any) {
        goToMainHostingVC()
    }
    
    private func goToMainHostingVC() {
        let vc = MainHostingViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

}
