//
//  Cell+Extension.swift
//  RingTones-Wallpapers
//
//  Created by vinova on 6/13/21.
//

import UIKit


protocol Reusable: class {
    static var defaultIdentifier: String { get }
}

extension Reusable where Self: UITableViewCell {
    static var defaultIdentifier: String {
        return String(describing: self)
    }
}

extension Reusable where Self: UICollectionViewCell {
    static var defaultIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func register<T: UITableViewCell & Reusable>(_: T.Type) {
        register(UINib(nibName: T.defaultIdentifier, bundle: nil), forCellReuseIdentifier: T.defaultIdentifier)
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell & Reusable>(_: T.Type) {
        register(UINib(nibName: T.defaultIdentifier, bundle: nil), forCellWithReuseIdentifier: T.defaultIdentifier)
    }
}
