//
//  DiskResponse.swift
//  diskPhoto
//
//  Created by user on 05.07.2020.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation

struct DiskResponse: Codable {
    let items: [DiskFile]?
}

struct DiskFile: Codable {
    let name: String?
    let preview: String?
    let size: Int64?
}
