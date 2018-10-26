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
    
    //MARK: - Life cycle
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = imageClusterID
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        guard let annotation = annotation as? CircleImageAnnotation else { return }
        image = annotation.imageData.image
    }
    
}
