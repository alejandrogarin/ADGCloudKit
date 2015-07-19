//
//  CloudContext.swift
//  ADGCloudKit
//
//  Created by Alejandro Diego Garin

// The MIT License (MIT)
//
// Copyright (c) 2015 Alejandro Garin @alejandrogarin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UIViewController {
    
    func adg_randomStringWithLength(len: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for (var i=0; i < len; i++) {
            let length = UInt32(letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString as String
    }
    
    /*!
    * @brief var aRandomInt = adg_random(-500...100)
    */
    func adg_random(range: Range<Int> ) -> Int {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
    
    func adg_showError(error: NSError) {
        let errorDesc = error.localizedDescription;
        let alertController: UIAlertController = UIAlertController(title: "Error", message: errorDesc, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func adg_showError(message message: String) {
        let alertController: UIAlertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func adg_window() -> UIWindow {
        let arrayOfWindows = UIApplication.sharedApplication().windows;
        for aWindow in arrayOfWindows {
            if (aWindow.windowLevel == UIWindowLevelNormal) {
                return aWindow;
            }
        }
        return UIApplication.sharedApplication().keyWindow!
    }
    
    class func adg_topMostController() -> UIViewController? {
        var topWindow = UIApplication.sharedApplication().keyWindow!
        if (topWindow.windowLevel != UIWindowLevelNormal) {
            topWindow = self.adg_window()
        }
        
        var topController = topWindow.rootViewController;
        if (topController == nil) {
            if let topWindowFromDelegate = UIApplication.sharedApplication().delegate?.window {
                if let actualWindowFromDelegate = topWindowFromDelegate {
                    topWindow = actualWindowFromDelegate
                }
            }
            topController = topWindow.rootViewController
        }
        
        if let actualTopController = topController {
            while ((actualTopController.presentedViewController) != nil) {
                topController = actualTopController.presentedViewController
            }
        }
        
        if let actualTopController = topController {
            if let navigation = actualTopController as? UINavigationController, actualTopController = navigation.viewControllers.last  {
                while ((actualTopController.presentedViewController) != nil) {
                    topController = actualTopController.presentedViewController
                }
            }
        }
        return topController
    }
    
    class func adg_constraintAddTopLeftBottomRight(fromView view:UIView, toSuperview superview: UIView) {
        let top = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        superview.addConstraints([top, left, right, bottom])
    }
    
    class func adg_constraintCenterXY(fromView view: UIView, toSuperView superview: UIView) {
        let centerX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        let centerY = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        superview.addConstraints([centerX, centerY])
    }
    
    class func adg_showLoadingIndicatorView(loadingView: UIView) {
        if let controller = UIViewController.adg_topMostController(), view = controller.view {
            view.addSubview(loadingView)
            UIViewController.adg_constraintAddTopLeftBottomRight(fromView: loadingView, toSuperview: view)
            
            let indicator = UIActivityIndicatorView();
            indicator.startAnimating()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            loadingView.addSubview(indicator)
            
            UIViewController.adg_constraintCenterXY(fromView: indicator, toSuperView: loadingView)
        }
    }
    
    class func adg_removeLoadingIndicatorView(loadingView: UIView) {
        loadingView.removeFromSuperview()
    }
}