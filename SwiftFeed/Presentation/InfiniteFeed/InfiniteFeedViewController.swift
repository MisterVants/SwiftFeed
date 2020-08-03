//
//  InfiniteFeedViewController.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import UIKit

class InfiniteFeedViewController: UIViewController {
    
    override func loadView() {
        let view = InfiniteFeedView()
        view.tableView.dataSource = self
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Swift Feed"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension InfiniteFeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: RepositoryCell.self, for: indexPath)
        return cell
    }
}
