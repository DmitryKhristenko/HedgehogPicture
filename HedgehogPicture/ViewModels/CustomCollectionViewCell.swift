//
//  CustomCollectionViewCell.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 07.02.23.
//

import UIKit

final class CustomCollectionViewCell: UICollectionViewCell {
    static let identifier = "customCell"
    weak var delegate: CustomCollectionViewCellDelegate?
    private let cache = NSCache<NSString, UIImage>()
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.backgroundColor = .gray
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
    private func animate() {
        UIView.animate(withDuration: 0.8, delay: 0.8, options: [.repeat, .autoreverse, .allowUserInteraction]) {
            self.imageView.backgroundColor = .gray.withAlphaComponent(0.7)
        }
    }
    // MARK: - Cache settings
    private func image(for urlString: String) -> UIImage? {
        return cache.object(forKey: urlString as NSString)
    }
    private func save(image: UIImage, for urlString: String) {
        cache.setObject(image, forKey: urlString as NSString)
        cache.totalCostLimit = 1024 * 1024 * 1024 // 1 gigabyte
        cache.countLimit = 200
    }
    // MARK: - Image decoding
    func configure(urlString: String) {
        var finalUrlString = urlString
        if urlString.hasPrefix("http://") {
            finalUrlString = urlString.replacingOccurrences(of: "http://", with: "https://")
        }
        // Check if the image is already in the cache
        if let cachedImage = image(for: finalUrlString) {
            imageView.image = cachedImage
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.delegate?.detailImageView.image = cachedImage
                self.delegate?.hideActivityIndicator()
            }
        } else {
            animate()
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
                    self?.delegate?.detailImageView.image = image
                    if self?.delegate?.detailImageView.image == image {
                        self?.delegate?.hideActivityIndicator()
                    }
                }
            }.resume()
        }
    }
}

protocol CustomCollectionViewCellDelegate: AnyObject {
    var detailImageView: UIImageView! { get set }
    func loadImage()
    func showActivityIndicator()
    func hideActivityIndicator()
}
