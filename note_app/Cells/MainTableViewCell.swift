//
//  MainTableViewCell.swift
//  note_app
//
//  Created by Bogdan on 15.03.2025.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    var onRemoveCell: (() -> Void)?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var imagesURL: [URL]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let imageFlowLayout = UICollectionViewFlowLayout()
        imageFlowLayout.itemSize = .init(width: 100, height: 100)
        imageFlowLayout.scrollDirection = .horizontal
        imageFlowLayout.minimumInteritemSpacing = 10
        imageCollectionView.collectionViewLayout = imageFlowLayout
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        let cellName = String(describing: ImageCollectionViewCell.self)
        imageCollectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
    }
    
    func updateView(withState state: MessagePresentation) {
        imagesURL = state.imagesData?.map { $0.thumbnailImageURL}
        dateLabel.text = state.date
        messageLabel.text = state.message
        imageCollectionView.reloadData()
    }
    @IBAction func didTouchRemoveButton(_ sender: Any) {
        onRemoveCell?()
    }
}

extension MainTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imagesURL = imagesURL {
            return imagesURL.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellName = String(describing: ImageCollectionViewCell.self)
        guard let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        if let imagesURL = imagesURL{
            cell.updateView(imageURL: imagesURL[indexPath.row])
        }
        return cell
    }
}

extension MainTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
