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
import UIKit
import CoreLocation
import ADGCloudKit

class ParentViewController: BaseViewController {
    
    var dao = ParentDAO()
    
    override func onFindAllRecords() {
        self.dao.findObjectsWithPredicate(nil, sortDescriptors: [NSSortDescriptor(key: "stringAttribute", ascending: true)], resultsLimit: nil) { [unowned self] (records, error) -> Void in
            print(error)
            if let records = records {
                self.datasource = records
                self.tableView.reloadData()
            }
        }
    }
    
    override func onDelete(object: CloudRecord, indexPath: NSIndexPath) {
        try! self.dao.deleteObject(object as! Parent, completionHandler: { [unowned self] (error) -> Void in
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.datasource.removeAtIndex(indexPath.row)
            self.tableView.endUpdates()
            })
    }
    
    override func onCellIdentifier() -> String {
        return "ParentCell"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? ChildViewController, indexPath = self.tableView.indexPathForSelectedRow {
            controller.parent = self.datasource[indexPath.row] as? Parent
        }
    }
    
    @IBAction func onAddTouched(sender: AnyObject) {
        let object = Parent()
        object.stringAttribute = self.adg_randomStringWithLength(4)
        object.intAttribute =  NSNumber(int: rand())
        object.doubleAttribute = NSDate().timeIntervalSinceNow
        object.dateTimeAttribute = NSDate()
        object.locationAttribute = CLLocation(latitude: Double(self.adg_random(-30...30)), longitude: Double(self.adg_random(-30...30)))
        object.stringListAttribute = [self.adg_randomStringWithLength(1), self.adg_randomStringWithLength(1), self.adg_randomStringWithLength(1)]
        
        self.dao.insertObject(object) { (object, error) -> Void in
            
            print(error)
            
            if let object = object {
                self.datasource.append(object)
                self.tableView.reloadData()
            }
        }
    }
}
