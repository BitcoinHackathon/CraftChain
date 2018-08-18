//
//  Post.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/18.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import Foundation

struct Post {
    struct Choice {
        let description: String
        let address: String
    }
    let choices: [Choice]
    let userName: String
    let createdAt: Date
    let description: String
    let deadline: Date

    var voteCount = 0

    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd HH:mm:ss"
        return df
    }()
}

extension Array where Element == Post.Choice {
    func get(at index: Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }
}
