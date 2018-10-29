//
//  VKImageCollectionViewCell.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 26/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class VKImageCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "VKImageCollectionViewCell"
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populate(with image: VKImage) {
        if let photoUrlString = image.photo604,
            let url = URL(string: photoUrlString) {
            imageView.kf.setImage(with: url)
        }
    }
    
}
