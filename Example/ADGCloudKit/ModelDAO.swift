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

import Foundation
import ADGCloudKit
import CloudKit

class BaseDAO<T: CloudRecord>: CloudObjectDAO<T>, CloudContextDelegate {
    
    let loadingView = UIView()
    
    init() {
        let context = CloudContext(usingDatabase: CKContainer.defaultContainer().privateCloudDatabase)
        super.init(usingContext: context)
        context.delegate = self
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        self.loadingView.alpha = 1.0
    }
    
    func cloudContextWillStartRequest(context: CloudContext) {
        UIViewController.adg_showLoadingIndicatorView(self.loadingView)
    }
    
    func cloudContextDidEndRequest(context: CloudContext) {
        UIViewController.adg_removeLoadingIndicatorView(self.loadingView)
    }
}

class ParentDAO: BaseDAO<Parent> {
    
}

class ChildDAO: BaseDAO<Child> {
    
}