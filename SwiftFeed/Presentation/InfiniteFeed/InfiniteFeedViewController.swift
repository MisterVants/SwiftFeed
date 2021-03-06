//
//  InfiniteFeedViewController.swift
//  SwiftFeed
//
//  Created by André Vants Soares de Almeida on 03/08/20.
//

import UIKit

class InfiniteFeedViewController: UIViewController {
    
    lazy var infiniteFeed: PageFeed = {
        let feed = PageFeed()
        feed.delegate = self
        return feed
    }()
    
    var feedView: InfiniteFeedView? {
        view as? InfiniteFeedView
    }
    
    override func loadView() {
        let view = InfiniteFeedView()
        view.tableView.dataSource = self
        view.tableView.prefetchDataSource = self
        view.refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localized.navigationTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.preferredCustomFont(for: .headline, weight: .bold)]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.preferredCustomFont(for: .largeTitle, weight: .bold)]
        
        feedView?.loadingView.show()
        infiniteFeed.loadNextPage(resetPagination: true)
    }
    
    @objc func refreshFeed() {
        infiniteFeed.loadNextPage(resetPagination: true)
    }
    
    private func loadMoreItems() {
        if !infiniteFeed.items.isEmpty {
            feedView?.loadingFooter.show()
        }
        infiniteFeed.loadNextPage()
    }
    
    private func stopLoading() {
        feedView?.refreshControl.endRefreshing()
        feedView?.loadingView.hide()
        feedView?.loadingFooter.hide()
    }
}

extension InfiniteFeedViewController: PageFeedDelegate {
    
    func pageFeed(_ feed: PageFeed, didLoadNewItemsAt indexPaths: [IndexPath], onPage pageIndex: Int) {
        stopLoading()
        if pageIndex == 1 {
            feedView?.tableView.reloadData()
        } else {
            feedView?.tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func pageFeed(_ feed: PageFeed, didFailLoadingWithError error: Error) {
        stopLoading()
        if case .rateLimitExceeded = error as? NetworkError {
            let alert = UIAlertController(
                title: Localized.Error.title,
                message: Localized.Error.message,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Localized.Error.action, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension InfiniteFeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infiniteFeed.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: RepositoryCell.self, for: indexPath)
        cell.model = GitHubRepository(serviceModel: infiniteFeed.items[indexPath.row])
        return cell
    }
}

extension InfiniteFeedViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row == tableView.numberOfRows(inSection: $0.section) - 1 }) {
            loadMoreItems()
        }
    }
}
