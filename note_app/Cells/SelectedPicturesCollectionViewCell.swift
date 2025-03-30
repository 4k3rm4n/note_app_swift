//
//  selectedPicturesCollectionViewCell.swift
//  note_app
//
//  Created by Bogdan on 24.03.2025.
//

import UIKit

class SelectedPicturesCollectionViewCell: UICollectionViewCell {
    var onRemoveSelectedImageCallback: (() -> Void)?
    @IBOutlet weak var unselectButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unselectButton.layer.cornerRadius = unselectButton.bounds.width / 2
        unselectButton.layer.masksToBounds = true
        selectedImageView.layer.cornerRadius = 8
        selectedImageView.layer.masksToBounds = true ///////////////////////asdasdasdasd
    }
    
    func updateView(with imageURL: URL) {
        selectedImageView.image = UIImage(contentsOfFile: imageURL.path)
    }
    
    @IBAction func didTouchUnselectButton(_ sender: Any) {
        onRemoveSelectedImageCallback?()
    }
}
