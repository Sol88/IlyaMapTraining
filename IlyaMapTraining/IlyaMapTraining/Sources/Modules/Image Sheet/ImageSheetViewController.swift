//
//  ImageSheetViewController.swift
//  CoolActionSheet
//
//  Created by Kovalenko Ilia on 23/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Photos

class ImageSheetViewController: UIViewController {
    
    //MARK: - Property
    private let reuseCellIdentifier = "ImagesCollectionViewCell"
    private let collectionHeight: CGFloat = 100
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    private var actionSheet: UIAlertController?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: collectionHeight, height: collectionHeight)
        
        let imageCollectionView = UICollectionView(frame: CGRect(x: 8.0, y: 48.0, width: actionSheet!.view.bounds.width - 8.0 * 4, height: collectionHeight), collectionViewLayout: layout)
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: reuseCellIdentifier)
        imageCollectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        imageCollectionView.layer.cornerRadius = 6.0
        imageCollectionView.clipsToBounds = true
        
        return imageCollectionView
    }()
    
    private var images: PHFetchResult<PHAsset>?
    private var imagesWithoutLocation: [PHAsset] = []
    private var actions: [UIAlertAction] = []
    private lazy var animator: UIViewPropertyAnimator = {
        let parameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: 0.2, timingParameters: parameters)
        return animator
    }()
    
    // Shared properties
    var newLocationForImage: CLLocationCoordinate2D?
    var getThumbnailImageHandler: ((UIImage, CLLocation?) -> Void)?
    var getHighQualityImageHandler: ((UIImage, CLLocation?) -> Void)?
    var targetSize: CGSize? {
        didSet {
            thumbnailSize = targetSize
        }
    }
    
    //MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        thumbnailSize = CGSize(width: collectionHeight, height: collectionHeight)
        if checkAuthorizationStatus() {
            prepareThumbnails()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    func set(actions: [UIAlertAction]) {
        self.actions = actions
    }
    
    func showActionSheet() {
        let actionSheet = getActionSheet(accessGranted: checkAuthorizationStatus())
        parent?.present(actionSheet, animated: true)
    }
    
    private func getActionSheet(accessGranted: Bool) -> UIAlertController {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.actionSheet = actionSheet
        
        let imageCollectionView = collectionView
        
        if accessGranted {
            
            if imagesWithoutLocation.count > 0 {
                actionSheet.title = "Set geotag to image\n\n\n\n\n\n\n"
                actionSheet.view.addSubview(imageCollectionView)
                
            } else {
                actionSheet.title = "There are no images without geotag"
            }
            
        } else {
            
            actionSheet.title = nil
            imageCollectionView.removeFromSuperview()
            
            actionSheet.addAction(UIAlertAction(title: "Access to Library needed. Press to open Settings", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            })
            
        }
        
        for action in actions {
            actionSheet.addAction(action)
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        return actionSheet
    }
    
    private func prepareThumbnails(){
        resetCachedAssets()
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        images = PHAsset.fetchAssets(with: allPhotosOptions)
        
        guard let images = images else { return }
        
        for i in 0..<images.count {
            let image = images.object(at: i)
            
            if image.location == nil {
                imagesWithoutLocation.append(image)
            }
        }
        
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ImageSheetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesWithoutLocation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = imagesWithoutLocation[indexPath.row]
        let location = asset.location
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellIdentifier, for: indexPath) as! ImagesCollectionViewCell
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.populate(with: image, location: location)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let targetSize = targetSize {
            
            let selectedCell = collectionView.cellForItem(at: indexPath) as! ImagesCollectionViewCell
            let selectedAsset = imagesWithoutLocation[indexPath.row]
            
            if let location = newLocationForImage {
                
                let newLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.init(for: selectedAsset)
                    assetChangeRequest.location = newLocation
                })
                
                selectedCell.location = newLocation
                
                getThumbnailImageHandler?(selectedCell.thumbnailImage, selectedCell.location)
                getHighQualityImage(for: selectedAsset, with: targetSize)
                
                imagesWithoutLocation.remove(at: indexPath.row)
                collectionView.deleteItems(at: [indexPath])
            }
            
        }
        
        actionSheet?.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        let highlightedCell = collectionView.cellForItem(at: indexPath) as! ImagesCollectionViewCell
        
        animator.addAnimations {
            highlightedCell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        animator.startAnimation()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        let unhighlightedCell = collectionView.cellForItem(at: indexPath) as! ImagesCollectionViewCell
        
        animator.addAnimations {
            unhighlightedCell.transform = CGAffineTransform.identity
        }
        
        animator.startAnimation()
    }
}

//MARK: - PhotoKit
extension ImageSheetViewController {
    private func getHighQualityImage(for asset: PHAsset, with size: CGSize) {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
            guard let image = image else { return }
            self.getHighQualityImageHandler?(image, asset.location)
        }
        
    }
    
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    private func checkAuthorizationStatus() -> Bool{
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
            
        case .denied, .restricted, .notDetermined:
            requestAuthorizationForPhoto()
            return false
        }
        
    }
    
    private func requestAuthorizationForPhoto() {
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                self?.prepareThumbnails()
            }
        }
        
    }
}
