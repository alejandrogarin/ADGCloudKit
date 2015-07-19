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
import CloudKit

public protocol CloudContextDelegate {
    func cloudContextWillStartRequest(context: CloudContext)
    func cloudContextDidEndRequest(context: CloudContext)
}

public class CloudContext {
    
    private let database: CKDatabase
    
    public var delegate: CloudContextDelegate?
    
    public init(usingDatabase database:CKDatabase) {
        self.database = database
    }
    
    deinit {
        //NSLog("%@:%@", String(self), __FUNCTION__)
    }
    
    public func insertRecord(newRecord: CKRecord, completionHandler: (record: CKRecord?, error: NSError?) -> Void) {
        delegate?.cloudContextWillStartRequest(self)
        self.database.saveRecord(newRecord) { [unowned self] (record: CKRecord?, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.cloudContextDidEndRequest(self)
                completionHandler(record: record, error: error)
            }
        }
    }
    
    public func updateRecord(record: CKRecord, completionHandler: (record: CKRecord?, error: NSError?) -> Void) {
        delegate?.cloudContextWillStartRequest(self)
        self.database.saveRecord(record) { [unowned self] (updatedRecord, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.cloudContextDidEndRequest(self)
                completionHandler(record: updatedRecord, error: error)
            }
        }
    }
    
    public func deleteRecordWithID(recordID recordID: CKRecordID, completionHandler: (error: NSError?) -> Void) {
        delegate?.cloudContextWillStartRequest(self)
        self.database.deleteRecordWithID(recordID, completionHandler: { [unowned self] (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.cloudContextDidEndRequest(self)
                completionHandler(error: error)
            }
        })
    }
    
    public func findRecordWithID(recordID: CKRecordID, completionHandler: (record: CKRecord?, error: NSError?) -> Void) {
        delegate?.cloudContextWillStartRequest(self)
        self.database.fetchRecordWithID(recordID) { [unowned self] (record, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.cloudContextDidEndRequest(self)
                completionHandler(record: record, error: error)
            }
        }
    }
    
    public func findEntityWithName(entityName : String, var predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, resultsLimit: Int?, completionHandler: (records: [CKRecord], cursor:CKQueryCursor?, error: NSError?) -> Void) {
        if (predicate == nil) {
            predicate = NSPredicate(value: true)
        }
        
        var resultRecordIDs: [CKRecord] = []
        
        let query = CKQuery(recordType: entityName, predicate: predicate!)
        query.sortDescriptors = sortDescriptors
        let queryOperation = CKQueryOperation(query: query)
        if let resultsLimit = resultsLimit {
            queryOperation.resultsLimit = resultsLimit
        }
        queryOperation.queryCompletionBlock = { [unowned self] (cursor:CKQueryCursor?, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.cloudContextDidEndRequest(self)
                completionHandler(records: resultRecordIDs, cursor: cursor, error: error)
            }
        }
        queryOperation.recordFetchedBlock = { (record) in
            resultRecordIDs.append(record)
        }
        delegate?.cloudContextWillStartRequest(self)
        self.database.addOperation(queryOperation)
    }
    
    public func findNextWithCursor(cursor: CKQueryCursor, resultsLimit: Int?, completionHandler: (records: [CKRecord], cursor:CKQueryCursor?, error: NSError?) -> Void) {
        var resultRecordIDs: [CKRecord] = []
        let queryOperation = CKQueryOperation(cursor: cursor)
        if let resultsLimit = resultsLimit {
            queryOperation.resultsLimit = resultsLimit
        }
        queryOperation.queryCompletionBlock = { [unowned self] (cursor:CKQueryCursor?, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.cloudContextDidEndRequest(self)
                completionHandler(records: resultRecordIDs, cursor: cursor, error: error)
            }
        }
        queryOperation.recordFetchedBlock = { (record) in
            resultRecordIDs.append(record)
        }
        delegate?.cloudContextWillStartRequest(self)
        self.database.addOperation(queryOperation)
    }
}