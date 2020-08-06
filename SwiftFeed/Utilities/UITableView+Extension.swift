//
//  UITableView+Extension.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: T.typeDescription)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: type.typeDescription, for: indexPath) as? T else {
            fatalError("Unable to dequeue table view cell with identifier: \(type.typeDescription)")
        }
        return cell
    }
}
