//
//  CloudObjectDAO.swift
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

public enum ADGCloudKitError : ErrorType {
    case CursorNotAvailable
    case InvalidRecordId
}

public class CloudObjectDAO<T: CloudRecord> {
    
    public var delegate: CloudContextDelegate? {
        get {
            return self.mapDAO.delegate
        }
        set(newDelegate) {
            self.mapDAO.delegate = newDelegate
        }
    }
    
    private var currentCursor: CKQueryCursor?
    
    private var mapDAO = CloudMapDAO(usingContext: CloudContext(usingDatabase: CKContainer.defaultContainer().privateCloudDatabase))
    
    public var entityName:String {
        return self.guessEntityName()
    }
    
    public init(usingDatabase database: CKDatabase) {
        self.mapDAO = CloudMapDAO(usingContext: CloudContext(usingDatabase: database))
    }
    
    deinit {
        self.currentCursor = nil
    }
    
    public func insertObject(object: T, completionHandler: (object: T?, error: NSError?) -> Void) {
        let map: [String: CKRecordValue] = self.createDictionaryFromObject(object)
        self.mapDAO.insertEntity(self.entityName, withMap: map) { (map, error) -> Void in
            self.manageSimpleCompletionHandlerWithMap(map, error: error, completionHandler: completionHandler)
        }
    }
    
    public func updateObject(record: T, completionHandler: (object: T?, error: NSError?) -> Void) throws {
        guard let recordIdentifier = record.recordName else {
            throw ADGCloudKitError.InvalidRecordId
        }

        let map: [String: CKRecordValue] = self.createDictionaryFromObject(record)
        let recordID: CKRecordID = CKRecordID(recordName: recordIdentifier)
        
        self.mapDAO.updateWithRecordID(recordID, map: map) { (resultMap, error) -> Void in
            self.manageSimpleCompletionHandlerWithMap(resultMap, error: error, completionHandler: completionHandler)
        }
    }
    
    public func deleteObject(object: T, completionHandler: (error: NSError?) -> Void) throws {
        guard let recordIdentifier = object.recordName else {
            throw ADGCloudKitError.InvalidRecordId
        }
        
        self.mapDAO.deleteWithRecordName(recordIdentifier) { (error) -> Void in
            completionHandler(error: error)
        }
    }
    
    public func findNextObjectsWithLimit(resultsLimit: Int?, completionHandler: (objects: [T]?, error: NSError?) -> Void) {
        guard let cursor = self.currentCursor else {
            completionHandler(objects:nil, error: nil)
            return
        }
        self.mapDAO.findNextRowsWithCursor(cursor, resultsLimit: resultsLimit) { (rows, cursor, error) -> Void in
            self.manageListCompletionHandlerWithRowsOfMap(rows, cursor: cursor, error: error, completionHandler: completionHandler)
        }
    }
    
    public func findObjectsWithPredicate(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, resultsLimit: Int?, completionHandler: (objects: [T]?, error: NSError?) -> Void) {
        self.mapDAO.findRowsWithEntityName(self.entityName, predicate: predicate, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit) { (rows, cursor, error) -> Void in
            self.manageListCompletionHandlerWithRowsOfMap(rows, cursor: cursor, error: error, completionHandler: completionHandler)
        }
    }
    
    public func findAllObjectsWithSortDescriptors(sortDescriptors: [NSSortDescriptor]?, completionHandler: (objects: [T]?, error: NSError?) -> Void) {
        self.findObjectsWithPredicate(nil, sortDescriptors: sortDescriptors, resultsLimit: nil, completionHandler: completionHandler)
    }
    
    public func findAllObjects(completionHandler: (objects: [T]?, error: NSError?) -> Void) {
        self.findObjectsWithPredicate(nil, sortDescriptors: nil, resultsLimit: nil, completionHandler: completionHandler)
    }
    
    //MARK: - Private API
    
    private func createObject() -> T? {
        let entityName = String(T.self)
        let classCreator = ClassCreatorBridge()
        return classCreator.createClassFromName(entityName) as? T
    }
    
    private func manageSimpleCompletionHandlerWithMap(map: [String: CKRecordValue]?, error: NSError?, completionHandler: (object: T?, error: NSError?) -> Void) {
        if error != nil {
            completionHandler(object: nil, error: error)
            return
        }
        guard let newObject = self.createObject(), map = map else {
            completionHandler(object: nil, error: error)
            return
        }
        self.fillObject(object: newObject, withMap: map)
        completionHandler(object: newObject, error: error)
    }
    
    private func manageListCompletionHandlerWithRowsOfMap(rowsOfMap: [[String: CKRecordValue]], cursor:CKQueryCursor?, error: NSError?, completionHandler: (records: [T]?, error: NSError?) -> Void) {
        self.currentCursor = cursor
        if (error != nil) {
            completionHandler(records:nil, error: error)
            return
        }
        var newArray:[T] = []
        for map:[String: CKRecordValue] in rowsOfMap {
            
            guard let newObject = self.createObject() else {
                continue
            }
            self.fillObject(object: newObject, withMap:map)
            newArray.append(newObject)
        }
        completionHandler(records: newArray, error: error)
    }
    
    private func fillObject(object newObject: T, withMap map: [String: CKRecordValue]) {
        newObject.recordName = map[CloudMapDAO.MapKeys.RecordName.rawValue] as? String
        newObject.zoneName = map[CloudMapDAO.MapKeys.ZoneName.rawValue] as? String
        newObject.ownerName = map[CloudMapDAO.MapKeys.OwnerName.rawValue] as? String
        
        let mirrorObject = Mirror(reflecting: newObject)
        for children in mirrorObject.children {
            if let index = children.label {
                let value = map[index]
                if let value = value {
                    newObject.setValue(value, forKey: index)
                }
            }
        }
    }
    
    private func createDictionaryFromObject(object: T) -> [String: CKRecordValue] {
        var map: [String: CKRecordValue] = [:]
        let mirrorObject = Mirror(reflecting: object)
        for children in mirrorObject.children {
            if let index = children.label {
                map[index] = self.unwrap(children.value)
            }
        }
        return map
    }
    
    private func unwrap(any:Any) -> CKRecordValue? {
        let mirror = Mirror(reflecting: any)
        if (mirror.children.count == 0) {
            return nil
        }
        if let children = mirror.children.first {
            return children.value as? CKRecordValue
        }
        return nil
    }
    
    private func guessEntityName() -> String {
        var entityName = String(T.self)
        let components = entityName.componentsSeparatedByString(".")
        if (components.count == 1) {
            return components[0]
        } else if components.count >= 2 {
            return components[1]
        } else if components.count >= 3 {
            entityName = components[2]
            entityName.stringByReplacingOccurrencesOfString(">", withString: "")
            return components[0]
        } else {
            return ""
        }
    }
}

