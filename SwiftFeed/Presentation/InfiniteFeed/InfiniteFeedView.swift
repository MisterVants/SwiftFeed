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
        tableView.estimatedRowHeight = Style.listRowHeight
        tableView.tableFooterView = loadingFooter
        tableView.register(RepositoryCell.self)
        return tableView
    }()
    
    private(set) lazy var loadingFooter: LoadingFooterView = {
        LoadingFooterView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: Style.listRowHeight))
    }()
    
    let refreshControl = UIRefreshControl()
    let loadingView = ActivityView()
    
    init() {
        super.init(frame: .zero)
        layoutView()
    }
    
    private func layoutView() {
        addSubview(tableView)
        addSubview(loadingView)
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let tableConstraints = [
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)]
        
        let loadingConstraints = [
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)]
        
        NSLayoutConstraint.activate([
            tableConstraints,
            loadingConstraints
        ].flatMap {$0})
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
