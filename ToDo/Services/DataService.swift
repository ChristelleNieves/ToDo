//
//  DataService.swift
//  ToDo
//
//  Created by Christelle Nieves on 9/29/21.
//

import Foundation
import CoreData
import UIKit

public class DataService {
    var tasksSortedByDate = [NSManagedObject]()
    
    func addTask(description: String, date: Date, isCompleted: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create a new TaskItem entity
        guard let newEntity = NSEntityDescription.entity(forEntityName: "TaskItem", in: managedContext) else { return }
        
        // Insert the new TaskItem into the manged context
        let newTaskItem = NSManagedObject(entity: newEntity, insertInto: managedContext)
        
        // Set the values
        newTaskItem.setValue(description, forKeyPath: "taskDescription")
        newTaskItem.setValue(date, forKeyPath: "date")
        newTaskItem.setValue(isCompleted, forKeyPath: "isCompleted")
        
        // Save the new entity
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error saving new task. \(error), \(error.userInfo)")
        }
    }
    
    func removeTask(task: NSManagedObject) {
        // Remove the task from CoreData
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(task)
        appDelegate.saveContext()
        
        // Repopulate the array
        tasksSortedByDate.removeAll()
        sortTasksByDate()
    }
    
    func updateTaskDescription(task: NSManagedObject, newDescription: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        task.setValue(newDescription, forKeyPath: "taskDescription")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error updating task. \(error), \(error.userInfo)")
        }
    }
    
    func toggleTaskCompletion(task: NSManagedObject) {
        guard let isCompleted = task.value(forKeyPath: "isCompleted") as? Bool else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let newValue = isCompleted ? false : true
        
        task.setValue(newValue, forKeyPath: "isCompleted")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error updating task. \(error), \(error.userInfo)")
        }
    }
    
    func sortTasksByDate() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TaskItem")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sort]
        
        do {
            tasksSortedByDate = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error fetching tasks. \(error), \(error.userInfo)")
        }
    }
}
