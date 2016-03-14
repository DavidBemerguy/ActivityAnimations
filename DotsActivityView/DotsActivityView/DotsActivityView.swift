//
//  DotsActivityView.swift
//  DotsActivityView
//
//  Created by David Bemerguy on 10/03/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//
//  This is a simple dots animation
// 
//  All this with a smooth animation provided by the CoreAnimation API
//
//  This software is provided as-is under the DWTFYW license (do what you want from it)
//

import Foundation
import UIKit

public class DotsActivityView : UIView{

    private let NumberOfDots = 5
    private let DotsFrameHeight: CGFloat = 30
    private let DotsRadius: CGFloat = 12
    private let ScaleInValue: CGFloat = 0.2
    private let ScaleOutValue: CGFloat = 1.0
    private let DotsAnimationDuration: CFTimeInterval = 0.7
    private let AnimationDelayValue = 0.25
    private let FadeOutAnimationDuration: CFTimeInterval = 0.3
    
    // MARK: - Init
    
    /**
    Initialize the view on the center of its superview
    
    - parameter center: The center of the superview
    
    - returns: A new instance of the view
    */
    public init(){
        super.init(frame: CGRectZero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        
        if (newSuperview != nil){
            var rect: CGRect = CGRectZero
            rect.size.width = CGFloat(NumberOfDots) * DotsRadius
            rect.size.height = DotsFrameHeight
            rect.origin.x = newSuperview!.frame.size.width/2 - rect.width/2
            rect.origin.y = newSuperview!.frame.size.height/2 - rect.height/2
            self.frame = rect
            
            for var index = 0; index < NumberOfDots; ++index{
                let layer = CAShapeLayer()
                layer.frame = self.layerFrame(index)
                layer.fillColor = UIColor.clearColor().CGColor
                let cornerRadius = layer.bounds.size.width / 2.0
                layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: cornerRadius).CGPath
                self.layer.addSublayer(layer)
            }
        }
    }
    
    // MARK: - Public
    
    /**
        The animation here has a little nuance:
        We embbed the big to small animation and the color changing animation at the dots and then start a group animation for it. On both methods we set the duration of the animation
        It gives the ability for the animation to animate all the dots and then wait until the last one finishes until the first dot starts a new animation
    */
    public func startAnimation(){
        for (index, layer) in self.layer.sublayers!.enumerate(){
            let start = CFTimeInterval(index) * DotsAnimationDuration * AnimationDelayValue
            self.addAnimations(layer, delay: start)
        }
    }
    
    public func stopAnimation(){
        UIView.animateWithDuration(FadeOutAnimationDuration, animations: { () -> Void in
            self.alpha = 0;
            }) { (animationDidFinish) -> Void in
                if (animationDidFinish){
                    self.removeFromSuperview()
                }
        }
    }
    
    // MARK: Animation
    
    private func createColorAnimation()->CAKeyframeAnimation{
        return self.createKeyFrameAnimation("fillColor", fromValue: UIColor.blackColor().CGColor, toValue: UIColor.redColor().CGColor)
    }
    
    private func createZoomAnimation()->CAKeyframeAnimation{
        return self.createKeyFrameAnimation("transform.scale", fromValue: ScaleInValue, toValue: ScaleOutValue)
    }
    
    // MARK: Helpers
    
    private func createKeyFrameAnimation(key: String, fromValue: AnyObject, toValue: AnyObject)->CAKeyframeAnimation{
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: key)
        keyFrameAnimation.values = [fromValue, toValue, fromValue]
        keyFrameAnimation.duration = DotsAnimationDuration
        keyFrameAnimation.removedOnCompletion = false
        keyFrameAnimation.fillMode = kCAFillModeForwards
        return keyFrameAnimation
    }
    
    private func addAnimations(layer: CALayer, delay: CFTimeInterval){
        let zoomAnimation = self.createZoomAnimation()
        let colorAnimation = self.createColorAnimation()
        
        let dotGroup = CAAnimationGroup()
        dotGroup.repeatCount = Float.infinity
        dotGroup.animations = [zoomAnimation, colorAnimation]
        dotGroup.beginTime = CACurrentMediaTime() + delay
        dotGroup.duration = DotsAnimationDuration * 2
        layer.addAnimation(dotGroup, forKey: "dotAnimation")
    }
    
    private func layerFrame(index: Int)->CGRect{
        let xOffset: CGFloat = self.bounds.size.width / CGFloat(NumberOfDots)
        let enclosingFrame = CGRectMake(xOffset * CGFloat(index), 0, DotsRadius, DotsFrameHeight)
        let xInset: CGFloat = (enclosingFrame.size.width - DotsRadius) / 2
        let yInset: CGFloat = (enclosingFrame.size.height - DotsRadius) / 2
        let circleFrame: CGRect = CGRectInset(enclosingFrame, xInset, yInset)
        
        return circleFrame
        
    }
}
