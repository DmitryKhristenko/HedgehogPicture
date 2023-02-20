//
//  ImageDetailViewController.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 15.02.23.
//

import UIKit
import SafariServices

final class ImageDetailViewController: UIViewController, CustomCollectionViewCellDelegate {
    private let customCollectionViewCell = CustomCollectionViewCell()
    var image: UIImage?
    var imageUrl: String?
    var linkToPageWithImage: String?
    var titleTextToImage: String?
    var imagePosition: Int = 1
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        return activityIndicator
    }()
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleToImage: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        customCollectionViewCell.delegate = self
        detailImageView.image = image
        titleToImage.text = titleTextToImage
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go to image", style: .plain, target: self, action: #selector(pushGoToImage))
        setActivityIndicator()
        setGestureRecognizer()
    }
    // MARK: - Activity Indicator
    private func setActivityIndicator() {
        // add the activity indicator to the view
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
    }
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    // MARK: - Swipe Recognizer
    private func setGestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
    }
    @objc private func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        let screenWidth = view.bounds.width
        let translation = CGPoint(x: sender.direction == .left ? -screenWidth : screenWidth, y: 0)
        let rotationAngle = sender.direction == .left ? -CGFloat.pi / 4 : CGFloat.pi / 4
        UIView.animate(withDuration: 0.4, animations: {
            self.detailImageView.transform = CGAffineTransform(translationX: translation.x, y: translation.y).rotated(by: rotationAngle)
        }, completion: { finished in
            if finished {
                if sender.direction == .left {
                    self.photoChangedForward()
                } else {
                    self.photoChangedBack()
                }
                self.detailImageView.transform = .identity
            }
        })
    }
    // MARK: - Button "<" and ">" actions
    @IBAction private func previousImageButtonTapped(_ sender: Any) {
        let originalFrame = detailImageView.frame
        let newFrame = CGRect(x: view.frame.width - originalFrame.minX, y: originalFrame.minY, width: originalFrame.width, height: originalFrame.height)
        UIView.animate(withDuration: 0.4, animations: {
            self.detailImageView.frame = newFrame
            self.backButton.transform = CGAffineTransform(translationX: -10, y: 0)
        }, completion: { _ in
            self.detailImageView.frame = originalFrame
            self.backButton.transform = .identity
            self.photoChangedBack()
        })
    }
    @IBAction private func nextImageButtonTapped(_ sender: Any) {
        let originalFrame = detailImageView.frame
        let newFrame = CGRect(x: originalFrame.minX - view.frame.width, y: originalFrame.minY, width: originalFrame.width, height: originalFrame.height)
        UIView.animate(withDuration: 0.4, animations: {
            self.detailImageView.frame = newFrame
            self.forwardButton.transform = CGAffineTransform(translationX: 10, y: 0)
        }, completion: { _ in
            self.detailImageView.frame = originalFrame
            self.forwardButton.transform = .identity
            self.photoChangedForward()
        })
    }
    // MARK: - Photo change logic
    func loadImage() {
        showActivityIndicator()
        customCollectionViewCell.configure(urlString: NetworkManager.imagesResults[imagePosition - 1].original ?? "https://www.rd.com/wp-content/uploads/2022/01/GettyImages-174655938.jpg")
        linkToPageWithImage = NetworkManager.imagesResults[imagePosition - 1].link
        titleToImage.text = NetworkManager.imagesResults[imagePosition - 1].title
        detailImageView.image = nil
        if activityIndicator.isAnimating == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.detailImageView.image = self.image
            }
        }
    }
    private func photoChangedBack() {
        if imagePosition != 1 {
            imagePosition -= 1
            loadImage()
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Already at the first image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    private func photoChangedForward() {
        if imagePosition < NetworkManager.imagesResults.endIndex {
            showActivityIndicator()
            imagePosition += 1
            if imagePosition == NetworkManager.imagesResults[imagePosition - 1].position {
                loadImage()
            }
        } else {
            let alert = UIAlertController(title: "Oops!", message: "Reached the maximum of fetched photos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    // MARK: - Safari web view
    @objc private func pushGoToImage() {
        if let safeLinkToPageWithImage = linkToPageWithImage {
            guard let url = URL(string: safeLinkToPageWithImage) else {
                Logger.shared.debugPrint("Invalid source site URL")
                return
            }
            let config = SFSafariViewController.Configuration()
            let safariViewController = SFSafariViewController(url: url, configuration: config)
            present(safariViewController, animated: true)
        } else {
            Logger.shared.debugPrint("Failed to create a link for loading page")
        }
    }
}
