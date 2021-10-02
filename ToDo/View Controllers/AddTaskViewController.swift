//
//  AddTaskViewController.swift
//  ToDo
//
//  Created by Christelle Nieves on 9/29/21.
//

import UIKit

enum AddTaskMode {
    case addTask
    case editTask
}

class AddTaskViewController: UIViewController {
    
    weak var delegate: TaskDelegate?
    
    var taskMode: AddTaskMode = .addTask
    let titleLabel = UILabel()
    let textField = UITextField()
    let addItemButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.secondarySystemBackground
        setupTitleLabel()
        setupTextField()
        setupAddItemButton()
        
        // Set up the observers for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(AddTaskViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddTaskViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Set the height of this view controller
    override func updateViewConstraints() {
        view.frame.size.height = UIScreen.main.bounds.height - UIScreen.main.bounds.height * 1/1.7
        view.frame.origin.y =  UIScreen.main.bounds.height * 1/1.7
        view.layer.cornerRadius = 20
        super.updateViewConstraints()
    }
}

// MARK: - UI Setup

extension AddTaskViewController {
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        // Attributes
        titleLabel.text = taskMode == .addTask ? "Add a Task" : "Edit Task"
        titleLabel.textColor = UIColor(named: "AppText")
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        
        // Constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTextField() {
        view.addSubview(textField)
        
        // Attributes
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: "Type here...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.textColor = UIColor.black
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.80)
        textField.layer.cornerRadius = 20
        
        // Add a leftView to the textField for padding
        let paddingView = UIView()
        paddingView.backgroundColor = UIColor.clear
        paddingView.frame = CGRect(x: 0, y: 0, width: 10, height: 20)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Constraints
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 35),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            textField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/8)
        ])
    }
    
    private func setupAddItemButton() {
        view.addSubview(addItemButton)
        
        // Attributes
        let config = UIImage.SymbolConfiguration(pointSize: 70)
        addItemButton.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: config), for: .normal)
        addItemButton.imageView?.tintColor = UIColor(named: "AppAccent")
        addItemButton.contentMode = .scaleAspectFit
        
        // Action
        addItemButton.addAction(UIAction { action in
            self.addItemButton.bounceAnimation()
            
            // Haptic feedback on button press
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Check if the textfield is empty or contains only spaces, if so present an alert and don't continue adding the task
            guard let text = self.textField.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                      self.presentNoTextAlert()
                      return
                  }
            
            // Save or update a task based on the current task mode
            switch self.taskMode {
            case .addTask:
                self.delegate?.saveNewTask(description: self.textField.text!, date: Date(), isCompleted: false)
                break
            case .editTask:
                self.delegate?.updateTask(newDescription: self.textField.text!)
                break
            }
            
            self.dismiss(animated: true, completion: nil)
            
        }, for: .touchUpInside)
        
        // Constraints
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addItemButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 40),
            addItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addItemButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/4.5),
            addItemButton.heightAnchor.constraint(equalTo: addItemButton.widthAnchor)
        ])
    }
}

// MARK: - Auxiliary Functions

extension AddTaskViewController {
    // Present an alert to notify the user that they need to type something in the textfield
    private func presentNoTextAlert() {
        let alertVC = UIAlertController(title: "Oops!", message: "You forgot to type your task in the textfield! Try again!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
            alertVC.dismiss(animated: true, completion: nil)
        })
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    // Move the view up when the keyboard pops up
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // If keyboard size is not available for some reason, dont do anything
            return
        }
        
        // Move the view up by the distance of the keyboard height
        self.view.frame.origin.y = (UIScreen.main.bounds.height * 1/1.7) - keyboardSize.height
    }
    
    // Move the view down when the keyboard goes down
    @objc func keyboardWillHide(notification: NSNotification) {
        // Move the view back to its original position
        self.view.frame.origin.y = UIScreen.main.bounds.height * 1/1.7
    }
}

// MARK: - TextField Delegate

extension AddTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
