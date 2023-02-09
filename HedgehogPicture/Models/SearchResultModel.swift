//
//  SearchResultModel.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 09.02.23.
//

import Foundation

struct SearchResultModel: Decodable {
    let name: String?
    let thumbnail: String?
    init(name: String?, thumbnail: String?) {
        self.name = name
        self.thumbnail = thumbnail
    }
}
struct SearchResultEnvelope: Decodable {
    let searchResults: [SearchResultModel]
    enum CodingKeys: String, CodingKey {
        case suggestedResults = "suggested_searches"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.searchResults = try values.decodeIfPresent([SearchResultModel].self, forKey: .suggestedResults)!
    }
}


//
//
//struct ImagesResult: Decodable {
//    let position: Int
//    let thumbnail: String
//    let source, title: String
//    let link: String
//    let original: String?
//    let isProduct: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case position, thumbnail, source, title, link, original
//        case isProduct = "is_product"
//    }
//}
