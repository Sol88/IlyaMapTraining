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
    var navigationAnimationController = SelectImageCellAnimator()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performPopChildAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        transitionCoordinator?.animateAlongsideTransition(in: view, animation: { context in
            
            if context.viewController(forKey: .to) is ImagePagesViewController {
                self.performPushChildAnimation()
            }
            
        }, completion: { context in
            
            if context.viewController(forKey: .to) is ImagePagesViewController {
                let cell = self.getSelectedCell()
                cell?.hideImage(false)
            }
            
        })
    }
    
    //MARK: - Method
    func getCell(at indexPath: IndexPath) -> VKImageCollectionViewCell? {
        let cell = imagesCollectionView.cellForItem(at: indexPath) as? VKImageCollectionViewCell
        
        return cell
    }
    
    func getSelectedCell() -> VKImageCollectionViewCell? {
        guard let selectedIndexPath = imagesCollectionView.indexPathsForSelectedItems?.first else { return nil }
        
        let selectedCell = imagesCollectionView.cellForItem(at: selectedIndexPath) as! VKImageCollectionViewCell
        
        return selectedCell
    }
    
    func getCellsFrameAndCenter(by index: Int) -> CGRect? {
        guard let cell = imagesCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? VKImageCollectionViewCell else { return nil }
        
        return getFrameAndCenter(of: cell)
    }
    
    
    func getSelectedCellFrameAndCenter() -> CGRect? {
        guard let selectedCell = getSelectedCell() else { return nil }
        
        return getFrameAndCenter(of: selectedCell)
    }
    
    func getFrameAndCenter(of cell: VKImageCollectionViewCell) -> CGRect {
        
        let yScrollOffset = imagesCollectionView.contentOffset.y
        var imageCenter = cell.center
        imageCenter.y -= yScrollOffset
        
        let imageFrame = cell.getImageViewFrame()
        
        let newFrame = CGRect(x: cell.frame.minX + imageFrame.minX + Constants.distanceToSafeArea,
                              y: cell.frame.minY + imageFrame.minY - yScrollOffset + Constants.distanceToSafeArea,
                              width: imageFrame.width,
                              height: imageFrame.height)
        
        return newFrame
    }
    
    func setupCollectionView() {
        imagesCollectionView.register(VKImageCollectionViewCell.self, forCellWithReuseIdentifier: VKImageCollectionViewCell.reuseID)
        
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.layer.cornerRadius = 8
        
        fetchImagesFromVK()
    }
    
    func fetchImagesFromVK() {
        let photoReq: VKRequest? = VKRequest(method: "photos.getAll", parameters: ["skip_hidden": 1])
        
        photoReq?.execute(resultBlock: { [weak self] response in
            guard
                let jsonResult = response?.json as? [String: Any],
                let wrapper = VKPhotoResponse.init(JSON: jsonResult),
                let items = wrapper.items
            else { return }
            
            self?.images = items
            self?.imagesCollectionView.reloadData()
            
        }, errorBlock: { error in
            
            if let error = error {
                print(error)
            }
            
        })
    }
    
    //MARK: - Animation
    func performPushChildAnimation() {
        let selectedCell = getSelectedCell()
        selectedCell?.hideImage(true)
    }
    
    func performPopChildAnimation() {
        let selectedCell = getSelectedCell()
        selectedCell?.hideImage(false)
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailsWrapperVC = ImagePagesViewController.storyboardInstance
        
        detailsWrapperVC.images = images
        detailsWrapperVC.selectedImageIndex = indexPath.row
        detailsWrapperVC.vkImageListViewController = self
        
        detailsWrapperVC.popComlectionAnimationHandler = { [unowned self] index in
            guard let cell = self.getCell(at: IndexPath(row: index, section: 0)) else { return }
            cell.hideImage(false)
        }
        
        detailsWrapperVC.popAnimationHandler = { [unowned self] index in
            guard let cell = self.getCell(at: IndexPath(row: index, section: 0)) else { return }
            cell.hideImage(true)
        }
        
        navigationController?.pushViewController(detailsWrapperVC, animated: true)
    }
    
}


//MARK: - UINavigationControllerDelegate
extension VKImageListViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            navigationAnimationController.pushing = true
        
        default:
            navigationAnimationController.pushing = false
        }
        
        return navigationAnimationController
    }
    
}

extension VKImageListViewController {
    private enum Constants {
        static let distanceToSafeArea: CGFloat = 8
    }
}
