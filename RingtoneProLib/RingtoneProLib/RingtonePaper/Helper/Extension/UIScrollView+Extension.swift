//
//  UIScrollView+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 5/13/21.
//

import Foundation
import UIKit


extension UIScrollView {
    
    
    private struct AssociatedKeys {
        static var delegate: UIScrollViewDelegate?
        static var loadControl: UILoadControl?
        fileprivate static var loadControlView: UIView?
    }
    
    
    public var loadControl: UILoadControl? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadControl) as? UILoadControl
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.loadControl, newValue as UILoadControl?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.updateLoadControl()
            }
        }
    }
    
    
    fileprivate var loadControlView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.loadControlView) as? UIView
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.loadControlView, newValue as UIView?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension UIScrollView {
    
    public func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    fileprivate func updateLoadControl() {
        guard let loadControl = self.loadControl else {
            return
        }
        
        loadControl.scrollView = self
        return setupLoadControlViewWithControl(control: loadControl)
    }
    
    
    fileprivate func setupLoadControlViewWithControl(control: UILoadControl) {
        
        guard let loadControlView = self.loadControlView else {
            self.loadControlView = UIView()
            self.loadControlView?.clipsToBounds = true
            self.loadControlView?.addSubview(control)
            return addSubview(self.loadControlView!)
        }
        
        if loadControlView.subviews.contains(control) {
            return
        }
        
        return loadControlView.addSubview(control)
    }
}
