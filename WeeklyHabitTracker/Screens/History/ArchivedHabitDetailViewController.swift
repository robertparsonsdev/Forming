//
//  ArchivedHabitDetailViewController.swift
//  WeeklyHabitTracker
//
//  Created by Robert Parsons on 6/13/20.
//  Copyright © 2020 Robert Parsons. All rights reserved.
//

import UIKit

class ArchivedHabitDetailViewController: UIViewController {
    private var archivedHabit: ArchivedHabit!
    private let persistenceManager: PersistenceService
    private let notificationCenter: NotificationCenter
    private var containerHeight = 300
    
    private let scrollView = UIScrollView()
    private let cell = ArchivedHabitCell()
    private let container = UIView()
    private let notesLabel = UILabel()
    private let notesTextView = UITextView()
    
    private var toolBar: UIToolbar!
    private var tap: UITapGestureRecognizer!
    
    // MARK: - Initializers
    init(persistenceManager: PersistenceService, notifCenter: NotificationCenter) {
        self.persistenceManager = persistenceManager
        self.notificationCenter = notifCenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewControllerFunctions
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
        
        // Notification oberservers
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabit), name: NSNotification.Name(NotificationName.newDay.rawValue), object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(reloadArchivedHabit), name: NSNotification.Name(NotificationName.archivedHabitDetail.rawValue), object: nil)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.notificationCenter.removeObserver(self, name: NSNotification.Name(NotificationName.newDay.rawValue), object: nil)
            self.notificationCenter.removeObserver(self, name: NSNotification.Name(NotificationName.archivedHabitDetail.rawValue), object: nil)
        }
    }
    
    // MARK: - Setters
    func set(archivedHabit: ArchivedHabit) {
        self.archivedHabit = archivedHabit
        cell.set(archivedHabit: archivedHabit, attributed: false)
    }
    
    // MARK: - Configuration Functions
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
        notesTextView.delegate = self
        notesTextView.text = self.archivedHabit?.notes
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
    
    // MARK: - Functions
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
    
    // MARK: - Selectors
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
        self.persistenceManager.save()
        self.adjustContainerHeight(newConstraint: 300)
    }
    
    @objc func reloadArchivedHabit() {
        DispatchQueue.main.async { self.cell.set(archivedHabit: self.archivedHabit, attributed: false) }
    }
}

// MARK: - Delegates
extension ArchivedHabitDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.archivedHabit?.notes = textView.text
    }
}
