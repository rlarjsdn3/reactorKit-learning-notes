//
//  DetailViewController.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import UIKit

import Kingfisher

final class DetailViewController: UIViewController {

    @IBOutlet weak private var imageView: UIImageView!
    
    var imageUrl: URL? {
        didSet {
            guard let url = imageUrl else { return }
            imageView.kf.setImage(with: .network(url))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
    }

}
