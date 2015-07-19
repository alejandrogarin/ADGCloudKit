//
//  CloudMapDAO.swift
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

public class CloudMapDAO {
    
    public enum MapKeys: String {
        case RecordName = "cloudkit_record_name"
        case ZoneName = "cloudkit_zone_name"
    }
    
    private let context:CloudContext
    
    public var delegate: CloudContextDelegate? {
        get {
            return self.context.delegate
        }
        set(newDelegate) {
            self.context.delegate = newDelegate
        }
    }
    
    init(usingContext context: CloudContext) {
        self.context = context
    }
    
    init() {
        self.context = CloudContext(usingDatabase: CKContainer.defaultContainer().privateCloudDatabase)
    }
    
    public func insertEntity(entityName: String, withMap map: [String: CKRecordValue], completionHandler: (map: [String: CKRecordValue]?, error: NSError?) -> Void) {
        
        let newRecord = CKRecord(recordType: entityName)
        for key in map.keys {
            newRecord[key] = map[key]
        }
        
        self.context.insertRecord(newRecord) { (record, error) -> Void in
            
            if error != nil {
                completionHandler(map: nil, error: error)
            } else {
                completionHandler(map: self.createDictionaryFromRecord(record), error: error)
            }
        }
    }
    
    public func updateWithRecordID(recordID: CKRecordID, map: [String: CKRecordValue], completionHandler: (resultMap: [String: CKRecordValue]?, error: NSError?) -> Void) {
        
        self.context.findRecordWithID(recordID) { (record, error) -> Void in
            if error != nil {
                completionHandler(resultMap: nil, error: error)
            } else {
                guard let record = record else {
                    completionHandler(resultMap: nil, error: NSError(domain: String(self), code: 1, userInfo: ["NSLocalizedDescriptionKey":"The record with the provided CKRecordID couldn't be found"]))
                    return
                }
                for key in map.keys {
                    record[key] = map[key]
                }
                self.context.updateRecord(record, completionHandler: { (record, error) -> Void in
                    completionHandler(resultMap: self.createDictionaryFromRecord(record), error: error)
                })
            }
        }
    }
    
    public func deleteWithRecordName(recordName: String, completionHandler: (error: NSError?) -> Void) {
        
        let recordID: CKRecordID = CKRecordID(recordName: recordName)
        self.context.deleteRecordWithID(recordID: recordID, completionHandler: completionHandler)
    }
    
    public func findRowsWithEntityName(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, resultsLimit: Int?, completionHandler: (rows: [[String: CKRecordValue]], cursor: CKQueryCursor?, error: NSError?) -> Void) {
        
        self.context.findEntityWithName(entityName, predicate: predicate, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit) { (records, cursor, error) -> Void in
            self.manageListCompletionHandlerData(records, cursor: cursor, error: error, completionHandler: completionHandler)
        }
    }
    
    public func findNextRowsWithCursor(cursor: CKQueryCursor, resultsLimit: Int?, completionHandler: (rows: [[String: CKRecordValue]], cursor: CKQueryCursor?, error: NSError?) -> Void) {
        
        self.context.findNextWithCursor(cursor, resultsLimit: resultsLimit) { (records, cursor, error) -> Void in
            self.manageListCompletionHandlerData(records, cursor: cursor, error: error, completionHandler: completionHandler)
        }
    }
    
    //MARK: - Private API
    
    private func manageListCompletionHandlerData(records: [CKRecord], cursor:CKQueryCursor?, error: NSError?, completionHandler: (rows: [[String: CKRecordValue]], cursor: CKQueryCursor?, error: NSError?) -> Void) {
        
        if (error != nil) {
            completionHandler(rows: [], cursor: cursor, error: error)
        } else {
            var newArray:[[String: CKRecordValue]] = []
            for cloudRecord:CKRecord in records {
                if let row = self.createDictionaryFromRecord(cloudRecord) {
                    newArray.append(row)
                } else {
                    newArray.append([:])
                }
            }
            completionHandler(rows: newArray, cursor: cursor, error: error)
        }
    }
    
    private func createDictionaryFromRecord(record: CKRecord?) -> [String: CKRecordValue]? {
        
        guard let validRecord = record else {
            return nil
        }
        
        var map: [String: CKRecordValue] = [:]
        map[MapKeys.RecordName.rawValue] = validRecord.recordID.recordName
        map[MapKeys.ZoneName.rawValue] = validRecord.recordID.zoneID.zoneName
        for key:String in validRecord.allKeys() {
            map[key] = validRecord[key]
        }
        return map
    }
}