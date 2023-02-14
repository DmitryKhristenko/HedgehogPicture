//
//  NetworkManager.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 08.02.23.
//

import UIKit

class NetworkManager {

    weak var delegate: DataReloadDelegate?
    
    var imagesResults: [ApiImages] = []
    
    var currentPage = 0
    
    func fetchPhotos(typedSearch: String, page: Int) {
        let urlString = "https://serpapi.com/search.json?engine=google&q=\(typedSearch)&tbm=isch&ijn=\(page)&api_key=\(ApiKey.shared.key)"
        
        guard let url = URL(string: urlString) else {
            Logger.shared.debugPrint("Error in URL creation")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                Logger.shared.debugPrint(error as Any)
                return
            }
            do {
                let jsonResults = try JSONDecoder().decode(ImagesResult.self, from: data)
                DispatchQueue.main.async {
                    guard let safeResults = jsonResults.images_results else {
                        Logger.shared.debugPrint(error as Any)
                        return
                    }
                    if safeResults.count <= 100 {
                        self?.imagesResults = safeResults
                    } else {
                        self?.imagesResults.append(contentsOf: safeResults)
                    }
                    self?.imagesResults = safeResults
                    self?.delegate?.reloadData()
                    print("jsonResults - \(String(describing: jsonResults.images_results?.count))")
                    print("local variable in NetworkManager - \(String(describing: self?.imagesResults.count))")
                    print(url)
                }
            }
            catch {
                Logger.shared.debugPrint(error)
            }
        }
        task.resume()
    }
    
    func loadNextPage(for typedSearch: String) {
        currentPage = 1
        fetchPhotos(typedSearch: typedSearch, page: currentPage) // fetch new page of results
    }
    
}

protocol DataReloadDelegate: AnyObject {
    func reloadData()
}
