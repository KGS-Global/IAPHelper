//
//  CustomAlertManager.swift
//  RemoveObject
//
//  Created by Shahwat Hasnaine on 23/2/22.
//

import Foundation
import UIKit

class TopAlertManager{

    static var isNoInterNetAlertShowing: Bool = false
    static var isSuccessShowing: Bool = false
    static var isCustomShowing: Bool = false

    private func getAlertHeight() -> CGFloat {
        return 64 + (UIDevice().hasNotch == true ? 20 : 0)
    }

    private func showAlert(fromViewController: UIViewController, alertView: TopAlertView, completion: (()->())? = nil) {
        let alertHeight: CGFloat = self.getAlertHeight()
        let frame = CGRect(x: 0, y: -alertHeight, width: fromViewController.view.bounds.width, height: alertHeight)


        fromViewController.view.addSubview(alertView)
        let newFrame = CGRect(x: 0, y: 0, width: fromViewController.view.bounds.width, height: alertHeight)

        UIView.animate(withDuration: 0.7) {
            alertView.frame = newFrame
        } completion: { isCompleted in
            UIView.animate(withDuration: 0.5, delay: 1.5) {
                alertView.frame = frame
            } completion: { isCompleted in
                alertView.removeFromSuperview()
                if let completion = completion{
                    completion()
                }
            }
        }

    }

    class func showNoInternetAlert() {

//        guard let fromViewController = UIApplication.shared.topMostVisibleViewController else {
//            fatalError("No visible view controller")
//        }

        guard let fromViewController = UIApplication.topViewController() else {
            fatalError("No visible view controller")
        }

        if self.isNoInterNetAlertShowing == true {
            return
        }

        self.isNoInterNetAlertShowing = true

        let alertHeight: CGFloat = self.getAlertHeight(TopAlertManager())()
        let frame = CGRect(x: 0, y: -alertHeight, width: fromViewController.view.bounds.width, height: alertHeight)
        let alertView = TopAlertView(frame: frame)
        alertView.updateValue(alertImage: nil, alertText: "No Internet Connection")

        self.showAlert(TopAlertManager())(fromViewController: fromViewController, alertView: alertView, completion: {
            self.isNoInterNetAlertShowing = false
        })
    }

    class func showSuccessTopAlert() {

        guard let fromViewController = UIApplication.shared.topMostVisibleViewController else {
            fatalError("No visible view controller")
        }

        if self.isSuccessShowing == true {
            return
        }

        self.isSuccessShowing = true

        let alertHeight: CGFloat = self.getAlertHeight(TopAlertManager())()
        let frame = CGRect(x: 0, y: -alertHeight, width: fromViewController.view.bounds.width, height: alertHeight)
        let alertView = TopAlertView(frame: frame)
        alertView.updateValue(alertImage: UIImage(named: "Net_Success", in: Bundle(for: self), with: nil), alertText: "Success")
        alertView.updateDesign(alertBackgroundColor: .green, alertTextColor: nil)


        self.showAlert(TopAlertManager())(fromViewController: fromViewController, alertView: alertView, completion: {
            self.isSuccessShowing = false
        })
    }

    class func showCustomTopAlert(withBackgroundColor: UIColor?, withTextColor: UIColor?, withImageName: String, withText: String?, completion: (()->())? = nil) {

        let withImage: UIImage = UIImage(named: withImageName, in: Bundle(for: self), with: nil)!
        guard let fromViewController = UIApplication.shared.topMostVisibleViewController else {
            fatalError("No visible view controller")
        }

        if self.isCustomShowing == true {
            return
        }

        self.isCustomShowing = true

        let alertHeight: CGFloat = self.getAlertHeight(TopAlertManager())()
        let frame = CGRect(x: 0, y: -alertHeight, width: fromViewController.view.bounds.width, height: alertHeight)
        let alertView = TopAlertView(frame: frame)
        alertView.updateValue(alertImage: withImage, alertText: withText)
        alertView.updateDesign(alertBackgroundColor: withBackgroundColor, alertTextColor: withTextColor)


        self.showAlert(TopAlertManager())(fromViewController: fromViewController, alertView: alertView, completion: {
            self.isCustomShowing = false
            if let completion = completion{
                completion()
            }
        })
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    
}


extension UIDevice{
    var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        //if UIDevice.current.orientation.isPortrait {  //Device Orientation != Interface Orientation
        if let o = windowInterfaceOrientation?.isPortrait, o == true {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
}
