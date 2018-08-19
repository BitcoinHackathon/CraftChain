//
//  Post.swift
//  SimpleWallet
//
//  Created by 下村一将 on 2018/08/18.
//  Copyright © 2018 Akifumi Fujita. All rights reserved.
//

import Foundation
import BitcoinKit

struct Post {
    struct Choice {
        let description: String
        let address: String
        let pubKey: PublicKey
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

    typealias RemainTime = (day: Int, hour: Int, min: Int, sec: Int)

    var remainTime: RemainTime {
        let diff = Int(deadline.timeIntervalSince(Date()))
        let day = diff/24/60/60
        let hour = diff/60/60
        let min = diff/60 - hour*60
        let sec = diff - min*60 - hour*60*60

        return RemainTime(day, hour, min, sec)
    }
}

extension Array where Element == Post.Choice {
    func get(at index: Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }
}
