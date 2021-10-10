//
//  DataService.swift
//  ToDo
//
//  Created by Christelle Nieves on 9/29/21.
//

import Foundation
import CoreData
import UIKit

var dataService = DataService.shared

public class DataService {
    static var shared = DataService()
    var tasksSortedByDate = [NSManagedObject]()
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - TaskItem Functions

extension DataService {
    func addTask(description: String, date: Date, isCompleted: Bool) {
        let context = persistentContainer.viewContext
        
        // Create a new TaskItem entity
        guard let newEntity = NSEntityDescription.entity(forEntityName: "TaskItem", in: context) else { return }
        
        // Insert the new TaskItem into the manged context
        let newTaskItem = NSManagedObject(entity: newEntity, insertInto: context) as! TaskItem
        
        // Set the values
        newTaskItem.taskDescription = description
        newTaskItem.date = date
        newTaskItem.isCompleted = isCompleted
        
        // Save the new entity
        do {
            try context.save()
        } catch let error as NSError {
            print("Error saving new task. \(error), \(error.userInfo)")
        }
    }
    
    func removeTask(task: NSManagedObject) {
        let context = persistentContainer.viewContext
        
        context.delete(task)
        saveContext()
        
        // Repopulate the array
        tasksSortedByDate.removeAll()
        sortTasksByDate()
    }
    
    func updateTaskDescription(task: NSManagedObject, newDescription: String) {
        guard let currentTask = task as? TaskItem else { return }
        let context = persistentContainer.viewContext
        
        currentTask.taskDescription = newDescription
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error updating task. \(error), \(error.userInfo)")
        }
    }
    
    func toggleTaskCompletion(task: NSManagedObject) {
        guard let currentTask = task as? TaskItem else { return }
        let context = persistentContainer.viewContext
        
        currentTask.isCompleted = currentTask.isCompleted ? false : true
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Error updating task. \(error), \(error.userInfo)")
        }
    }
    
    func sortTasksByDate() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskItem")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sort]
        
        do {
            tasksSortedByDate = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error fetching tasks. \(error), \(error.userInfo)")
        }
    }
}
