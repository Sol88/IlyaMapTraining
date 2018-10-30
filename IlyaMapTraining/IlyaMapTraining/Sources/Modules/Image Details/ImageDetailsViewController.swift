//
//  ImageDetailsViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 29/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import Kingfisher

class ImageDetailsViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var imageView: UIImageView!
    
    //MARK: - Property
    static var storyboardInstance: ImageDetailsViewController {
        let storyboard = UIStoryboard(name: String(describing: ImageDetailsViewController.self), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: ImageDetailsViewController.self)) as! ImageDetailsViewController
    }
    
    var image: VKImage!
    var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
    var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    //MARK: - Lifecyrcle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupImageView()
    }
    
    //MARK: - Action
    @objc func unzoom() {
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut)
        animator.addAnimations { [weak self] in
            self?.scrollView.zoomScale = Constants.minZoom
        }
        
        animator.startAnimation()
    }
    
    //MARK: - Method
    func setupView() {
        scrollView.minimumZoomScale = Constants.minZoom
        scrollView.maximumZoomScale = Constants.maxZoom
    }
    
    func setupImageView() {
        if let link = image.photo604, let url = URL(string: link) {
            imageView.kf.setImage(with: url)
        }
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(unzoom))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    
    //MARK: - Animation
    func performPushAnimation(with frame: CGRect) {
        let originFrame = imageView.frame
        let errorYOffset: CGFloat = 22
        
        imageView.frame = frame
        imageView.frame.origin.y += errorYOffset
        
        scrollView.backgroundColor = UIColor(white: 0, alpha: 0)
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        
        transitionCoordinator?.animateAlongsideTransition(in: view, animation: { [weak self] context in
            
            self?.imageView.frame = originFrame
            self?.view.backgroundColor = UIColor(white: 1, alpha: 1)
            self?.scrollView.backgroundColor = UIColor(white: 0, alpha: 1)
            
        })
    }
    
    func performPopAnimation(with frame: CGRect?, index: Int, handler: ((Int) -> Void)?, completionHandler: ((Int) -> Void)?) {
        unzoom()
        var newFrame = imageView.frame
        
        if let frame = frame {
            newFrame = frame
        } else {
            newFrame.origin.x += 1000
        }
        
        transitionCoordinator?.animateAlongsideTransition(in: view, animation: { [weak self] context in
            
            self?.imageView.frame = newFrame
            self?.scrollView.backgroundColor = UIColor(white: 0, alpha: 0)
            
            self?.view.backgroundColor = UIColor(white: 1, alpha: 0)
            
            handler?(index)
            
        }, completion: { context in
            completionHandler?(index)
        })
    }
    
}

extension ImageDetailsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        parent!.navigationController?.setNavigationBarHidden(!(scrollView.zoomScale == 1.0), animated: true)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        parent!.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        parent!.navigationController?.setNavigationBarHidden(!(scale == 1.0), animated: true)
    }
}

extension ImageDetailsViewController {
    private enum Constants {
        static let maxZoom: CGFloat = 2.5
        static let minZoom: CGFloat = 1.0
    }
}
