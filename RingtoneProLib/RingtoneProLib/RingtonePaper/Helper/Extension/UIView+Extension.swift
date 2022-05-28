//
//  UIView+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/2/21.
//

import Foundation
import UIKit



extension UIView{
    func fillHorizontalSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            //                if #available(iOS 11, *) {
            //                    leftAnchor.constraint(equalTo: superview.leftAnchor, constant: constant).isActive = true
            //                    rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -constant).isActive = true
            //                } else {
            leftAnchor.constraint(equalTo: superview.leftAnchor, constant: constant).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -constant).isActive = true
            //}
        }
    }
    
    func fillVerticalSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            //                if #available(iOS 11, *) {
            //                    topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: constant).isActive = true
            //                    bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -constant).isActive = true
            //                } else {
            topAnchor.constraint(equalTo: superview.topAnchor, constant: constant).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -constant).isActive = true
            //                }
            
        }
    }
    
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func swipeLeft(duration:Double = 0.3){
        self.frame = CGRect(x: frame.width, y: frame.origin.y, width: frame.width, height: frame.height)
        UIView.animate(withDuration: duration) {
            self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
    }
    func swipeRight(duration:Double = 0.3){
        self.frame = CGRect(x: -frame.width, y: frame.origin.y, width: frame.width, height: frame.height)
        UIView.animate(withDuration: duration) {
            self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
    }
    func applyBlurEffect() {
        if #available(iOS 13.0, *) {
            let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blurEffectView)
        } else {
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blurEffectView)
        }
        
    }
    
    func dropShadow(color: UIColor, opacity: Float = 1, offSet: CGSize, radius: CGFloat = 5, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
      }
    func progressAnimation(value: Double) {
        
        let progressLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: frame.size.width/2, startAngle: -.pi / 2 , endAngle: 3 * .pi / 2, clockwise: true)
        progressLayer.path = circularPath.cgPath
        progressLayer.name = "progressLayer"
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 3
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = #colorLiteral(red: 0.06274509804, green: 0.8039215686, blue: 0.4901960784, alpha: 1)
        layer.addSublayer(progressLayer)
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.fromValue = 0
        circularProgressAnimation.toValue = value
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
    func removeProgressLayer() {
        self.layer.sublayers?.forEach({ progressLayer in
            if progressLayer.name == "progressLayer" {
                progressLayer.removeFromSuperlayer()
            }
        })
    }
}
