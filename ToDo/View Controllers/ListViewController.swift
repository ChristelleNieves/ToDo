//
//  ListViewController.swift
//  ToDo
//
//  Created by Christelle Nieves on 9/29/21.
//

import UIKit
import CoreData

class ListViewController: UIViewController {
    
    let listViewModel = ListViewModel()
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    let addTaskButton = UIButton()
    let noTasksView = NoTasksView()
    var editIndexPath: IndexPath?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listViewModel.getAllTasks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupTableView()
        setupAddTaskButton()
        setupNoTasksView()
    }
}

// MARK: - UI Setup

extension ListViewController {
    private func setupTableView() {
        view.addSubview(tableView)
        
        // Attributes
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        
        // Appearance
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        
        // Constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupAddTaskButton() {
        view.addSubview(addTaskButton)
        
        // Attributes
        let config = UIImage.SymbolConfiguration(pointSize: 70)
        addTaskButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config), for: .normal)
        addTaskButton.backgroundColor = UIColor.clear
        addTaskButton.imageView?.tintColor = UIColor(named: "AppAccent")
        addTaskButton.contentMode = .scaleAspectFill
        
        // Action
        addTaskButton.addAction(UIAction { action in
            self.addTaskButton.bounceAnimation()
            
            UIView.animate(withDuration: 0.25, animations: {
                
                // Present AddTaskViewController
                let addTaskVC = AddTaskViewController()
                addTaskVC.delegate = self
                addTaskVC.modalPresentationStyle = .pageSheet
                addTaskVC.modalTransitionStyle = .coverVertical
                self.present(addTaskVC, animated: true, completion: nil)
            })
        }, for: .touchUpInside)
        
        // Constraints
        addTaskButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTaskButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addTaskButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            addTaskButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4.5),
            addTaskButton.heightAnchor.constraint(equalTo: addTaskButton.widthAnchor)
        ])
    }
    
    // noTasksView is a view that will only be visible whenever there are 0 rows in the tableView
    private func setupNoTasksView() {
        view.addSubview(noTasksView)
        
        noTasksView.isHidden = true
        
        // Attributes
        noTasksView.layer.cornerRadius = 20
        noTasksView.backgroundColor = UIColor.secondarySystemBackground
        
        // Constraints
        noTasksView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noTasksView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTasksView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noTasksView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
    }
}

// MARK: - TableView Delegate

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noTasksView.isHidden = listViewModel.tasks.count == 0 ? false : true
        
        return listViewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        cell.delegate = self
        cell.setupCellWithViewModel(viewModel: listViewModel.taskCellViewModels[indexPath.row])
        cell.task = listViewModel.tasks[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            
            // Display alert to confirm deletion of task
            let alert = UIAlertController(title: "Delete this task?", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
                
                // Remove the task from the viewModel array
                self.listViewModel.dataService.removeTask(task: self.listViewModel.tasks[indexPath.row])
                self.listViewModel.getAllTasks()
                
                // Remove the cell from the tableView
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.reloadData()
                
                completionHandler(true)
                
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            })
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(UIColor(named: "AppAccent") ?? UIColor.systemRed, renderingMode: .alwaysOriginal)
        deleteAction.backgroundColor = UIColor.systemBackground
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let archive = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            
            // Present the AddTaskViewController in "edit" mode to edit the selected task
            let editTaskVC = AddTaskViewController()
            editTaskVC.delegate = self
            editTaskVC.taskMode = .editTask
            
            // Save the current index path so we can use it when we update the task in the viewModel/Coredata
            self?.editIndexPath = indexPath
            
            editTaskVC.modalPresentationStyle = .pageSheet
            editTaskVC.modalTransitionStyle = .coverVertical
            self?.present(editTaskVC, animated: true, completion: nil)
            completionHandler(true)
        }
        
        archive.image = UIImage(systemName: "slider.horizontal.3")?.withTintColor(UIColor.darkGray, renderingMode: .alwaysOriginal)
        archive.backgroundColor = UIColor.systemBackground
        
        let configuration = UISwipeActionsConfiguration(actions: [archive])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            // Open detail view for the selected cell
            let detailVC = TaskDetailViewController()
            detailVC.setDateText(date: self.listViewModel.taskCellViewModels[indexPath.row].dateCreated)
            detailVC.modalPresentationStyle = .popover
            detailVC.modalTransitionStyle = .coverVertical
            self.present(detailVC, animated: true, completion: nil)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            tableView.cellForRow(at: indexPath)?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        
        if listViewModel.tasks.count == 0 {
            subtitleLabel.isHidden = true
        }
        
        headerView.backgroundColor = .clear
        
        // Configure title label
        titleLabel.text = "Hello 👋🏻"
        titleLabel.textColor = UIColor(named: "AppText")
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        headerView.addSubview(titleLabel)
        
        // Set title label constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30)
        ])
        
        // Configure subtitle label
        let numIncompleteTasks = listViewModel.getNumberOfIncompleteTasks()
        
        // If the number of tasks left is 1 we want to display the singular word "task", otherwise it will be plural "tasks"
        let taskPluralOrSingular = numIncompleteTasks == 1 ? "task" : "tasks"
        
        subtitleLabel.text = numIncompleteTasks == 0 ? "You've completed all your tasks! 🎉" : "You have \(numIncompleteTasks) \(taskPluralOrSingular) to complete"
        subtitleLabel.textColor = UIColor(named: "AppAccent")
        subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        headerView.addSubview(subtitleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.frame.height * 1/6
    }
}

// MARK: - TaskDelegate

extension ListViewController: TaskDelegate {
    func saveNewTask(description: String, date: Date, isCompleted: Bool) {
        listViewModel.dataService.addTask(description: description, date: date, isCompleted: isCompleted)
        listViewModel.getAllTasks()
        tableView.reloadData()
    }
    
    func toggleCompletion(task: NSManagedObject) {
        listViewModel.dataService.toggleTaskCompletion(task: task)
        listViewModel.getAllTasks()
        tableView.reloadData()
    }
    
    func updateTask(newDescription: String) {
        listViewModel.dataService.updateTaskDescription(task: listViewModel.tasks[editIndexPath!.row], newDescription: newDescription)
        listViewModel.getAllTasks()
        tableView.reloadData()
    }
}
