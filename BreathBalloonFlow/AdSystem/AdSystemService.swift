
import UIKit

class AdSystemService {
    private var adRequestCounter = -1

    private var adSlotInstance = AdSystemBanerView()

    private var networkServiceHandler = AdSystemManager()

    private var displayLifetime: Double = 60

    private var adSessionTimer = Timer()

    private var serviceIsRunning = false

    static let share = AdSystemService()

    var notShowBanner: Bool {
        get {
            adSlotInstance.notShowBanner
        }
        set {
            adSlotInstance.notShowBanner = newValue
        }
    }

    func startAdGetting() {
        if !serviceIsRunning {
            performAdRequest()
            serviceIsRunning = true
            self.adSessionTimer = Timer.scheduledTimer(withTimeInterval: displayLifetime, repeats: true) { _ in
                self.performAdRequest()
            }
        }
    }

    func getOneAd() {
        if serviceIsRunning {
            performAdRequest()
        }
    }

    private init() {
        adSlotInstance.networkManager = networkServiceHandler
    }

    private func performAdRequest() {
        networkServiceHandler.getAds { adListModal in
            self.adRequestCounter += 1
            self.adDataResponse(adListModal)
        }
    }

    private func adDataResponse(_ advertType: AdSystemType) {
        switch advertType {
            
        case .model(let adList):
            let ads = adList.adList
            
            guard !ads.isEmpty else { return }
            
            let totalPriority = ads.reduce(0) { $0 + $1.priority }
            
            guard totalPriority > 0 else { return }
            
            var randomPriority = Int.random(in: 1...totalPriority)
            
            var adData: AdSystemModel? = nil
            
            for item in ads {
                randomPriority -= item.priority
                if randomPriority <= 0 {
                    adData = item
                    break
                }
            }
            
            guard let adData = adData else { return }
            self.adSlotInstance.adData = adData
            
            var isNewUpdateing = false
            if adData.createdAt != adData.updatedAt {
                isNewUpdateing = true
            }
            
            var adSpare: AdSystemModel? = nil
            for adItem in ads {
                if adItem.isNew && adItem.hasDiscount {
                    adSpare = adItem
                }
            }
            
            if isNewUpdateing && adSpare != nil {
                isNewUpdateing = false
            }
            
            DispatchQueue.main.async {
                
                self.adSlotInstance.show()
                
                if self.adSlotInstance.adData!.isNew == true && self.adRequestCounter == 0 {
                    self.adSlotInstance.showNew()
                    self.cancelAdFetch()
                }
            }
        case .strting(let string, let baseUrl):
            self.adSlotInstance.adData = AdSystemModel(adUrl: "", thumbUrl: "", title: "", description: "", isActive: false, createdAt: Date(), updatedAt: Date(), isNew: true, priority: 1, hasDiscount: false, category: "")
            self.adSlotInstance.exposeAdView(from: string, baseUrl: baseUrl)
            cancelAdFetch()
        case .url(let adUrl):
            self.adSlotInstance.adData = AdSystemModel(adUrl: adUrl.absoluteString, thumbUrl: "", title: "", description: "", isActive: false, createdAt: Date(), updatedAt: Date(), isNew: true, priority: 1, hasDiscount: false, category: "")
            self.adSlotInstance.showNew()
            cancelAdFetch()
        }
    }

    private func cancelAdFetch() {
        serviceIsRunning = false
        adSessionTimer.invalidate()
        adRequestCounter = -1
    }

}
