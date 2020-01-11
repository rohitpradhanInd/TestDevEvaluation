//  ViewController.swift
//  Posts
//
//  Created  on 11/01/20.
//
//

import UIKit

class PostsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet var postTableView: UITableView!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var pageNumber: Int = 1
    // MARK: - Properties
    var posts: [Post] = []
        
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPosts(isRefresh: true)
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Set up
    private func setupUI() {
        updateNavigationTitle()
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.estimatedRowHeight = 44
        if #available(iOS 10.0, *) {
            postTableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
    }
    
    // MARK: - Actions
    private func updateNavigationTitle(){
       let selectedCount = posts.filter({$0.isSelected}).count
        
        if selectedCount == 0 {
            self.navigationItem.title = "Posts"
        } else {
            self.navigationItem.title = "Posts" + "(\(selectedCount))"

        }
    }
    
    @objc private func refreshList() {
        self.fetchPosts(isRefresh: true)
    }
    
    // MARK: - Navigation
    
    // MARK: - Network Manager calls
    
    private func fetchPosts(isRefresh: Bool) {
        
        APIManager.shared.fetchPostsRequest(pageNumber: self.pageNumber) { [weak self] (result) in
            
            if let `self` = self {
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    switch (result) {
                    case .success(let posts):
                        if isRefresh {
                            self.posts = []
                            self.posts = posts ?? []
                        } else {
                            self.posts.append(contentsOf: posts ?? [])
                        }
                        
                        self.postTableView.reloadData()
                        self.updateNavigationTitle()
                        
                    case.failure(let error):
                        print(error)
                    }
                }
            }
            
        }
    }

}

// MARK: - Extensions

extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "PostsCell", for: indexPath) as! PostsCell
        let post = posts[indexPath.row]
        cell.titleLabel.text = post.title
        cell.dateLabel.text = post.createdAt
        cell.toggleSwitch.isOn = post.isSelected
        return cell
    }
    
}


extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        posts[indexPath.row].isSelected = !posts[indexPath.row].isSelected
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateNavigationTitle()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard  indexPath.row == self.posts.count - 1 else { return }
        pageNumber +=  1
        fetchPosts(isRefresh: false)
    }
  
}
