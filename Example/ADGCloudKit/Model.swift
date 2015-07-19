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
import CoreLocation

@objc class Parent: CloudRecord, CustomDebugStringConvertible {
    var stringAttribute: String?
    var doubleAttribute: NSNumber?
    var intAttribute: NSNumber?
    var dateTimeAttribute: NSDate?
    var locationAttribute: CLLocation?
    var stringListAttribute: NSArray?
    
    override var debugDescription: String {
        return "stringAttribute: \(stringAttribute)\n" +
        "doubleAttribute: \(doubleAttribute)\n" +
        "intAttribute: \(intAttribute)\n" +
        "dateTimeAttribute:\(dateTimeAttribute)\n" +
        "locationAttribute: \(locationAttribute)\n" +
        "stringListAttribute: \(stringListAttribute)"
    }
}

@objc class Child: CloudRecord {
    var refToParent: CKReference?
    var stringAttribute: String?
    
    override var debugDescription: String {
        return "stringAttribute: \(stringAttribute)\n" +
        "refToParent: \(refToParent)\n"
    }
}