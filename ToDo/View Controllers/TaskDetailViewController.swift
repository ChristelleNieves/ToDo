//
//  TaskDetailViewController.swift
//  ToDo
//
//  Created by Christelle Nieves on 10/2/21.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    let titleLabel = UILabel()
    let dateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.secondarySystemBackground
        setupTitleLabel()
        setupDateLabel()
    }
}

// MARK: - Setup

extension TaskDetailViewController {
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        // Attributes
        titleLabel.text = "Task Details"
        titleLabel.textColor = UIColor(named: "AppText")
        titleLabel.font = UIFont.systemFont(ofSize: 25)
        
        // Constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupDateLabel() {
        view.addSubview(dateLabel)
        
        // Attributes
        dateLabel.textColor = UIColor(named: "AppAccent")
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.numberOfLines = 0
        dateLabel.lineBreakMode = .byWordWrapping
        
        // Constraints
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            dateLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90)
        ])
    }
    
    func setDateText(date: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long

        // get the date time String from the date object
        let dateTimeString = formatter.string(from: date)
        dateLabel.text = "This task was created on \(dateTimeString)"
    }
}
