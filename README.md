## 若您有興趣了解站內付2.0的服務，請前往以下網址並填寫資料，我們將派專人與您聯繫
## https://member.ecpay.com.tw/MemberReg/MerchantRegister

# 站內付2.0_iOS版

## About

此套件提供手機端的全功能付款功能。

- 整合商家信用卡金流服務
- 消費者直接輸入信用卡號並且付款
- 支援信用卡端 3D驗證流程
- 支援非信用卡付款方式
- 支援AE卡

## Requirements

* XCode 15+ **(SDK 1.5.0 版本之後將不再支援XCode15以下的版本)**
* Swift 5.5+
* iOS 13+
* Cocoapods 1.12.1+

## Installation

### 支援套件管理

> 請注意，此套件使用 XCFramework 製作，Cocoapods 的版本必須要是 1.12.1 以上。
    <br />
    XCode15 以下的版本 從 SDK 1.5.0 版本之後將不再支援

### [CocoaPods](http://cocoapods.org)
[![CocoaPods](https://img.shields.io/cocoapods/v/ECPayPaymentGatewayKit.svg)](https://cocoapods.org/pods/ECPayPaymentGatewayKit)

Podfile內容

````ruby
#版本號自 1.5.0 起, SDK 僅支援 XCode15+。
pod 'ECPayPaymentGatewayKit', '1.6.0'
````

此套件相依其他 CocoaPods 套件，詳細清單如下：
````ruby
pod 'PromiseKit' , '6.8.5'
pod 'Alamofire', '5.2.2'
pod 'IQKeyboardManagerSwift'
pod 'KeychainSwift', '16.0.1'
#pod 'SwiftyJSON', '~> 4.2.0'  #自版本號 1.3.2 起, 移除了 SwiftyJSON 的套件參考.
pod 'SwiftyXMLParser', :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
pod 'CryptoSwift', '1.4.1'
````

由於此套件為 static framework，我們在安裝 cocoapods 前，需要以下指令在 podfile 最底部
```ruby
static_frameworks = ['ECPayPaymentGatewayKit']
pre_install do |installer|
  installer.pod_targets.each do |pod|
    if static_frameworks.include?(pod.name)
      puts "#{pod.name} installed as static framework!"
      def pod.static_framework?;
        true
      end
    end
  end
end

```

範例專案以 Swift 為主，安裝時請在 [Podfile] 同層目錄下執行以下指令：

````ruby
pod install
````

若要避免快取，我們可以改由以下的指令安裝。

````ruby
#曾經安裝過SDK的話，請先解除安裝
pod deintegrate '可能需要有 .xcodeproj 的路徑' 
#再清除快取 (若有多個，請多次執行該指令刪除)
pod cache clean ECPayPaymentGatewayKit

#重新安裝更新的版本
pod install --repo-update
````
<!-- 
## XCode 12, 安裝方法如下

請先下載 ECPayPaymentGatewayKit.podspec 檔案, 各版本連結如下
* *[1.1.0(1.1.0.65) for XCode 12 podspec file](https://github.com/ECPay/ECPayPaymentGatewayKit_iOS/releases/download/1.1.0_XCode12/ECPayPaymentGatewayKit.podspec)*
* *[1.2.0(1.2.0.40) for XCode 12 podspec file](https://github.com/ECPay/ECPayPaymentGatewayKit_iOS/releases/download/1.2.0_XCode12/ECPayPaymentGatewayKit.podspec)*
* *[1.2.1(1.2.1.7) for XCode 12 podspec file](https://github.com/ECPay/ECPayPaymentGatewayKit_iOS/releases/download/1.2.1_XCode12/ECPayPaymentGatewayKit.podspec)*

Podfile 內, 移除原本的語法 

> ~~'pod ECPayPaymentGatewayKit', '~> 1.1.0'~~

> ~~'pod ECPayPaymentGatewayKit', '~> 1.2.0'~~

> ~~'pod ECPayPaymentGatewayKit', '~> 1.2.1'~~

確認好你的 podspec 檔案路徑, 然後在 Podfile 內輸入以下

```ruby
pod 'ECPayPaymentGatewayKit', :podspec => '/你的路徑/ECPayPaymentGatewayKit.podspec'
```
曾經安裝過SDK的話，請先解除安裝

```ruby
pod deintegrate '可能需要有 .xcodeproj 的路徑' 
```
請記得做 cache clean, 確保安裝同個版本不會使用到暫存的快取資料

```ruby
pod cache clean ECPayPaymentGatewayKit
```

再一次安裝 (安裝自本地端的 podspec 檔案)
```ruby
pod install --repo-update
```
 -->




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
信用卡交易。填入交易 Token 以及交易編號等待 callback 即可。請參考 ViewController.swift 程式碼如下：
````swift
ECPayPaymentGatewayManager.sharedInstance().createPayment(token: token,
                                                          merchantID: "",
                                                          useResultPage: use_resultPage_Switch.isOn ? 1 : 0,
                                                          app"測試的商店(\(ECPayPaymentGatewayManager.sharedInstance().sdkEnvironmentString()))",
                                                          language: use_enUS_Switch.isOn ? "en-US" : "zh-TW")
{ (state) in
    //
    self.resultTextView.text = state.description
    
//    print(state)
//    print("")
    
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

    if let callbackState = state as? CreatePaymentCallbackState {
        
        print("CreatePaymentCallbackState:")
        print("RtnCode = \(callbackState.RtnCode)")
        print("RtnMsg = \(callbackState.RtnMsg)")
        
        if let order = callbackState.OrderInfo {
            print("\(order)")
            print("\(order.MerchantTradeNo ?? "")")
            print("\(order.TradeNo ?? "")")
            print("\(order.TradeDate)")
            print("\(order.TradeStatus ?? 0)")
        }
        if let card = callbackState.CardInfo {
            print("\(card)")
            print("\(card.AuthCode ?? "")")
            print("\(card.Gwsr ?? "")")
            print("\(card.ProcessDate)")
            print("\(card.Stage ?? 0)")
            print("\(card.Stast ?? 0)")
            print("\(card.Staed ?? 0)")
            print("\(card.Amount ?? 0)")
            print("\(card.Eci ?? 0)")
            print("\(card.Card6No ?? "")")
            print("\(card.Card4No ?? "")")
            print("\(card.RedDan ?? 0)")
            print("\(card.RedDeAmt ?? 0)")
            print("\(card.RedOkAmt ?? 0)")
            print("\(card.RedYet ?? 0)")
        }
        if let atm = callbackState.ATMInfo {
            print("\(atm)")
            print("\(atm.BankCode ?? "")")
            print("\(atm.vAccount ?? "")")
            print("\(atm.ExpireDate)")
        }
        if let cvs = callbackState.CVSInfo {
            print("\(cvs)")
            print("\(cvs.PaymentNo ?? "")")
            print("\(cvs.ExpireDate)")
            print("\(cvs.PaymentURL ?? "")")
        }
        if let barcode = callbackState.BarcodeInfo {
            print("\(barcode)")
            print("\(barcode.ExpireDate)")
            print("\(barcode.Barcode1 ?? "")")
            print("\(barcode.Barcode2 ?? "")")
            print("\(barcode.Barcode3 ?? "")")
        }
        if let unionpay = callbackState.UnionPayInfo {
            print("\(unionpay.UnionPayURL ?? "")")
        }
    }
    
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

