//
//  PastJourneysViewController.swift
//  LiveLine
//
//  Created by Rhys Powell on 8/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit
import CoreData

class PastJourneysViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var fetchedResultsController: NSFetchedResultsController? = nil
    var dateFormatter: NSDateFormatter? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        dateFormatter = NSDateFormatter()
        dateFormatter?.dateStyle = .ShortStyle
        dateFormatter?.timeStyle = .NoStyle
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        createFetchedResultsController()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showJourneyDetails") {
            if let playBackController = segue.destinationViewController as? PlayBackJourneyViewController {
                let selectedIndexPath = self.tableView.indexPathForSelectedRow()
                playBackController.journey = self.fetchedResultsController?.objectAtIndexPath(selectedIndexPath!) as? Journey
            }
        }
    }
    
    // MARK: - Table view data source
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let journeyCell = cell as JourneyCell
        let journey = fetchedResultsController!.objectAtIndexPath(indexPath) as Journey
        
        journeyCell.titleLabel.text = journey.title
        journeyCell.dateLabel.text = dateFormatter?.stringFromDate(journey.timestamp) ?? "No date"
        journeyCell.distanceLabel.text = "\(journey.distance.doubleValue / 1000.0) km"
        journeyCell.bezierView.path = scaledJourneyPath(journey)
    }
    
    func scaledJourneyPath(journey: Journey) -> UIBezierPath {
        var scalingBounds = (minX: 180.0, minY: 180.0, maxX: -180.0, maxY: -180.0)
        
        for coord in journey.coordinatesArray {
            if (coord.latitude.doubleValue > scalingBounds.maxY) {
                scalingBounds.maxY = coord.latitude.doubleValue
            }
            
            if (coord.latitude.doubleValue < scalingBounds.minY) {
                scalingBounds.minY = coord.latitude.doubleValue
            }
            if (coord.longitude.doubleValue > scalingBounds.maxX) {
                scalingBounds.maxX = coord.longitude.doubleValue
            }
            
            if (coord.longitude.doubleValue < scalingBounds.minX) {
                scalingBounds.minX = coord.longitude.doubleValue
            }
        }
        
        let scalingFactor = max(scalingBounds.maxX - scalingBounds.minX, scalingBounds.maxY - scalingBounds.minY)
        var path = UIBezierPath()
        var offsets = (x: (scalingBounds.maxX - scalingBounds.minX - scalingFactor) / 2, y: (scalingBounds.maxY - scalingBounds.minY - scalingFactor) / 2)
        var firstPoint = true
        for coord in journey.coordinatesArray {
            let point = CGPoint(
                x: (coord.longitude.doubleValue - scalingBounds.minX - offsets.x) / scalingFactor * 64 + 10,
                y: (((((coord.latitude.doubleValue - scalingBounds.minY - offsets.y) / scalingFactor) - 0.5) * -1) + 0.5) * 64 + 10
            )
            
            if (firstPoint) {
                path.moveToPoint(point)
                firstPoint = false
            } else {
                path.addLineToPoint(point)
            }
        }
        path.lineWidth = 2
        
        return path
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        let sectionInfo = self.fetchedResultsController!.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = fetchedResultsController!.managedObjectContext
            context.deleteObject(fetchedResultsController!.objectAtIndexPath(indexPath) as NSManagedObject)
            
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - Fethched Results Controller
    
    func createFetchedResultsController() {
        if (managedObjectContext != nil && fetchedResultsController == nil) {
            let fetchRequest = NSFetchRequest()
            
            let entity = NSEntityDescription.entityForName("Journey", inManagedObjectContext: managedObjectContext!)
            fetchRequest.entity = entity
            
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            
            var error: NSError? = nil
            if !fetchedResultsController!.performFetch(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath)!, atIndexPath: indexPath)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
