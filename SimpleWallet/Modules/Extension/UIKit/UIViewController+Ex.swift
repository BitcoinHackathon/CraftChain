//
//  UIViewController+Ex.swift
//  SimpleWallet
//
//  Created by 宇野凌平 on 2018/08/18.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertViewController(
        title: String? = nil,
        message: String? = nil,
        actionTitle: String? = "OK",
        handler: ((UIAlertAction) -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        
        present(alertController, animated: true)
    }
}
