//
//  Photos.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 08.02.23.
//

import Foundation

struct Photos: Decodable {
    let url: String?
    let title: String?
    let urlToImage: String?
    let description: String?
    let publishedAt: String?
    let sourceName: String?
    let author: String?
}
