//
//  imageCollectionViewCell.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import UIKit

// MARK: - CollectionViewCell

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    
    @IBOutlet private weak var searchImageView: UIImageView!
    
    // MARK: Properties
    private var currentImageURL: URL!
    
    // MARK: Methods
    
    // prepares the cell for next use
    override func prepareForReuse() {
        super.prepareForReuse()
        searchImageView.image = nil
    }
    
    // setup cell content with the model object
    func setUpCell(with imageData: ImageData) {
        guard let url = imageData.imageURL else {
            return
        }
        currentImageURL = url
        if let data = ImageCache.shared.imageData(for: url) {
            searchImageView.image = UIImage(data: data)
        } else {
            weak var weakSelf = self
            let cellTag = self.tag
            NetworkingClient.shared.downloadImage(for: url) { (data) in
                guard let srongSelf = weakSelf else {
                    return
                }
                if cellTag == srongSelf.tag {
                    srongSelf.searchImageView.image = UIImage(data: data)
                }
            }
        }
    }
}
