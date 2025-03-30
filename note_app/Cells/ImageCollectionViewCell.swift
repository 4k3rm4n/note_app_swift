//
//  imageCollectionViewCell.swift
//  note_app
//
//  Created by Bogdan on 21.03.2025.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    func updateView(imageURL: URL) {
        mainImageView.image = UIImage(contentsOfFile: imageURL.path)
    }
}
