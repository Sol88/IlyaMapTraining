//
//  SwipeInteractiveTransitionAnimatorViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 29/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit

class SelectImageCellAnimator: NSObject {
    
    //MARK: - Property
    var duration = 0.7
    var animatorForCurrentTransition: UIViewImplicitlyAnimating?
    var pushing = false
    
}

//MARK: - UIViewControllerAnimatedTransitioning
extension SelectImageCellAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animatorForCurrentTransition = animatorForCurrentTransition {
            return animatorForCurrentTransition
        }
        
        if pushing {
            return createPushAnimator(using: transitionContext)
        } else {
            return createPopAnimator(using: transitionContext)
        }
        
    }
}

//MARK: - Animator creating methods
extension SelectImageCellAnimator {
    func createPushAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let containerView = transitionContext.containerView
        let presentedView = transitionContext.view(forKey: .to)!
        
        let parameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        
//        presentedView.backgroundColor = UIColor(white: 1, alpha: 0)
        containerView.addSubview(presentedView)
        
        
        animator.addAnimations {
//            presentedView.backgroundColor = UIColor(white: 1, alpha: 1)
        }
        
        animator.addCompletion { [weak self] _ in
            self?.animatorForCurrentTransition = nil
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animatorForCurrentTransition = animator
        return animator
    }
    
    func createPopAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let containerView = transitionContext.containerView
        let returningView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let fromVC = transitionContext.viewController(forKey: .from)!
        
        let parameters = UICubicTimingParameters(animationCurve: .easeInOut)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
        
        if fromVC is VKImageListViewController {
            animator.addAnimations {
                fromView.frame.origin.x += 1000
                containerView.insertSubview(returningView, belowSubview: fromView)
            }
        } else {
//            fromView.backgroundColor = UIColor(white: 1, alpha: 1)
            
            animator.addAnimations {
//                fromView.backgroundColor = UIColor(white: 1, alpha: 0)
                containerView.insertSubview(returningView, belowSubview: fromView)
            }
        }
        
        animator.addCompletion { [weak self] _ in
            
            self?.animatorForCurrentTransition = nil
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animatorForCurrentTransition = animator
        return animator
    }
}

