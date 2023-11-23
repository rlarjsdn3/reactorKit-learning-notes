//
//  Photo.swift
//  HelloReactorKit
//
//  Created by 김건우 on 11/23/23.
//

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage, total: Int
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
