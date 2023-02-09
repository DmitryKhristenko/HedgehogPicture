//
//  ViewController.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 07.02.23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataModel = [1,2,8,4,5,6,7,3,9]
    let searchViewController = SearchViewController()
    let searchController = UISearchController(searchResultsController: SearchViewController())
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = searchViewController
        // UISearchResultsUpdating will inform your class of any text changes within the UISearchBar.
        searchController.delegate = searchViewController
        searchController.searchBar.autocapitalizationType = .none
        // Monitor when the search button is tapped.
        searchController.searchBar.delegate = searchViewController
        // UISearchController obscures the view controller containing the information you’re searching.
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos"
        // by setting to true, you ensure that the search bar doesn’t remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
        
        
        //        let nib = UINib(nibName: "TableCell", bundle: nil)
        //        collectionView.register(nib, forCellWithReuseIdentifier: "searchCell")
        
        //        let searchTableController = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        //        // This view controller is interested in table view row selections.
        //           searchTableController?.tableView.delegate = searchTableController
        
        
        
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //            let destinationVC = segue.destination as? SearchViewController
    //        }
    //        // searchController.performSegue(withIdentifier: "TableCell", sender: self)
    //    }
    
}

extension ViewController: UISearchControllerDelegate {
    
}



extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource, PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as? CustomCollectionViewCell {
            cell.imageView.image = UIImage(named: "\(dataModel[indexPath.row]).jpg")
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 15
            cell.imageView.contentMode = .scaleAspectFill
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let image = UIImage(named: "\(dataModel[indexPath.row]).jpg")
        if let height = image?.size.height {
            return height / 5.0
        }
        return 0.0
    }
}


