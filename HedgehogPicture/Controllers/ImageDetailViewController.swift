//
//  ImageDetailViewController.swift
//  HedgehogPicture
//
//  Created by Дмитрий Х on 15.02.23.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    var image: UIImage?

    var imageUrl: String?
    
    @IBOutlet weak var uiImageView: UIImageView!

    @IBAction func imageUrlButton(_ sender: Any) {
        print("button taped, url \(String(describing: imageUrl))")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiImageView.image = image

    }
    


}
