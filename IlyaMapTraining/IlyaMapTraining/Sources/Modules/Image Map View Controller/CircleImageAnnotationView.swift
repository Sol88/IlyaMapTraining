//
//  CircleImageAnnotationView.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 25/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import MapKit

private let imageClusterID = "multiImage"

class CircleImageAnnotationView: MKAnnotationView {

    static let reuseID = "imageAnnotation"
    private var imageView: UIImageView!
    
    //MARK: - Life cycle
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        clusteringIdentifier = imageClusterID
        
        frame.size = CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)
        
        imageView = UIImageView(frame: bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.cornerRadius
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
         
        guard let annotation = annotation as? CircleImageAnnotation else { return }
        imageView.image = annotation.imageData.image
    }
    
}

extension CircleImageAnnotationView {
    
    enum Constants {
        static let circleDiameter: CGFloat = 60
        static var cornerRadius: CGFloat {
            get {
                return circleDiameter / 2
            }
        }
    }
    
}
