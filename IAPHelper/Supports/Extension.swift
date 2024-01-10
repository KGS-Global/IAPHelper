//
//  UIViewExtension.swift
//  IAPHelper
//
//  Created by Rifat Haider on 14/12/23.
//

import UIKit
extension UIView {
    func roundTopCorners(_ radius: CGFloat = 10) {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.roundCorners(corners: [.topLeft, .topRight], radius: radius)
        }
    }
    
    func roundBottomCorners(_ radius: CGFloat = 10) {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            self.roundCorners(corners: [.bottomLeft, .bottomRight], radius: radius)
        }
    }
    
    func roundBothCorner(_ radius: CGFloat = 10) {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
    }
    
    private func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIApplication {

    func getKeyWindow() -> UIWindow? {

        return UIApplication.shared.windows.filter({$0.isKeyWindow}).first
    }
    


    /// Top visible viewcontroller
    var topMostVisibleViewController : UIViewController? {

        let keyWindow = self.getKeyWindow()

        if keyWindow?.rootViewController is UINavigationController {
            return (keyWindow?.rootViewController as! UINavigationController).visibleViewController
        }
        return nil
    }
}
