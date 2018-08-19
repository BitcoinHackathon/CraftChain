//
//  AppDelegate.swift
//  SimpleWallet
//
//  Created by Akifumi Fujita on 2018/08/17.
//  Copyright © 2018年 Akifumi Fujita. All rights reserved.
//

import UIKit
import BitcoinKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        setup()

        window = UIWindow()
        window?.makeKeyAndVisible()
        let tabBarController = UITabBarController()
        let viewControllers = [UINavigationController(rootViewController: TopTableViewController.make()),
                               WalletViewController.make(),
                               CommentListTableViewController.make(),
                               HomeViewController.make(),
                               PostViewController.make(),
                               AdminViewController.make()]

        viewControllers.forEach {
            tabBarController.addChildViewController($0)
        }
        window?.rootViewController = tabBarController

        return true
    }

    private func setup() {
        let post = Post(choices: [Post.Choice(description: "ビット子", address: "addr1", pubKey: PrivateKey().publicKey()),
                                  Post.Choice(description: "イーサ子", address: "addr2", pubKey: PrivateKey().publicKey()),
                                  Post.Choice(description: "リップルン", address: "addr3", pubKey: PrivateKey().publicKey())],
                        userName: "立命館大学ミスコン",
                        createdAt: Date(),
                        description: "今年のミス立命館を決めます",
                        deadline: Date().addingTimeInterval(2000),
                        voteCount: 0)
        PostManager.shared.append(post)

        if AppController.shared.wallet == nil {
            debugLog("Create wallet")
            let privateKey = PrivateKey(network: .testnet)
            let wif = privateKey.toWIF()
            AppController.shared.importWallet(wif: wif)
        } else {
            debugLog("Exists wallet")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

