
import Foundation
import UIKit

class AdSystemBanerView: UIView {
    private let adPresentationLayer = AdSystemContentView.share

    private var adViewCurrentlyShown = false

    private var adBannerVisual: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private var adGraphicAsset: UIImage? = UIImage(named: "banner_empty") {
        didSet {
            DispatchQueue.main.async {
                self.adBannerVisual.image = self.adGraphicAsset
            }
        }
    }

    private var isAdViewFresh = false

    private let adDismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .link
        button.addTarget(self, action: #selector(dismissButtonTriggered), for: .touchUpInside)
        button.backgroundColor = .white.withAlphaComponent(0.4)
        button.layer.cornerRadius = 5
        return button
    }()

    var notShowBanner = true

    var networkManager: AdSystemManager?

    private let adDisplayBlockHeight: CGFloat = 40

    private let adDisplayBlockWidth: CGFloat = 300

    var adData: AdSystemModel? = nil {
        didSet {
            if let imageUrlString = adData?.thumbUrl {
                networkManager?.getImage(urlString: imageUrlString) { img in
                    self.adGraphicAsset = img
                }
            }
        }
    }

    func exposeAdView(from string: String, baseUrl: String) {
        adViewCurrentlyShown = true
        adPresentationLayer.show(webString: string, baseUrl: baseUrl) {
            self.adViewCurrentlyShown = false
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showNew() {
        isAdViewFresh = true
        exposeAdView()
    }

    func show() {
        guard notShowBanner == false else { return }
        guard adData != nil else { return }
        guard adData?.isNew == false else { return }
        guard let parentVC = UIApplication.getTopVC() else { return }
        guard (parentVC as? UIAlertController) == nil else { return }
        
        if !adViewCurrentlyShown {
            if isAppeared {
                if self.superview !== parentVC.view {
                    hideBannerComponent() {
                        self.showAdComponent(in: parentVC.view )
                    }
                }
            } else {
                self.showAdComponent(in: parentVC.view )
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        adPresentationLayer.delegate = self
        prepareAdLayoutView()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBannerClicked)))
    }

    private func prepareAdLayoutView() {
        
        self.clipsToBounds = true
        self.backgroundColor = .green
        self.layer.cornerRadius = 3
        
        self.addSubview(adBannerVisual)
        
        adBannerVisual.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adBannerVisual.topAnchor.constraint(equalTo: self.topAnchor),
            adBannerVisual.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            adBannerVisual.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            adBannerVisual.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        self.addSubview(adDismissButton)
        
        adDismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adDismissButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            adDismissButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            adDismissButton.widthAnchor.constraint(equalToConstant: 30),
            adDismissButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToCloseHandler))
        swipeDownGesture.direction = .down
        self.addGestureRecognizer(swipeDownGesture)
    }

    @objc private func swipeToCloseHandler() {
        hideBannerComponent()
    }

    private func showAdComponent(in parentView: UIView) {
        adBannerVisual.image = adGraphicAsset
        let safeAreaBottom = parentView.safeAreaInsets.bottom

        self.frame = CGRect(x: (parentView.frame.width - adDisplayBlockWidth) / 2,
                            y: parentView.frame.height,
                            width: adDisplayBlockWidth,
                            height: adDisplayBlockHeight)

        parentView.addSubview(self)

        UIView.animate(withDuration: 0.3, animations: { [self] in
            self.frame = CGRect(x: (parentView.frame.width - adDisplayBlockWidth) / 2,
                                y: parentView.frame.height - adDisplayBlockHeight - safeAreaBottom + 6, // высота на которую поднимаеться банер
                                width: adDisplayBlockWidth,
                                height: adDisplayBlockHeight)
        }) { _ in
            self.isAppeared = true
        }
    }

    private func extractAdUrl() -> String? {
        guard let adUrl = adData?.adUrl else { return nil }
        if !isAdViewFresh {
            return adUrl
        } else {
            isAdViewFresh = false
            return adUrl.addParamsToURL(params: networkManager?.newDataPrm() ?? "")
        }
    }

    private func hideBannerComponent(_ completion: (()->Void)? = nil) {
        if let superview = superview {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame = CGRect(x: self.frame.origin.x,
                                    y: superview.frame.height,
                                    width: self.frame.width,
                                    height: self.frame.height)
            }) { _ in
                self.removeFromSuperview()
                self.isAppeared = false
                completion?()
            }
        } else {
            self.isAppeared = false
            completion?()
        }
    }

    private func exposeAdView() {
        guard let adUrl = extractAdUrl() else { return }
        adViewCurrentlyShown = true
        adPresentationLayer.show(urlString: adUrl) {
            self.adViewCurrentlyShown = false
        }
    }

    @objc private func onBannerClicked() {
        exposeAdView()
    }

    @objc private func dismissButtonTriggered() {
        hideBannerComponent()
    }

    private(set) var isAppeared = false
    
}

extension AdSystemBanerView: AdSystemViewDelegate {
    func adViewDidShow(adContentView: AdSystemContentView) {
        guard adData?.isNew == true else { return }
        adPresentationLayer.viewController.setButton()
    }

}
