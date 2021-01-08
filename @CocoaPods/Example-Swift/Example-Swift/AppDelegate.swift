//
//  AppDelegate.swift
//  Example-Swift
//
//  Created by Mingfeng Ho 何明峯 on 2020/5/7.
//  Copyright © 2020 ECPay. All rights reserved.
//

import UIKit
import ECPayPaymentGatewayKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var envStr:String = "prod"
        if let env = Bundle.main.object(forInfoDictionaryKey: "ENV") as? String {
            envStr = env.lowercased()
        }
        
        switch envStr {
        case "beta":
            ECPayPaymentGatewayManager.sharedInstance().initialize(env: .Beta)
            break
        case "stage":
            ECPayPaymentGatewayManager.sharedInstance().initialize(env: .Stage)
            break
        default:
            ECPayPaymentGatewayManager.sharedInstance().initialize(env: .Prod)
            break
        }
        
        
        return true
    }

}

