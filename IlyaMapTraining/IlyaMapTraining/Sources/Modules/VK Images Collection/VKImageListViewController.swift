//
//  VKImageListViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 26/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import VK_ios_sdk
import Kingfisher

class VKImageListViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    //MARK: - Property
    static var storyboardInstance: VKImageListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "VKImageListViewController") as! VKImageListViewController
    }
    
    var images: [VKImage] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - Method
    func setupView() {
        imagesCollectionView.register(VKImageCollectionViewCell.self, forCellWithReuseIdentifier: VKImageCollectionViewCell.reuseID)
        
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.layer.cornerRadius = 8
        
        fetchImagesFromVK()
        
    }
    
    func fetchImagesFromVK() {
        let photoReq: VKRequest? = VKRequest(method: "photos.getAll", parameters: ["skip_hidden": 1])
        
        photoReq?.execute(resultBlock: { [weak self] response in
            
            guard let jsonResult = response?.json as? [String: Any] else { return }
            let wrapper = VKPhotoResponse.init(JSON: jsonResult)
            
            guard let items = wrapper?.items else { return }
            self?.images = items
            self?.imagesCollectionView.reloadData()
            
        }, errorBlock: { error in
            if let error = error {
                print(error)
            }
        })
    }
    
}

extension VKImageListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VKImageCollectionViewCell.reuseID, for: indexPath) as! VKImageCollectionViewCell
        let image = images[indexPath.row]
    
        cell.populate(with: image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSide = imagesCollectionView.frame.width / 2 - 5
        let cellSize = CGSize(width: cellSide, height: cellSide)
        return cellSize
    }
    
}
