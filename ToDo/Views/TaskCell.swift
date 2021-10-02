//
//  TaskCell.swift
//  ToDo
//
//  Created by Christelle Nieves on 9/29/21.
//

import UIKit
import CoreData

class TaskCell: UITableViewCell {
    
    weak var delegate: TaskDelegate?
    
    weak var task: NSManagedObject?
    let roundedView = UIView()
    let checkMarkCircleButton = UIButton()
    let taskLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        setupRoundedView()
        setupCheckMarkCircleButton()
        setupTaskLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Setup

extension TaskCell {
    private func setupRoundedView() {
        roundedView.layer.cornerRadius = 18
        roundedView.backgroundColor = UIColor.secondarySystemBackground
        roundedView.isUserInteractionEnabled = true
        contentView.addSubview(roundedView)
        
        // Constraints
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            roundedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roundedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            roundedView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.90),
            roundedView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.80)
        ])
    }
    
    private func setupCheckMarkCircleButton() {
        roundedView.addSubview(checkMarkCircleButton)
        
        // Attributes
        let config = UIImage.SymbolConfiguration(pointSize: 32)
        checkMarkCircleButton.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
        checkMarkCircleButton.imageView?.tintColor = UIColor(named: "AppAccent")
        checkMarkCircleButton.contentMode = .scaleAspectFit
        
        // Action
        checkMarkCircleButton.addAction(UIAction { action in
            self.checkMarkCircleButton.bounceAnimation()
            
            // Haptic feedback on button press
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            if let currentTask = self.task {
                self.delegate?.toggleCompletion(task: currentTask)
                
                guard let isCompleted = currentTask.value(forKeyPath: "isCompleted") as? Bool else { return }
                guard let taskDescription = self.task?.value(forKeyPath: "taskDescription") as? String else { return }
                
                if isCompleted {
                    self.checkMarkCircleButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: config), for: .normal)
                    
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: taskDescription)
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
                    
                    self.taskLabel.attributedText = attributeString
                    self.taskLabel.textColor = UIColor(named: "AppAccent")
                } else {
                    self.taskLabel.attributedText = NSAttributedString(string: taskDescription)
                    self.checkMarkCircleButton.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
                    self.taskLabel.textColor = UIColor(named: "AppText")
                }
            }
        }, for: .touchUpInside)
        
        // Constraints
        checkMarkCircleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkMarkCircleButton.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            checkMarkCircleButton.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 5),
            checkMarkCircleButton.widthAnchor.constraint(equalTo: roundedView.widthAnchor, multiplier: 1/7),
            checkMarkCircleButton.heightAnchor.constraint(equalTo: checkMarkCircleButton.widthAnchor)
        ])
    }
    
    private func setupTaskLabel() {
        roundedView.addSubview(taskLabel)
        
        // Attributes
        taskLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)
        taskLabel.textColor = UIColor(named: "AppText")
        taskLabel.numberOfLines = 0
        taskLabel.lineBreakMode = .byWordWrapping
        
        // Constraints
        taskLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskLabel.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            taskLabel.leadingAnchor.constraint(equalTo: checkMarkCircleButton.trailingAnchor, constant: 5),
            taskLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -5)
        ])
    }
}

// MARK: - Auxiliary Functions

extension TaskCell {
    func setupCellWithViewModel(viewModel: TaskCellViewModel) {
        // Reset the attributed text for the tasklabel
        taskLabel.attributedText = nil
        
        // Set the text color and button image according to whether the task is completed or not
        let config = UIImage.SymbolConfiguration(pointSize: 25)
        
        switch viewModel.isCompleted {
        case true:
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: viewModel.taskDescription)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            
            taskLabel.attributedText = attributeString
            taskLabel.textColor = UIColor(named: "AppAccent")
            checkMarkCircleButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: config), for: .normal)
            break
        case false:
            taskLabel.text = viewModel.taskDescription
            taskLabel.textColor = UIColor(named: "AppText")
            checkMarkCircleButton.setImage(UIImage(systemName: "circle", withConfiguration: config), for: .normal)
            break
        }
    }
}
