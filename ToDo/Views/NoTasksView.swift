//
//  NoTasksView.swift
//  ToDo
//
//  Created by Christelle Nieves on 10/1/21.
//

import UIKit

class NoTasksView: UIView {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupSubtitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Setup

extension NoTasksView {
    private func setupTitleLabel() {
        self.addSubview(titleLabel)
        
        // Attributes
        titleLabel.text = "You haven't added any tasks yet ☹️"
        titleLabel.textColor = UIColor(named: "AppAccent")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        // Constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.90)
        ])
    }
    
    private func setupSubtitleLabel() {
        self.addSubview(subtitleLabel)
        
        // Attributes
        subtitleLabel.text = "Add a task by clicking the add button below!"
        subtitleLabel.textColor = UIColor(named: "AppText")?.withAlphaComponent(0.60)
        subtitleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        
        // Constraints
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            subtitleLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30)
        ])
    }
}
