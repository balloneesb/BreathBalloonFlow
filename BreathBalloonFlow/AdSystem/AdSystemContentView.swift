
import UIKit
import WebKit

protocol AdSystemViewDelegate {
    func adViewDidShow(adContentView: AdSystemContentView)
}

class AdSystemContentView {
    private var onContentHideDone: (()->Void)?

    let viewController: AdSystemViewController

    var delegate: AdSystemViewDelegate?

    static let share = AdSystemContentView()

    func show(urlString: String, _ onContentHideDone: (()->Void)? = nil) {
        guard let adUrl = URL(string: urlString) else { return }
        
        viewController.dismissCompletion = onContentHideDone
        viewController.webUrl = adUrl
        
        let navController = UINavigationController(rootViewController: viewController)
        
        
        if let topController = UIApplication.getTopVC() {
            navController.modalPresentationStyle = .fullScreen
            topController.present(navController, animated: true, completion: nil)
        }
    }

    func didShow() {
        delegate?.adViewDidShow(adContentView: self)
    }

    func show(webString: String, baseUrl: String, _ onContentHideDone: (()->Void)? = nil) {
        viewController.dismissCompletion = onContentHideDone
        viewController.webString = webString
        viewController.baseUrl = URL(string: baseUrl)
        
        DispatchQueue.main.async {
            let navController = UINavigationController(rootViewController: self.viewController)
            
            if let topController = UIApplication.getTopVC() {
                navController.modalPresentationStyle = .fullScreen
                topController.present(navController, animated: true, completion: nil)
            }
        }
    }

    private init() {
        viewController = AdSystemViewController()
        viewController.adView = self
    }

}

class AdSystemViewController: UIViewController, WKNavigationDelegate {
    var webString: String?

    var webUrl: URL?

    var dismissCompletion: (()->Void)?

    private var inlineWebDisplay: WKWebView!

    private var buttonGroupWasUpdated = false

    var baseUrl: URL?

    var adView: AdSystemContentView?

    private var uiBackControl: UIBarButtonItem!

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        dismissCompletion?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topSafeArea = view.safeAreaInsets.top
        inlineWebDisplay.frame = CGRect(x: 0, y: topSafeArea, width: view.bounds.width, height: view.bounds.height - topSafeArea)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adView?.didShow()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        defineBackControl()
        initEmbeddedWebView()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.host?.contains("apps.apple.com") == true {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            redirectAlertPrompt()
            return
        }
        decisionHandler(.allow)
    }

    @objc func backTapped(_ sender: UIButton) {
        if inlineWebDisplay.canGoBack {
            inlineWebDisplay.goBack()
        }
    }

    func setButton() {
        buttonGroupWasUpdated = true
        let button = uiBackControl.customView as? UIButton
        button?.removeTarget(self, action: #selector(backControlTriggered), for: .touchUpInside)
        button?.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    func inlineWebDisplay(_ inlineWebDisplay: WKWebView, didFinish navigation: WKNavigation!) {
        if buttonGroupWasUpdated {
            uiBackControl.isEnabled = inlineWebDisplay.canGoBack
        }
    }

    private func defineBackControl() {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        
        if let backImage = UIImage(systemName: "chevron.backward") {
            button.setImage(backImage, for: .normal)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.tintColor = navigationController?.navigationBar.tintColor
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        button.sizeToFit()
        button.addTarget(self, action: #selector(backControlTriggered), for: .touchUpInside)
        
        uiBackControl = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = uiBackControl
    }

    private func initEmbeddedWebView() {
        if webUrl != nil || webString != nil {
            inlineWebDisplay = WKWebView(frame: CGRect.zero)
            view.addSubview(inlineWebDisplay)
            inlineWebDisplay.navigationDelegate = self
            inlineWebDisplay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let topSafeArea = view.safeAreaInsets.top
            inlineWebDisplay.frame = CGRect(x: 0, y: topSafeArea, width: view.bounds.width, height: view.bounds.height - topSafeArea)
            
            if let adUrl = webUrl {
                let request = URLRequest(url: adUrl)
                inlineWebDisplay.load(request)
            } else if let webString = webString {
                inlineWebDisplay.loadHTMLString(webString, baseURL: baseUrl)
            }
        }
    }

    private func redirectAlertPrompt() {
        let alert = UIAlertController(title: "Apple Store will be opened in a few seconds", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
    }

    @objc private func backControlTriggered() {
        self.dismiss(animated: true, completion: nil)
    }

}
