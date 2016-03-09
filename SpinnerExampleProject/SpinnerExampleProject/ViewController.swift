//
//  ViewController.swift
//  DBSpinnerActivityView
//
//  Created by David Bemerguy on 21/02/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

import UIKit
import SpinnerActivityView

class ViewController: UIViewController {
    
    @IBOutlet var myView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let spinner = SpinnerActivityView()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.myView!.addSubview(spinner)
            spinner.startAnimation()            
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            spinner.stopAnimation()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

