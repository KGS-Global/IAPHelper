//
//  CustomTopAlertView.swift
//  customAlert
//
//  Created by Shahwat Hasnaine on 23/2/22.
//

import UIKit

class TopAlertView: UIView {

    
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var alertLabel: UILabel!

    // rgba(236, 247, 255, 1)
    // rgba(11, 13, 15, 1)
    private let defaultBackgroundColor: UIColor = UIColor(red: 236.0 / 255.0, green: 247.0/255.0, blue: 255.0/255.0, alpha: 1)
    private let defaultAletTextColor: UIColor = UIColor(red: 11.0 / 255.0, green: 13.0/255.0, blue: 15.0/255.0, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = loadFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _ = loadFromNib()
    }

    func loadFromNib() -> UIView {
        let bundleName = Bundle(for:type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundleName)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        self.initialSettings()
        return view
    }

    private func initialSettings() {
        self.roundBottomCorners(16)
        self.updateDesign(alertBackgroundColor: nil, alertTextColor: nil)
    }

    func updateValue(alertImage: UIImage?, alertText: String?) {

        if let alertText = alertText {
            self.alertLabel.isHidden = false
            self.alertLabel.text = alertText
        } else {
            self.alertLabel.isHidden = true
        }

        if let alertImage = alertImage {
            self.alertImageView.isHidden = false
            self.alertImageView.image = alertImage
        } else {
            self.alertImageView.isHidden = true
        }
    }

    func updateDesign(alertBackgroundColor: UIColor?, alertTextColor: UIColor?) {

        if let alertBackgroundColor = alertBackgroundColor {
            self.backgroundColor = alertBackgroundColor
        } else {
            self.backgroundColor = self.defaultBackgroundColor
        }

        if let alertTextColor = alertTextColor {
            self.alertLabel.textColor = alertTextColor
        } else {
            self.alertLabel.textColor = self.defaultAletTextColor
        }
    }

}



extension UIView {

    func slideInFromLeft(_ duration: TimeInterval = 0.3, completionDelegate: CAAnimationDelegate? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()

        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: CAAnimationDelegate = completionDelegate {
            slideInFromLeftTransition.delegate = delegate
        }

        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed

        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }

    func slideInFromRight(_ duration: TimeInterval = 0.3, completionDelegate: CAAnimationDelegate? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()

        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: CAAnimationDelegate = completionDelegate {
            slideInFromLeftTransition.delegate = delegate
        }

        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed

        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
}


extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

