//
//  MainHostingViewController.swift
//  BreathBalloonFlow
//
//  Created by vo on 08.07.2025.
//

import UIKit
import SwiftUI

class MainHostingViewController: UIViewController {
    private var hostingController: UIHostingController<AnyView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AdSystemService.share.notShowBanner = false
        AdSystemService.share.getOneAd()
        
        let rootView: AnyView = AnyView(LibraryView())
       
        // Создаем и добавляем UIHostingController
        let hostingController = UIHostingController(rootView: rootView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
} 
