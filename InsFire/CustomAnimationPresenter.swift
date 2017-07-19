//
//  CustomAnimationPresenter.swift
//  InsFire
//
//  Created by TG on 19/7/17.
//  Copyright © 2017 TG. All rights reserved.
//

import UIKit


class CustomAnimationPresenter: NSObject,UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Custom transition animation code logic
        let containerView = transitionContext.containerView
        
        // HomeControllerView slides opposite to fade out
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        guard let toView = transitionContext.view(forKey: .to) else { return }

        containerView.addSubview(toView)
        
        let startingFrame = CGRect(x: toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startingFrame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            
            // animation goes here
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
        }) { (_) in
            // when animation completed, notify by set completetrans to true
            transitionContext.completeTransition(true)
        }
    }
    
}
    
