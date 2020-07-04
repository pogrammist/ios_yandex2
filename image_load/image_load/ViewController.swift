//
//  ViewController.swift
//  image_load
//
//  Created by user on 05.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let string = "https://www.google.ru/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"
        guard let url = URL(string: string) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            print("Done!")
            guard let data = data else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        }
        task.resume()
    }
}

