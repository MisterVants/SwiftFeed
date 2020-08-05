//
//  InfiniteFeedView.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import UIKit

class InfiniteFeedView: UIView {
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = loadingFooter
        tableView.register(RepositoryCell.self)
        return tableView
    }()
    
    private(set) lazy var loadingFooter: LoadingFooterView = {
        LoadingFooterView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 100))
    }()
    
    let refreshControl = UIRefreshControl()
    
    init() {
        super.init(frame: .zero)
        layoutView()
    }
    
    private func layoutView() {
        addSubview(tableView)
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let tableConstraints = [
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)]
        
        NSLayoutConstraint.activate(tableConstraints)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
