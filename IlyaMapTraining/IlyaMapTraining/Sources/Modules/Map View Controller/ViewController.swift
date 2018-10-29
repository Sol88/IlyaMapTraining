//
//  ViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 25/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import VK_ios_sdk
import UIKit

class ViewController: UIViewController {
    
    //MARK: - Property
    static var storyboardInstance: ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
    }
    
    var imageMapViewController: ImageMapViewController!
    var fromLibrary = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageMapViewController = ImageMapViewController(with: view.frame, fromLibrary: fromLibrary)
        addChild(imageMapViewController)
        view.addSubview(imageMapViewController.mapView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageMapViewController.fromLibrary = fromLibrary
    }

}


