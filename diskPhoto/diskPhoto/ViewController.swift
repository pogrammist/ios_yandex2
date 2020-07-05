//
//  ViewController.swift
//  diskPhoto
//
//  Created by user on 05.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()
    private var isFirst = true
    
    private var token: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirst {
            updateData()
        }
        isFirst = false
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        title = "Мои фото"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateData() {
        guard !token.isEmpty else {
            let requestTokenViewController = AuthViewController()
            requestTokenViewController.delegate = self
            present(requestTokenViewController, animated: false, completion: nil)
            return
        }
    }
}

extension ViewController: AuthViewControllerDelegate {
    func handleTokenChange(token: String) {
        self.token = token
        print("New token: \(token)")
        updateData()
    }
}
