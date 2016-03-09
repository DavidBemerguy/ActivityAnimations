//
//  DBSpinnerActivityView.swift
//  DBSpinnerActivityView
//
//  Created by David Bemerguy on 21/02/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//
//  This is a simple spinning animation
//  The ideia is to create a blow effect with a circle where it grows from SpinnerInitialRadius to SpinnerOnAnimationPickRadius, then returning its size to SpinnerFinalRadius
//  All this with a smooth animation provided by the CoreAnimation API
//
//  This software is provided as-is under the DWTFYW license (do what you want from it)
//

import Foundation
import UIKit

public class DBSpinnerActivityView : UIView{
    
    // MARK: - Private constants
    
    private let SpinnerSize = CGSizeMake(40, 40)
    private let SpinnerInitialRadius: CGFloat = 9.0
    private let SpinnerOnAnimationPickRadius: CGFloat = 23.0
    private let SpinnerFinalRadius: CGFloat = 20.0
    private let SpinnerLineWidth: CGFloat = 4.0
    private let ShadowOpacity: Float = 1.0

    private let SpinAnimationDuration: CFTimeInterval = 1.0
    private let BlowAnimationDuration: CFTimeInterval = 0.3
    private let FadeOutAnimationDuration: CFTimeInterval = 0.3
    
    // MARK: - Private vars
    
    private var circleMarginInitialFromSpinnerContainer : CGFloat?
    private var circleMarginOnAnimationPickFromSpinnerContainer : CGFloat?
    private var circleMarginFinalFromSpinnerContainer : CGFloat?
    
    private var spinnerContentView: UIView?
    private var shadowDummyView: UIView?
    private var spinnerContainerLayer: CAShapeLayer?
    private var circleLayer: CAShapeLayer?
    private var shadowLayer: CAShapeLayer?
    
    // MARK: - Init
    
    /**
    Initialize the view on the center of its superview
    
    - parameter center: The center of the superview
    
    - returns: A new instance of the view
    */
    init(){
        super.init(frame: CGRectZero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        
        if (newSuperview != nil){
            var rect: CGRect = CGRectZero
            rect.size = SpinnerSize
            rect.origin.x = newSuperview!.frame.size.width/2 - SpinnerSize.width/2
            rect.origin.y = newSuperview!.frame.size.height/2 - SpinnerSize.height/2
            self.frame = rect
            
            initGlobalVars()
            initViews()
        }
    }

    private func initGlobalVars(){
        
        let marginRatio: CGFloat = 0.2 // Give the circle some margin from the views borders
        
        self.circleMarginInitialFromSpinnerContainer = (SpinnerInitialRadius * 2) * marginRatio
        self.circleMarginOnAnimationPickFromSpinnerContainer = (SpinnerOnAnimationPickRadius * 2) * marginRatio
        self.circleMarginFinalFromSpinnerContainer = (SpinnerFinalRadius * 2) * marginRatio
    }
    
    private func initViews(){
        
        self.spinnerContentView = self.createSpinnerContentView() // An invisible view that holds all the magic
        self.shadowDummyView = self.createShadowDummyView() // An invisible view that holds the shadow below the spinner
        self.shadowLayer = self.createShadowLayer() // The shadow on the bottom of the view
        self.spinnerContainerLayer = self.createSpinnerContainerLayer() // A white circle where the spinner runs
        self.circleLayer = self.createCircleLayer() // The spinner itself
        
        let spinnerCV = self.spinnerContentView!
        addSubview(spinnerCV)
        insertSubview(self.shadowDummyView!, belowSubview: spinnerCV)
        self.shadowDummyView!.layer.addSublayer(self.shadowLayer!)
        spinnerCV.layer.addSublayer(self.spinnerContainerLayer!)
        spinnerCV.layer.addSublayer(self.circleLayer!)
    }
    
    // MARK: - Public
    
    /*
    *  We animate the bezier path of the spinner animates from 0 trough 90 degrees and back
    *  The spinnerContentView is rotated and it gives the impression that the spinner makes a 360 degrees spin
    */
    
    public func startAnimation(){
        
        assert(self.superview != nil, "Must be added to a view before starting animating")
        
        let animationKey = "blowAnimation"
        let spinnerContainerAnimation = self.createSpinnerContainerAnimation()
        
        // First we add all the animations, the begin, on pick and final state
        self.spinnerContainerLayer!.addAnimation(spinnerContainerAnimation, forKey: animationKey)
        self.circleLayer!.addAnimation(self.createCircleLayerAnimation(), forKey: animationKey)
        self.shadowLayer!.addAnimation(spinnerContainerAnimation, forKey: animationKey)
        
        // Then we set the final state as the path to be animated infinitly
        self.spinnerContainerLayer!.path = self.createSpinnerBezierPathWithOval(SpinnerFinalRadius)
        self.circleLayer!.path = self.createCircleBezierPathWithArc(SpinnerFinalRadius, margin: self.circleMarginFinalFromSpinnerContainer!)
        
        // After that we start the spin animation and the content view rotation
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(BlowAnimationDuration * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            let animatedCircleLayer = self.createAnimatedCircleLayer()
            self.spinnerContentView!.layer.addSublayer(animatedCircleLayer)
            animatedCircleLayer.addAnimation(self.createStrokeAnimation(), forKey: nil)
            self.spinnerContentView!.layer.addAnimation(self.createRotationAnimation(), forKey: nil)
        }
    }
    
    public func stopAnimation(){
        UIView.animateWithDuration(FadeOutAnimationDuration, animations: { () -> Void in
            self.shadowDummyView!.alpha = 0
            self.spinnerContentView!.alpha = 0;
            }) { (animationDidFinish) -> Void in
                if (animationDidFinish){
                    self.removeFromSuperview()
                }
        }
    }
    
    // MARK: - Create views helpers
    
    private func createSpinnerContentView()->UIView{
        var rect = CGRectZero
        rect.origin = CGPointMake(self.frame.size.width/2 - SpinnerFinalRadius, self.frame.size.height/2 - SpinnerFinalRadius)
        rect.size = SpinnerSize
        let spinnerContentView = UIView(frame: rect)
        spinnerContentView.backgroundColor = UIColor.clearColor()
        return spinnerContentView
    }
    
    func createShadowDummyView()->UIView{
        let shadowDummyView = UIView(frame: self.spinnerContentView!.frame)
        shadowDummyView.backgroundColor = UIColor.clearColor()
        return shadowDummyView
    }
    
    // MARK: - Create layers helpers
    
    func createShadowLayer()->CAShapeLayer{
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = UIColor.grayColor().CGColor
        shadowLayer.shadowColor = UIColor.grayColor().CGColor
        shadowLayer.shadowOpacity = ShadowOpacity
        shadowLayer.shadowOffset = CGSizeMake(0,4)
        shadowLayer.path = self.createSpinnerBezierPathWithOval(SpinnerFinalRadius)
        return shadowLayer
        
    }
    
    func createSpinnerContainerLayer()->CAShapeLayer{
        let spinnerContainerLayer = CAShapeLayer()
        spinnerContainerLayer.fillColor = UIColor.whiteColor().CGColor
        return spinnerContainerLayer
    }
    
    func createCircleLayer()->CAShapeLayer{
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.lineWidth = SpinnerLineWidth
        circleLayer.strokeColor = UIColor(white: 0.75, alpha: 1.0).CGColor
        return circleLayer
    }
    
    func createAnimatedCircleLayer()->CAShapeLayer{
        let animatedCircleLayer = CAShapeLayer()
        animatedCircleLayer.lineWidth = SpinnerLineWidth
        animatedCircleLayer.fillColor = UIColor.clearColor().CGColor
        animatedCircleLayer.lineCap = kCALineJoinRound
        animatedCircleLayer.path = UIBezierPath(arcCenter: CGPointMake(self.spinnerContentView!.frame.size.width/2, self.spinnerContentView!.frame.size.height/2), radius: SpinnerFinalRadius - circleMarginFinalFromSpinnerContainer!, startAngle: degressToRadians(266), endAngle: degressToRadians(355), clockwise: true).CGPath
        animatedCircleLayer.strokeColor = UIColor.redColor().CGColor
        animatedCircleLayer.frame = self.spinnerContentView!.frame
        
        return animatedCircleLayer
    }
    
    // MARK: Create animations layer
    
    func createStrokeAnimation()->CAKeyframeAnimation{
        let strokeAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeAnimation.values = [0,1,0.8,0]
        strokeAnimation.duration = SpinAnimationDuration
        strokeAnimation.repeatCount = Float.infinity
        return strokeAnimation
    }
    
    func createRotationAnimation()->CABasicAnimation{
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = M_PI*2
        rotationAnimation.duration = SpinAnimationDuration
        rotationAnimation.repeatCount = Float.infinity
        return rotationAnimation
    }
    
    func createSpinnerContainerAnimation()->CAKeyframeAnimation{
        let spinnerContainerAnimation = CAKeyframeAnimation(keyPath: "path")
        spinnerContainerAnimation.values = self.createSpinnerOvalBezierPaths()
        spinnerContainerAnimation.duration = BlowAnimationDuration
        return spinnerContainerAnimation
    }
    
    func createCircleLayerAnimation()->CAKeyframeAnimation{
        let circleLayerAnimation = CAKeyframeAnimation(keyPath: "path")
        circleLayerAnimation.values = createCircleArcBezierPaths()
        circleLayerAnimation.duration = BlowAnimationDuration
        return circleLayerAnimation
    }
    
    // MARK: - General helpers
    
    func createSpinnerBezierPathWithOval(radius: CGFloat)->CGPathRef{
        return UIBezierPath(ovalInRect: CGRectMake(self.spinnerContentView!.frame.size.width/2 - radius, self.spinnerContentView!.frame.size.height/2 - radius, radius*2, radius*2)).CGPath
    }
    
    func createCircleBezierPathWithArc(radius: CGFloat, margin: CGFloat)->CGPathRef{
        return UIBezierPath(arcCenter: CGPointMake(self.spinnerContentView!.frame.size.width/2, self.spinnerContentView!.frame.size.height - SpinnerFinalRadius), radius: radius-margin, startAngle: 0, endAngle: degressToRadians(360), clockwise: true).CGPath
    }
    
    func createSpinnerOvalBezierPaths()->[CGPathRef]{
        return [createSpinnerBezierPathWithOval(SpinnerInitialRadius),
                createSpinnerBezierPathWithOval(SpinnerOnAnimationPickRadius),
                createSpinnerBezierPathWithOval(SpinnerFinalRadius)]
    }
    
    func createCircleArcBezierPaths()->[CGPathRef]{
        return [createCircleBezierPathWithArc(SpinnerInitialRadius, margin:circleMarginInitialFromSpinnerContainer!),
                createCircleBezierPathWithArc(SpinnerOnAnimationPickRadius, margin: circleMarginOnAnimationPickFromSpinnerContainer!),
                createCircleBezierPathWithArc(SpinnerFinalRadius, margin: circleMarginFinalFromSpinnerContainer!)]
    }
    
    func degressToRadians(angle: Double)->CGFloat{
        return CGFloat(((angle) / 180.0 * M_PI))
    }
}