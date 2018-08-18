//
//  MockHelper.swift
//  SimpleWallet
//
//  Created by Daiki Sekiguchi on 2018/08/19.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import Foundation
import BitcoinKit

struct BCHHelper {
    func createMultisigAddress(adminPubKey: PublicKey, targetPubKey: PublicKey) -> Address {
        let multisig = Script(publicKeys: [adminPubKey, targetPubKey], signaturesRequired: 2)!
        return multisig.toP2SH().standardAddress(network: .testnet)!
    }
    
    func selectTx(from utxos: [UnspentTransaction], amount: Int64) -> (utxos: [UnspentTransaction], fee: Int64) {
        return (utxos, 500)
    }
    
    func string2ExpiryTime(dateString: String) -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: dateString)!
        let dateUnix: TimeInterval = date.timeIntervalSince1970
        return Data(from: Int32(dateUnix).littleEndian)
    }
}
