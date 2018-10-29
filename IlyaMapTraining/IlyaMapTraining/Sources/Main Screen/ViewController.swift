//
//  ViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 25/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    //MARK: - Property
    var imageMapViewController: ImageMapViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageMapViewController = ImageMapViewController(with: view.frame)
        addChild(imageMapViewController)
        view.addSubview(imageMapViewController.mapView)
    }


}

