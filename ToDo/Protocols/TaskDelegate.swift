//
//  TaskDelegate.swift
//  ToDo
//
//  Created by Christelle Nieves on 10/1/21.
//

import Foundation
import CoreData

protocol TaskDelegate: AnyObject {
    func saveNewTask(description: String, date: Date, isCompleted: Bool)
    func toggleCompletion(task: NSManagedObject)
    func updateTask(newDescription: String)
}
