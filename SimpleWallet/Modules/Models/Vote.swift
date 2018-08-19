//
//  Vote.swift
//  SimpleWallet
//
//  Created by Daiki Sekiguchi on 2018/08/19.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import Foundation

struct Vote: Codable {
    let hash: String
    let message: String
    
    func toJson() -> String {        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        let json: String = String(data: data, encoding: .utf8)!

        return json
    }
}

extension Vote {
    init(from data: Data) {
        self = try! JSONDecoder().decode(Vote.self, from: data)
    }
}
