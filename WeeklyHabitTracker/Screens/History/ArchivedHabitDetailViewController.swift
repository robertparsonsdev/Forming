//
//  ArchivedHabitDetailViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchivedHabitDetailViewController: UIViewController {
    private var archivedHabit: ArchivedHabit?
    private var containerHeight = 300
    
    private let scrollView = UIScrollView()
    private let cell = ArchivedHabitCell()
    private let container = UIView()
    private let notesLabel = UILabel()
    private let notesTextView = UITextView()
    
    private var toolBar: UIToolbar!
    private var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIApplication.keyboardWillHideNotification, object: nil)
        
        configureScrollView()
        configureToolbar()
        configureTap()
        configureContainer()
        configureNotesLabel()
        configureNotesTextView()
        configureConstraints()
    }
    
    func set(archivedHabit: ArchivedHabit) {
        self.archivedHabit = archivedHabit
        cell.set(archivedHabit: archivedHabit)
    }
    func configureScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
    }
    
    func configureToolbar() {
        toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 30)))
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .systemGreen
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), saveButton], animated: false)
        toolBar.sizeToFit()
    }
    
    func configureTap() {
        tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func configureContainer() {
        container.layer.cornerRadius = 14
        container.backgroundColor = .tertiarySystemFill
    }
    
    func configureNotesLabel() {
        notesLabel.text = "Notes:"
        notesLabel.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    func configureNotesTextView() {
        notesTextView.backgroundColor = .clear
        notesTextView.font = UIFont.systemFont(ofSize: 17)
        notesTextView.inputAccessoryView = self.toolBar
    }

    func configureConstraints() {
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        scrollView.addSubview(cell)
        cell.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 90)
        
        scrollView.addSubview(container)
        container.anchor(top: cell.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: CGFloat(self.containerHeight))
        scrollView.addSubview(notesLabel)
        notesLabel.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 20)
        container.addSubview(notesTextView)
        notesTextView.anchor(top: notesLabel.bottomAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 0)
    }
    
    func adjustContainerHeight(newConstraint: CGFloat) {
        DispatchQueue.main.async {
            for constraint in self.container.constraints {
                if constraint.description.contains(String(self.containerHeight)) {
                    self.container.removeConstraint(constraint)
                    self.container.heightAnchor.constraint(equalToConstant: newConstraint).isActive = true
                    self.containerHeight = Int(newConstraint)
                    break
                }
            }
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func saveButtonTapped() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let framHeight: CGFloat = self.view.frame.height
            let cellHeight: CGFloat = 90
            let keyboardHeight: CGFloat = keyboardFrame.cgRectValue.height
            let toolbarHeight: CGFloat = 30
            let topBarHeight: CGFloat = self.topbarHeight
            let heightLeft: CGFloat = framHeight - cellHeight - keyboardHeight - toolbarHeight - topBarHeight
            self.adjustContainerHeight(newConstraint: heightLeft)
        }
    }
    
    @objc func keyboardWillDisappear() {
        self.archivedHabit?.notes = self.notesTextView.text
        self.adjustContainerHeight(newConstraint: 270)
    }
}

extension UIViewController {
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
