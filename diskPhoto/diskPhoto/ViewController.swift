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
    private var filesData: DiskResponse?
    private let fileCellIdentifier = "FileTableViewCell"

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
        
        tableView.dataSource = self
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: fileCellIdentifier)
        
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
        
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/files")
        components?.queryItems = [URLQueryItem(name: "media type", value: "image")]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let sself = self, let data = data else { return }
            guard let newFiles = try? JSONDecoder().decode(DiskResponse.self, from: data) else { return }
            print("Received: \(newFiles.items?.count ?? 0) files")
            sself.filesData = newFiles
            
            DispatchQueue.main.async { [weak self] in 
                self?.tableView.reloadData()
            }
        }
        task.resume()
    }
}

extension ViewController: AuthViewControllerDelegate {
    func handleTokenChange(token: String) {
        self.token = token
        print("New token: \(token)")
        updateData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesData?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fileCellIdentifier, for: indexPath)
        guard let items = filesData?.items, items.count > indexPath.row else {
            return cell
        }
        let currentFile = items[indexPath.row]
        if let fileCell = cell as? FileTableViewCell {
            fileCell.delegate = self
            fileCell.bindModel(currentFile)
        }
        return cell
    }
}

extension ViewController: FileTableViewCellDelegate {
    func loadImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
}
