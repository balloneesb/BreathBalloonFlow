
import Foundation
import AppTrackingTransparency
import AdSupport

class AppCoreConfig {
    
    static let appsFlyerSDKKey = "8GSZoXiiSqkF8SgugKTLEm"
    
    static let appStoreID = "6748152951"
    
    static var appInfoSource = "bretheeballo_iosapp"
    
    static let userDeviceUUID = getDeviceUUID()
    
    static let adsCoreConfigURL = "https://balloneesb.com/ad/"
    
    static let oneSignalAppToken = "17bdd772-8dfc-4c3c-b3e5-070ecd849f5f"
    
    static private func getDeviceUUID() -> String? {
        
        var idfa: String = "";
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    
                    print("Authorized")
                    
                    idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    
                case .denied: print("denied")
                case .notDetermined: print("not determined")
                case .restricted: print("restricted")
                @unknown default: print("unknown")
                }
            }
        } else {
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return nil
            }
            idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        return idfa
    }
    
}

extension Notification.Name {
    static let handlePushDelivery = Notification.Name("handlePushDelivery")
}
