//
//  TaskCellViewModel.swift
//  ToDo
//
//  Created by Christelle Nieves on 9/29/21.
//

import Foundation
import CoreData

public class TaskCellViewModel {
    var taskDescription: String
    var dateCreated: Date
    var isCompleted: Bool
    
    init(taskObject: NSManagedObject) {
        let description = taskObject.value(forKeyPath: "taskDescription") as? String
        let date = taskObject.value(forKeyPath: "date") as? Date
        let completed = taskObject.value(forKeyPath: "isCompleted") as? Bool
        
        self.taskDescription = description ?? ""
        self.dateCreated = date ?? Date()
        self.isCompleted = completed ?? false
    }
}
