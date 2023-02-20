//
//  NetworkManager.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 08.02.23.
//

import UIKit

final class NetworkManager {
    weak var delegate: DataReloadDelegate?
    weak var paginationDelegate: PaginationDelegate?
    static var imagesResults: [ApiImages] = []
    private var currentPage = 0
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
                        NetworkManager.imagesResults = safeResults
                    } else {
                        NetworkManager.imagesResults.append(contentsOf: safeResults)
                    }
                    self?.delegate?.reloadData()
                    self?.paginationDelegate?.didFetchPhotos()
                }
            } catch {
                Logger.shared.debugPrint(error)
            }
        }
        task.resume()
    }
}

protocol DataReloadDelegate: AnyObject {
    func reloadData()
}
protocol PaginationDelegate: AnyObject {
    func didFetchPhotos()
}
