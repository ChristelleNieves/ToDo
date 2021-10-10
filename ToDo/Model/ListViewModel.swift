//
//  ListViewModel.swift
//  ToDo
//
//  Created by Christelle Nieves on 9/29/21.
//

import Foundation
import CoreData

public class ListViewModel {
    var tasks = [NSManagedObject]()
    var taskCellViewModels = [TaskCellViewModel]()
    
    func getAllTasks() {
        tasks.removeAll()
        dataService.sortTasksByDate()
        tasks = dataService.tasksSortedByDate
        populateCellViewModels()
    }
    
    func populateCellViewModels() {
        taskCellViewModels.removeAll()
        
        for task in tasks {
            let viewModel = TaskCellViewModel(taskObject: task)
            taskCellViewModels.append(viewModel)
        }
    }
    
    func getNumberOfIncompleteTasks() -> Int {
        var numIncompleteTasks = 0
        
        for task in tasks {
            guard let isCompleted = task.value(forKeyPath: "isCompleted") as? Bool else { return 0 }
            
            if !isCompleted {
                numIncompleteTasks += 1
            }
        }
        
        return numIncompleteTasks
    }
}
