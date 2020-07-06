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
    private let textField = UITextField()
    private let uploadButton = UIButton()
    
    private var isFirst = true
    
    private var token: String = ""
    private var filesData: DiskResponse?
    private let fileCellIdentifier = "FileTableViewCell"
    private let textFieldHeight: CGFloat = 44

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
        
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: fileCellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.dataSource = self

        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textFieldHeight))
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        textField.placeholder = "Введите URL за загрузки файла"

        uploadButton.setTitle("↓", for: .normal)
        uploadButton.setTitleColor(.black, for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadFile), for: .touchUpInside)

        [tableView, textField, uploadButton].forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textField.heightAnchor.constraint(equalToConstant: textFieldHeight),

            uploadButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            uploadButton.heightAnchor.constraint(equalTo: textField.heightAnchor),
            uploadButton.widthAnchor.constraint(equalTo: uploadButton.heightAnchor),
            uploadButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func updateData() {
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
    
    @objc private func uploadFile() {
        guard let fileUrl = textField.text, !fileUrl.isEmpty else { return }
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/upload")
        components?.queryItems = [
            URLQueryItem(name: "url", value: fileUrl),
            URLQueryItem(name: "path", value: "file"),
        ]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("Success")
                    self.updateData()
                default:
                    print("Status: \(response.statusCode)")
                }
            }
        }.resume()
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
