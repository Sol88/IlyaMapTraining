//
//  CircleImageAnnotation.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 25/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CircleImageAnnotation: NSObject, MKAnnotation {
    
    
    var imageData: ImageData!
    var representedAssetIdentifier: String!
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return imageData.location
        }
        set {
            imageData.location = newValue
        }
    }
    
    override init() {
        super.init()
    }
    
    init(imageData: ImageData) {
        self.imageData = imageData
        super.init()
    }
    
}
