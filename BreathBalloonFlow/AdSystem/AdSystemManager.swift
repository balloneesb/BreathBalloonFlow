
import UIKit
import AppsFlyerLib
import OneSignalFramework

class AdSystemManager: NSObject {
    private var vendorIdValue: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    private var campaignSourceTag: String {
        AppCoreConfig.appInfoSource
    }

    private var parameterSet: [(String, String)] {
        return [
            ("device_id", deviceIdentifierCode),
            ("utm_source", campaignSourceTag),
            ("push-token", pushNotificationToken),
            ("appsf_cuid", clientTrackingCode),
            ("idfv", vendorIdValue)
        ]
    }

    private var fullEncodedParams: String {
        var paramsStr = ""
        for val in parameterSet {
            paramsStr += val.0 + "=" + val.1 + "&"
        }
        paramsStr = paramsStr.trimmingCharacters(in: CharacterSet(charactersIn: "&"))
        
        return paramsStr
    }

    private var clientTrackingCode: String {
        AppsFlyerLib.shared().getAppsFlyerUID()
    }

    private var deviceIdentifierCode: String {
        AppCoreConfig.userDeviceUUID ?? ""
    }

    private var pushNotificationToken: String {
        OneSignal.User.pushSubscription.token ?? ""
    }

    private var finalLandingRedirect: URL?

    private let userAgentField = "Mozilla/5.0 (\(UIDevice.current.name); CPU iPhone OS \(UIDevice.current.systemVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(UIDevice.current.systemVersion) Mobile/\(UIDevice.current.localizedModel) Safari/604.1"

    func getImage(urlString: String, completion: @escaping (UIImage)->Void) {
        guard let imageUrl = URL(string: urlString) else { return}
        
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
        }.resume()
    }
    
    func getAds(completion: @escaping (AdSystemType)->Void) {
        let urlString = constructAdUrlString()
        guard let url = URL(string: String(urlString)) else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue(userAgentField, forHTTPHeaderField: "User-Agent")

        let task = session.dataTask(with: request) { (data, response, error) in
             if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                
                guard let httpResponse = response as? HTTPURLResponse else { return }
                
                if let finalURL = self.finalLandingRedirect {
                    DispatchQueue.main.async {
                        completion(.url(finalURL))
                    }
                } else {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let adList = try decoder.decode(AdSystemListModel.self, from: data)
                        completion(.model(adList))
                    } catch let jsonError {
                        var string = self.convertEncodedString(data: data, response: response)
                        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                        let baseUrl = "\(components?.scheme ?? "")://\(components?.host ?? "")"
                        completion(.strting(string, baseUrl))
                    }
                }
            }
        }

        task.resume()
    }

    func newDataPrm() -> String {
        return fullEncodedParams
    }

    private func convertEncodedString(data: Data, response: URLResponse?) -> String {
        var string = String(data: data, encoding: .utf8)
        
        if string == nil, let encodingName = response?.textEncodingName {
            let encoding = CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
            let stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding)
            string = String(data: data, encoding: String.Encoding(rawValue: stringEncoding))
        }
        
        return string ?? "server string is empty"
    }

    private func constructAdUrlString() -> String {
        var urlString = AppCoreConfig.adsCoreConfigURL
        urlString += "?"
        
        urlString += fullEncodedParams
        
        return urlString
    }

}

extension AdSystemManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        if request.url?.absoluteString.contains("tid=") ?? false || request.url?.absoluteString.contains("tkn=") ?? false {
            self.finalLandingRedirect = request.url
            completionHandler(nil)
        } else {
            completionHandler(request)
        }
    }

}

enum AdSystemType {
    case url(URL)
    case strting(String, String)
    case model(AdSystemListModel)
}
