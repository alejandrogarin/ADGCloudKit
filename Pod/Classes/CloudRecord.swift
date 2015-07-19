//
//  CloudRecord.swift
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
import CloudKit

public class CloudRecord: NSObject {
    public var recordID: String?
    public var zoneID: String?
    
    public var entityName:String? {
        get {
            let components = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".")
            if components.count >= 2 {
                return components[1]
            } else {
                return nil
            }
        }
    }
    
    public func asCKRecord() -> CKRecord? {
        
        guard let recordID = self.recordID, entityName = self.entityName else {
            return nil
        }
        return CKRecord(recordType: entityName, recordID: CKRecordID(recordName: recordID))
    }
    
    public func asCKReferenceWithDeleteAction() -> CKReference? {
        guard let record = self.asCKRecord() else {
            return nil
        }
        return CKReference(record: record, action: CKReferenceAction.DeleteSelf)
    }
    
    public func asCKReferenceWithoutAction() -> CKReference? {
        guard let record = self.asCKRecord() else {
            return nil
        }
        return CKReference(record: record, action: CKReferenceAction.None)
    }
    
    public func asCKReferenceWithAction(action: CKReferenceAction) -> CKReference? {
        guard let record = self.asCKRecord() else {
            return nil
        }
        return CKReference(record: record, action: action)
    }
}