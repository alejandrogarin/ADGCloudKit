//
//  CloudSubscription.swift
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

public class CloudSubscription {
    private let database: CKDatabase
    
    init(usingDatabase database:CKDatabase) {
        self.database = database
    }

    public func createSubscriptionWithID(subscriptionID: String, entityName: String, predicate: NSPredicate?, completionHandler: (subscription: CKSubscription?, error: NSError?) -> Void) {
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = ""
        self.createSubscriptionWithID(subscriptionID, notificationInfo: notificationInfo, entityName: entityName, predicate: predicate, completionHandler: completionHandler)
    }
    
    public func createSubscriptionWithID(subscriptionID: String, notificationInfo: CKNotificationInfo, entityName: String, var predicate: NSPredicate?, completionHandler: (subscription: CKSubscription?, error: NSError?) -> Void) {
        
        if (predicate == nil) {
            predicate = NSPredicate(value: true)
        }
        
        let options:CKSubscriptionOptions = [CKSubscriptionOptions.FiresOnRecordCreation, CKSubscriptionOptions.FiresOnRecordDeletion, CKSubscriptionOptions.FiresOnRecordUpdate]
        let subscription = CKSubscription(recordType: entityName, predicate: predicate!, subscriptionID: subscriptionID, options: options)
        subscription.notificationInfo = notificationInfo
        self.database.saveSubscription(subscription) { (subscription, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(subscription: subscription, error: error)
            }
        }
    }
    
    public func deleteSubscriptionWithID(subscriptionID: String, completionHandler: (result: String?, error: NSError?) -> Void) {
        self.database.deleteSubscriptionWithID(subscriptionID) { (subscription, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(result: subscription, error: error)
            }
        }
    }
}
