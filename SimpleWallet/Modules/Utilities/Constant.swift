//
//  Constant.swift
//  SimpleWallet
//
//  Created by Daiki Sekiguchi on 2018/08/19.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import Foundation
import BitcoinKit

struct Constant {
    // 投票で使うコインの金額
    static let voteAmount: Int64 = 300
    
    // 一旦、運営 = ログインユーザーとする
    static let adminPubKey: PublicKey = AppController.shared.wallet!.publicKey
}
