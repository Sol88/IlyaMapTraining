//
//  ImagePagesViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 29/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class ImagePagesViewController: UIPageViewController {
    
    
    //MARK: - Property
    static var storyboardInstance: ImagePagesViewController {
        let storyboard = UIStoryboard(name: "ImagesPagesViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ImagePagesViewController") as! ImagePagesViewController
    }
    
    weak var vkImageListViewController: VKImageListViewController?
    var images: [VKImage] = []
    var selectedImageIndex: Int!
    var childrenViewControllers: [ImageDetailsViewController] = []
    var popComlectionAnimationHandler: ((Int) -> Void)?
    var popAnimationHandler: ((Int) -> Void)?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        generateViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performPushAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        performPopAnimation()
    }

    //MARK: - Method
    func setupView() {
        delegate = self
        dataSource = self
        
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        navigationItem.title = "\(selectedImageIndex + 1) of \(images.count)"
    }
    
    private func generateViewControllers() {
        var array: [ImageDetailsViewController] = []
        
        for image in images {
            let imageDetailsVC = ImageDetailsViewController.storyboardInstance
            imageDetailsVC.image = image
            
            array.append(imageDetailsVC)
        }
        
        childrenViewControllers = array
        setViewControllers([array[selectedImageIndex]], direction: .forward, animated: true)
    }
    
    //MARK: - Animation
    func performPushAnimation() {
        
        guard let selectedCellFrame = vkImageListViewController?.getSelectedCellFrameAndCenter() else { return }
        let currentViewController = childrenViewControllers[selectedImageIndex]
        
        currentViewController.performPushAnimation(with: selectedCellFrame)
    }
    
    func performPopAnimation() {
        
        let currentCellFrame = vkImageListViewController?.getCellsFrameAndCenter(by: selectedImageIndex)
        let currentViewController = childrenViewControllers[selectedImageIndex]
        
        currentViewController.performPopAnimation(with: currentCellFrame, index: selectedImageIndex,handler: popAnimationHandler, completionHandler: popComlectionAnimationHandler)
    }
    
}

//MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension ImagePagesViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard
            let viewController = viewController as? ImageDetailsViewController,
            let index = childrenViewControllers.index(of: viewController),
            index > 0
        else { return nil }
        
        return childrenViewControllers[index - 1]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard
            let viewController = viewController as? ImageDetailsViewController,
            let index = childrenViewControllers.index(of: viewController),
            index < images.count - 1
        else { return nil }
        
        return childrenViewControllers[index + 1]
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewController = pageViewController.viewControllers?.first as? ImageDetailsViewController else { return }
        
        if let index = childrenViewControllers.index(of: viewController) {
            selectedImageIndex = index
            navigationItem.title = "\(index + 1) of \(String(describing: self.images.count))"
        }
        
    }
    
}
