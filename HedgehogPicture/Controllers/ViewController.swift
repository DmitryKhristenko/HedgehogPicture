//
//  ViewController.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 07.02.23.
//

import UIKit

final class ViewController: UIViewController {
    let networkManager = NetworkManager()
    let customCollectionViewCell = CustomCollectionViewCell()
    let searchController = UISearchController(searchResultsController: nil)
    var collectionView: UICollectionView?
    var typedSearch = ""
    var shouldLoadNextPage = true
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.delegate = self
        setupCollectionView()
        setupSearchController()
        configureRefreshControl()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let navBar = navigationController?.navigationBar {
            collectionView?.frame = CGRect(x: 0, y: navBar.frame.maxY, width: view.bounds.width, height: view.bounds.height - navBar.frame.maxY)
        }
    }
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        let layout = PinterestLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        collectionView.backgroundColor = .init(named: "blured")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? PinterestLayout { layout.delegate = self }
        view.addSubview(collectionView)
    }
    // MARK: - Setup Search Controller
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchBar.autocapitalizationType = .none
        // Monitor when the search button is tapped.
        searchController.searchBar.delegate = self
        // UISearchController obscures the view controller containing the information you’re searching.
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos"
        // The search bar doesn’t remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
    }
}

extension ViewController: DataReloadDelegate, UISearchBarDelegate {
    // DataReloadDelegate method
    func reloadData() {
        collectionView?.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if var text = searchBar.text {
            if text.contains(" ") {
                text = text.replacingOccurrences(of: " ", with: "_")
            }
            reloadData()
            NetworkManager.imagesResults = []
            networkManager.fetchPhotos(typedSearch: text, page: 0)
            typedSearch = text
        }
    }
}
// MARK: - Setup Collection View
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, PinterestLayoutDelegate, PaginationDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NetworkManager.imagesResults.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        guard index < NetworkManager.imagesResults.count else {
            return UICollectionViewCell()
        }
        guard let imageUrlString = NetworkManager.imagesResults[index].original else {
            return UICollectionViewCell()
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(urlString: imageUrlString)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let imageHeightInInt = NetworkManager.imagesResults[indexPath.row].original_height else {
            return 250.0
        }
        let imageHeightInCGFloat = CGFloat(integerLiteral: imageHeightInInt)
        return imageHeightInCGFloat / 5
    }
    // MARK: - Setup second screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToPhoto", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhoto",
           let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first,
           let imageCell = collectionView?.cellForItem(at: selectedIndexPath) as? CustomCollectionViewCell,
           let destinationVC = segue.destination as? ImageDetailViewController {
            destinationVC.image = imageCell.imageView.image
            destinationVC.imageUrl = NetworkManager.imagesResults[selectedIndexPath.row].original
            destinationVC.linkToPageWithImage = NetworkManager.imagesResults[selectedIndexPath.row].link
            destinationVC.titleTextToImage = NetworkManager.imagesResults[selectedIndexPath.row].title
            destinationVC.imagePosition = NetworkManager.imagesResults[selectedIndexPath.row].position ?? 1
        }
    }
    // MARK: - Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        let nextPage = currentPage + 1
        guard shouldLoadNextPage && offsetY > contentHeight - height else { return }
        shouldLoadNextPage = false
        networkManager.fetchPhotos(typedSearch: typedSearch, page: nextPage)
        currentPage = nextPage
    }
    func didFetchPhotos() {
        shouldLoadNextPage = true // set shouldLoadNextPage back to true
        collectionView?.reloadData()
    }
    // MARK: - Refresh control
    private func configureRefreshControl() {
        // Add the refresh control to UIScrollView object.
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    @objc private func handleRefreshControl() {
        // Update content
        reloadData()
        // Dismiss the refresh control.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
}
