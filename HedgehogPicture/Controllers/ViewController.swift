//
//  ViewController.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 07.02.23.
//

import UIKit

class ViewController: UIViewController {
    
    var imageSizes: [IndexPath: CGSize] = [:]
    
    var collectionView: UICollectionView?
    
    let networkManager = NetworkManager()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var itemPerPage = 20
    
    var typedSearch = ""
    
    override func viewDidLoad() {
        print("loaded view")
        super.viewDidLoad()
        
        networkManager.delegate = self
        
        setupCollectionView()
        setupSearchController()
        
        //        layout.scrollDirection = .vertical
        //        layout.minimumLineSpacing = 0
        //        layout.minimumInteritemSpacing = 0
        //        layout.itemSize = CGSize(width: view.frame.size.width / 2, height: view.frame.size.width / 2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    // MARK: - Setup Collection View
    func setupCollectionView() {
        let layout = PinterestLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CustomCollectionViewCell.self,
                                forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.collectionView = collectionView
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = .init(named: "blured")
        if let layout = collectionView.collectionViewLayout as? PinterestLayout { layout.delegate = self }
        view.addSubview(collectionView)
    }
    // MARK: - Setup Search Controller
    func setupSearchController() {
        navigationItem.searchController = searchController
        // UISearchResultsUpdating will inform your class of any text changes within the UISearchBar.
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        // Monitor when the search button is tapped.
        searchController.searchBar.delegate = self
        // UISearchController obscures the view controller containing the information you’re searching.
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos"
        // by setting to true, you ensure that the search bar doesn’t remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
    }
}

extension ViewController: DataReloadDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    func reloadData() {
        collectionView?.reloadData()
        print("reloadData from delegate was called")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            reloadData()
            networkManager.imagesResults = []
            networkManager.fetchPhotos(typedSearch: text, page: 0)
            typedSearch = text
            print("typedSearch = \(typedSearch)")
        }
    }
    func updateSearchResults(for searchController: UISearchController) {}
}
// MARK: - Setup Collection View
extension ViewController: UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate, PinterestLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("imagesResults.count = \(networkManager.imagesResults.count)")
        return networkManager.imagesResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        guard index < networkManager.imagesResults.count else {
            return UICollectionViewCell()
        }
        guard let imageUrlString = networkManager.imagesResults[index].original else {
            return UICollectionViewCell()
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageUrlString)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let imageHeightInInt = networkManager.imagesResults[indexPath.row].original_height else {
            return 200.0
        }
        let imageHeightInCGFloat = CGFloat(integerLiteral: imageHeightInInt)
        return imageHeightInCGFloat / 5
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > contentHeight - height {
            print("scrollViewDidScroll")
            networkManager.loadNextPage(for: typedSearch)
            reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToPhoto", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToPhoto",
               let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first,
               let imageCell = collectionView?.cellForItem(at: selectedIndexPath) as? CustomCollectionViewCell,
               let destinationVC = segue.destination as? ImageDetailViewController {
                
                // Pass the selected image and URL string to the destination view controller
                destinationVC.image = imageCell.imageView.image
                destinationVC.imageUrl = networkManager.imagesResults[selectedIndexPath.row].original
            }
        }

    
}

