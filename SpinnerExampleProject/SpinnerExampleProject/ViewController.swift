//
//  ViewController.swift
//  DBSpinnerActivityView
//
//  Created by David Bemerguy on 21/02/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

import UIKit
import SpinnerActivityView
import DotsActivityView

class ViewController: UIViewController {
    
    @IBOutlet var spinnerView: UIView?
    @IBOutlet var dotsView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let spinner = SpinnerActivityView()
        let dots = DotsActivityView()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.spinnerView!.addSubview(spinner)
            self.dotsView!.addSubview(dots)
            spinner.startAnimation()
            dots.startAnimation()
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            spinner.stopAnimation()
            dots.stopAnimation()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

