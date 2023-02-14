//
//  ApiImages.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 08.02.23.
//

import Foundation

struct ImagesResult: Codable {
    let images_results: [ApiImages]?
}

struct ApiImages: Codable {
    let position: Int?
    let link: String?
    let original: String? // photo itself
    let original_width: Int?
    let original_height: Int?
}
