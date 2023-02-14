//
//  CustomCollectionViewCell.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 07.02.23.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "customCell"
    
    private let cache = NSCache<NSString, UIImage>()
    
     let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    
    func image(for urlString: String) -> UIImage? {
        //print("image func was called \(cache.name)")
        return cache.object(forKey: urlString as NSString)
    }
    
    func save(image: UIImage, for urlString: String) {
        cache.setObject(image, forKey: urlString as NSString)
        cache.totalCostLimit = 1024 * 1024 * 1024 // 1 gigabyte
        //print("image saved")
    }
    
    func configure(with urlString: String) {
        var finalUrlString = urlString
        if urlString.hasPrefix("http://") {
            finalUrlString = urlString.replacingOccurrences(of: "http://", with: "https://")
        }
        // Check if the image is already in the cache
        if let cachedImage = image(for: finalUrlString) {
            self.imageView.image = cachedImage
            print(imageView.image?.images as Any)
            return
        }
        // If the image is not in the cache, download it from the URL
        guard let url = URL(string: finalUrlString) else {
            Logger.shared.debugPrint("failed to load image")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                Logger.shared.debugPrint(error as Any)
                return
            }
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else {
                    Logger.shared.debugPrint("Error in creation UIImage from data")
                    return
                }
                self?.save(image: image, for: finalUrlString)
                self?.imageView.image = image
            }
        }.resume()
    }
}
    
//    func configure(with urlString: String) {
//        var finalUrlString = urlString
//        if urlString.hasPrefix("http://") {
//            finalUrlString = urlString.replacingOccurrences(of: "http://", with: "https://")
//        }
//        // Check if the image is already in the cache
//        if let cachedImage = image(for: finalUrlString) {
//            self.imageView.image = cachedImage
//            print(cachedImage.images as Any)
//            return
//        }
//        // If the image is not in the cache, download it from the URL
//        guard let url = URL(string: finalUrlString) else {
//            Logger.shared.debugPrint("failed to load image")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard let data = data, error == nil else {
//                Logger.shared.debugPrint(error as Any)
//                return
//            }
//            DispatchQueue.main.async {
//                let image = UIImage(data: data)
//                guard let safeImage = image else {
//                    Logger.shared.debugPrint("Error in creation UIImage from data")
//                    return
//                }
//                self?.save(image: safeImage, for: finalUrlString)
//                print("save method was called \(String(describing: self?.save(image: safeImage, for: finalUrlString)))" as Any)
//                self?.imageView.image = safeImage
//            }
//        }.resume()
//    }



//    func configure(with urlString: String, completion: @escaping (Data?) -> Void) {
//        var finalUrlString = urlString
//        if urlString.hasPrefix("http://") {
//            finalUrlString = urlString.replacingOccurrences(of: "http://", with: "https://")
//        }
//
//        guard let url = URL(string: finalUrlString) else {
//            completion(nil)
//            Logger.shared.debugPrint("failed to load image")
//            return
//        }
//        if let cachedImage = imageCache.object(forKey: NSString(string: finalUrlString)) {
//            completion(cachedImage as Data)
//        } else {
//            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//                guard error == nil, let data = data else {
//                    Logger.shared.debugPrint(error as Any)
//                    completion(nil)
//                    return
//                }
//                DispatchQueue.main.async {
//                    let image = UIImage(data: data)
//                    self?.imageView.image = image
//                }
//                self?.imageCache.setObject(data as NSData, forKey: NSString(string: finalUrlString))
//                completion(data)
//            }.resume()
//        }
//    }

