//
//  NetworkManager.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 08.02.23.
//

import Foundation

let searchViewController = SearchViewController()
protocol NetworkManagerDelegate {
    func didUpdateSearch(_ NetworkManager: NetworkManager, search: SearchResultModel)
    func didFailWithError(error: Error)
}
struct NetworkManager {
    var delegate: NetworkManagerDelegate?
    func fetchResults(typedSearch: String) {
        let urlString = "https://serpapi.com/search.json?engine=google&q=\(typedSearch)&tbm=isch&start=0&num=20&ijn=0&api_key=\(ApiKey.shared.key)"
        performRequest(with: urlString)
        print("urlString: \(urlString)")
    }
    
    func performRequest(with urlString: String) {
        // 1. Create a URL
        if let url = URL(string: urlString) {
            // 2. Create a URL session
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    Logger.shared.debugPrint(error as Any)
                    return
                }
                if let safeData = data {
                    if let search = self.parseJSON(safeData) {
                        self.delegate?.didUpdateSearch(self, search: search)
                    }
                }
            }
            // 4. Start the task
            task.resume()
        }
    }
    func parseJSON(_ searchData: Data) -> SearchResultModel? {
        print("parseJSON func was called")
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(SearchResultEnvelope.self, from: searchData)
            let name = decodedData.searchResults[1].name
            let thumbnail = decodedData.searchResults[1].thumbnail
            let searchResults = SearchResultModel(name: name, thumbnail: thumbnail)
            print("searchResults:\(searchResults)")
            return searchResults
        } catch {
            delegate?.didFailWithError(error: error)
            Logger.shared.debugPrint(error)
            return nil
        }
    }
}
