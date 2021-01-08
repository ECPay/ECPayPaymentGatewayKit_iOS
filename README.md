# 站內付2.0_iOS版

## About

此套件提供手機端的全功能付款功能。

- 整合商家信用卡金流服務
- 消費者直接輸入信用卡號並且
- 支援信用卡端 3D驗證流程
- 支援非信用卡付款方式

## Requirements

* XCode 12.2+
* Swift 5+
* iOS 10+
* Cocoapods 1.10.0+

## Installation

### 支援套件管理

> 請注意，此套件使用 XCFramework 製作，Cocoapods 的版本必須要是 1.10.0 以上。

### [CocoaPods](http://cocoapods.org)
[![CocoaPods](https://img.shields.io/cocoapods/v/ECPayPaymentGateway.svg)](https://cocoapods.org/pods/ECPayPaymentGateway)

Podfile內容
````ruby
pod 'ECPayPaymentGateway', '~> 0.0.1'
````
此套件相依其他 CocoaPods 套件，詳細清單如下：
````ruby
pod 'PromiseKit' , '~> 6.8.3'
pod 'Alamofire', '~> 5.2.1'
pod 'IQKeyboardManagerSwift'
pod 'KeychainSwift', '~> 16.0'
pod 'SwiftyJSON', '~> 4.2.0'
pod 'SwiftyXMLParser', :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
pod 'CryptoSwift', '~> 0.14.0'
````

範例專案以 Swift 為主，請在 [Podfile] 同層目錄下執行以下指令：
````ruby
pod install
````

## Usage

### Import

````swift
import ECPayPaymentGatewayKit
````

### Initialize
建議於 AppDelegate.swift 內執行初始化的動作，環境參數請參考下段說明。

````swift
ECPayPaymentGatewayManager.sharedInstance().initialize(env: .Stage)
````

請參考AppDelegate.swift 程式碼如下，可直接修改您想使用的環境：
````swift
//var envStr:String = "prod"
//if let env = Bundle.main.object(forInfoDictionaryKey: "ENV") as? String {
//    envStr = env.lowercased()
//}
//switch envStr {
//case "stage":
//    ECPayPaymentGatewayManager.sharedInstance().initialize(env: .Stage)
//    break
//default:
//    ECPayPaymentGatewayManager.sharedInstance().initialize(env: .Prod)
//    break
//}

//或者把上述程式碼 remark，並且直接改成您想使用的環境。
ECPayPaymentManager.sharedInstance().initialize(env: .Stage)
````

### CreatePayment
信用卡交易。填入交易 Token 以及交易編號等待 callback 即可。
ps: 下列程式碼請參考範例專案內 ViewController.swift
````swift
ECPayPaymentGatewayManager.sharedInstance().createPayment(token: token,
                                                          merchantID: "",
                                                          useResultPage: use_resultPage_Switch.isOn ? 1 : 0,
                                                          app"測試的商店(\(ECPayPaymentGatewayManager.sharedInstance().sdkEnvironmentString()))",
                                                          language: use_enUS_Switch.isOn ? "en-US" : "zh-TW")
{ (state) in
    //
    self.resultTextView.text = state.description
    
    print(state)
    print("")
    
    // if state.callbackStateStatus == .Success {
    //
    //     let state_ = state as! CreatePaymentCallbackState
    //     print("CreatePaymentCallbackState:")
    //     print(" RtnCode = \(state_.RtnCode)")
    //     print(" RtnMsg = \(state_.RtnMsg)")
    //     print(" MerchantID = \(state_.MerchantID)")
    //     print(" OrderInfo = \(state_.OrderInfo)")
    //     print(" CardInfo = \(state_.CardInfo)")
    //
    // }
    
    let ac = UIAlertController(title: "提醒您", message: "已經 callback，請看 console!", preferredStyle: UIAlertController.Style.alert)
    let aa = UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil)
    ac.addAction(aa)
    self.present(ac, animated: true, completion: nil)
}
````
## Contact

綠界科技 技術客服信箱：techsupport@ecpay.com.tw

## License

Copyright © 1996-2021 Green World FinTech Service Co., Ltd. All rights reserved. 
