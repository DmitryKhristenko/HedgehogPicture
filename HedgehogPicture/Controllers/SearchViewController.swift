//
//  SearchViewController.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 08.02.23.
//

import UIKit

class SearchViewController: UITableViewController {
    var networkManager = NetworkManager()
    let searchResultModel = SearchResultModel(name: "", thumbnail: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
        print("Show searchViewController")
        networkManager.delegate = self
       //что-то типо этого для поисковой строки  searchTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Setting up the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResultModel.name?.count ?? 8
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = searchResultModel.name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainVC = ViewController()
        present(mainVC, animated: true)
    }
    
}
// MARK: - NetworkManagerDelegate
extension SearchViewController: NetworkManagerDelegate {
    func didUpdateSearch(_ NetworkManager: NetworkManager, search: SearchResultModel) {
        DispatchQueue.main.async {
            print(search)
            
            // наверное вызвать метод обновления таблицы с новым апи запросом
        }
    }
    func didFailWithError(error: Error) {
        Logger.shared.debugPrint(error)
    }
}
// MARK: - Search Field methods
extension SearchViewController: UISearchResultsUpdating {
    // Asks the object to update the search results for a specified controller.
    func updateSearchResults(for searchController: UISearchController) {
        guard let textSearch = searchController.searchBar.text else {
            return
        }
        print(textSearch)
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        print("willPresentSearchController")
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
