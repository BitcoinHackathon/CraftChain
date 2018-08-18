//
//  PostManager.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/18.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import Foundation

class PostManager {
    private init() {}
    static let shared = PostManager()

    var posts: [Post] = []

    func append(_ post: Post) {
        posts.append(post)
    }

    func all() -> [Post] {
        return posts
    }
}
