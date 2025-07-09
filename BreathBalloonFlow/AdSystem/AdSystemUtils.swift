
import UIKit

extension UIApplication {
    static func getTopVC(_ vc: UIViewController? = {
        if #available(iOS 13, *) {
            var rootViewController: UIViewController?
            let allScenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }

            for scene in allScenes {
                for window in scene.windows where !window.isHidden {
                    rootViewController = window.rootViewController
                    break
                }
                if rootViewController != nil {
                    break
                }
            }
            return rootViewController
        } else {
            return UIApplication.shared.windows.filter { !$0.isHidden }.first?.rootViewController
        }
    }()) -> UIViewController? {
        if let navController = vc as? UINavigationController {
            return getTopVC(navController.viewControllers.last)
        } else if let tabController = vc as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getTopVC(selected)
            }
        } else if let presented = vc?.presentedViewController {
            return getTopVC(presented)
        }
        return vc
    }

}

extension String {
    func addParamsToURL(params: String) -> String? {
        guard var urlComponents = URLComponents(string: self) else { return nil }
        
        let paramPairs = params.split(separator: "&")
        
        if urlComponents.queryItems == nil {
            urlComponents.queryItems = []
        }
        
        for param in paramPairs {
            let keyValue = param.split(separator: "=")
            if keyValue.count == 2 {
                let key = String(keyValue[0])
                let value = String(keyValue[1])
                
                if !(urlComponents.queryItems?.contains(where: { $0.name == key }) ?? false) {
                    let newQueryItem = URLQueryItem(name: key, value: value)
                    urlComponents.queryItems?.append(newQueryItem)
                }
            }
        }
        
        return urlComponents.url?.absoluteString
    }

}

