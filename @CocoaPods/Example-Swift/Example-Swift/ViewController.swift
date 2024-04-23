//
//  ViewController.swift
//  Example-Swift
//
//  Created by ECPay.
//  Copyright © 2020 ECPay. All rights reserved.
//

import UIKit
import ECPayPaymentGatewayKit
import PromiseKit
import CryptoSwift
import Alamofire

class ViewController: UIViewController {
    
    //MARK: - properties
    //0:定期定額, 1:國旅卡, 2:付款選擇清單頁, 3:用於非交易類型
    private var tokenType:Int = 2 {
        didSet {
            flexibleInstallment_Switch.isOn = false
            flexibleInstallment_stackVw.isHidden = !(tokenType == 2) //等於2, 則不隱藏, 要互斥
        }
    }
    private var tokenTypeStrings:[String] = ["0:定期定額", "1:國旅卡", "2:付款選擇頁", "3:非交易類型"]
    private lazy var tokenTypePickerView:UIPickerView
        = UIPickerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height * 0.3, width: UIScreen.main.bounds.size.width, height: 150))
    
    
    //MARK: - IBOutlet
    @IBOutlet weak var applePayVIew: UIView!
    @IBOutlet var tokenTextField: UITextField!
    @IBOutlet var merchantTradeNoTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    @IBOutlet weak var versionLBL: UILabel!
    @IBOutlet weak var envLBL: UILabel!
    
    @IBOutlet weak var tokenTypeTextField: UITextField!
    
    @IBOutlet var tokenButton: UIButton!
    //@IBOutlet var apiTestButton: UIButton!
    @IBOutlet var payButton: UIButton!
    
    @IBOutlet weak var applePay_stackVw: UIStackView!
    @IBOutlet weak var applePay_Switch: UISwitch!
    
    @IBOutlet weak var flexibleInstallment_stackVw: UIStackView!
    @IBOutlet weak var flexibleInstallment_Switch: UISwitch!
    
    @IBOutlet weak var three_d_stackVw: UIStackView!
    @IBOutlet weak var three_d_Switch: UISwitch!
    
    
    @IBOutlet weak var merchant_id_stackVw: UIStackView!
    @IBOutlet weak var merchantIDTextField: UITextField!
    @IBOutlet weak var aes_key_stackVw: UIStackView!
    @IBOutlet weak var aesKeyTextField: UITextField!
    @IBOutlet weak var aes_iv_stackVw: UIStackView!
    @IBOutlet weak var aesIVTextField: UITextField!
    
    
    @IBOutlet weak var use_resultPage_Switch: UISwitch!
    @IBOutlet weak var use_enUS_Switch: UISwitch!
    
    @IBOutlet weak var backgroundColorTextField: UITextField!
    
    @IBOutlet weak var inputMerchatDataStack: UIStackView!
    @IBOutlet weak var testAEStackView: UIStackView!
    @IBOutlet weak var testAESwitch: UISwitch!
    
    var merchantData: (merchantID: String, aesKey: String, aesIV: String) {
        get {
            
            //正式環境
            if ECPayPaymentGatewayManager.sharedInstance().sdkEnvironmentString().lowercased() == "prod" {
                return (merchantIDTextField.text ?? "",
                        aesKeyTextField.text ?? "",
                        aesIVTextField.text ?? "")
            }
            
            //apple pay 測試啟動時, 強制帶入以下 merchant 資料
            if applePay_Switch.isOn {
                
                let merchantID = "3085064"
                let aesKey = "IbbuSaicEBXdejGm" //"GgfULm7egp1UtBWb"
                let aesIV = "hSNBNMLMMdLHTz0J" // "QzdMzx773m65zjw6"
                
                return (merchantID, aesKey, aesIV)
            }
            
            //依照原本的方式
            let is3D = three_d_Switch.isOn

            let merchantID = (is3D) ? "3002607" : "2000132"
            let aesKey = (is3D) ? "pwFHCqoQZGmho4w6" : "5294y06JbISpM5x9"
            let aesIV = (is3D) ? "EkRm7iFT261dpevs" : "v77hoKGq4kWxNNIS"
            
            return (merchantID, aesKey, aesIV)
        }
    }
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionLBL.text = bundleVersion
        }
        envLBL.text = ECPayPaymentGatewayManager.sharedInstance().sdkEnvironmentString()
        
        //apiTestButton.isEnabled = false
//        payButton.isEnabled = false
        
        //three_d_stackVw.isHidden = !(envLBL.text! == "Stage")
        //three_d_stackVw.isHidden = true
        
        //MARK: tokenType
        tokenType = 2
        tokenTypeTextField.inputView = tokenTypePickerView
        tokenTypePickerView.delegate = self as UIPickerViewDelegate
        tokenTypePickerView.dataSource = self as UIPickerViewDataSource
        
        tokenTypeChange()
        tokenTypePickerView.selectRow(tokenType, inComponent: 0, animated: false)
        
        backgroundColorTextField.delegate = self
        backgroundColorTextField.adjustsFontSizeToFitWidth = true
        backgroundColorTextField.minimumFontSize = 0.1
        
        //MARK: 依照環境隱藏
        applePay_Switch.isOn = false //預設 applePay 不給測, 除非 stage.
        
        var hideViews: [UIView] = [
            inputMerchatDataStack
        ]
        
        switch ECPayPaymentGatewayManager.sharedInstance().sdkEnvironmentString().lowercased() {
        case "prod":
            hideViews = [
                three_d_stackVw,
                three_d_Switch,
                testAEStackView
            ]
            
        case "stage":
            applePay_Switch.isOn = true
            switchChanged(mySwitch: applePay_Switch)
            testAEStackView.isHidden = true
        default:    // beta
            break
        }
        if applePay_Switch.isOn == false {
            //false 的時候隱藏不給測 apple pay.
            hideViews.append(contentsOf: [applePay_stackVw, applePay_Switch])
        }
        for hideView in hideViews {
            hideView.isHidden = true
        }
        
        let applePayBtn = ApplePayButton.loadViewFromXib()
        applePayBtn?.frame = self.applePayVIew.bounds
        applePayBtn?.onClickApplePayButton = {
            //MARK: Apple pay button 範例
            //請在此使用取得的token來呼叫createPaayment
            let params = self.tradeTokenRequestData(paymentUIType: self.tokenType, merchantID: self.merchantData.merchantID)
            ECPayPaymentGatewayManager.sharedInstance().eTestingTK(paymentUIType: self.tokenType,
                                                                                   is3D: self.three_d_Switch.isOn,
                                                                                   merchantID: self.merchantData.merchantID,
                                                                                   aesKey: self.merchantData.aesKey,
                                                                                   aesIV: self.merchantData.aesIV,
                                                                                   parameters: params){ (state) in

                self.stopLoading()

                print("state.callbackStateStatus = \(state.callbackStateStatus.toString())")
                print("state.callbackStateMessage = \(state.callbackStateMessage)")
                print("")

                if state.callbackStateStatus == .Success {

                    self.switchChanged(mySwitch: self.three_d_Switch)

                    let state_ = state as! TestingTokenCallbackState
                    self.tokenTextField.text = state_.Token
                    //self.merchantTradeNoTextField.text = String(state_.MerchantTradeNo)
                    //self.apiTestButton.isEnabled = true
//                    self.payButton.isEnabled = true
                    
                    ECPayPaymentGatewayManager.sharedInstance().createPayment(token: self.tokenTextField.text!,
                                                                              merchantID: "",
                                                                              useResultPage: self.use_resultPage_Switch.isOn ? 1 : 0,
                                                                              appStoreName: "測試的商店(\(ECPayPaymentGatewayManager.sharedInstance().sdkEnvironmentString()))",
                                                                              language: self.use_enUS_Switch.isOn ? "en-US" : "zh-TW",
                                                                              isUseApplePayButton: true)
                    { (state) in
                        //
                        self.resultTextView.text = state.description

        //                print(state)
        //                print("")

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
                                print("\(order.TradeStatus ?? "")")
                                print("\(order.PaymentDate)")
                                print("\(order.TradeAmt ?? 0)")
                                print("\(order.PaymentType ?? "")")
                                print("\(order.ChargeFee ?? 0)")
                                print("\(order.TradeStatus ?? "")")

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
                                print("\(card.PeriodType ?? "")")
                                print("\(card.Frequency ?? 0)")
                                print("\(card.ExecTimes ?? 0)")
                                print("\(card.PeriodAmount ?? 0)")
                                print("\(card.TotalSuccessTimes ?? 0)")
                                print("\(card.TotalSuccessAmount ?? 0)")
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

                } else {
                    let ac = UIAlertController(title: "提醒您", message: state.callbackStateMessage, preferredStyle: UIAlertController.Style.alert)
                    let aa = UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil)
                    ac.addAction(aa)
                    self.present(ac, animated: true, completion: nil)
                    self.resultTextView.text = state.callbackStateMessage
                }
            }
        }
        self.applePayVIew.addSubview(applePayBtn!)

    }
    func tokenTypeChange() {
        self.tokenTypeTextField.text = self.tokenTypeStrings[self.tokenType]
    }
    //MARK: - IBAction
    @IBAction func getToken(_ sender: Any) {
        if tokenTypeTextField.isFirstResponder {
            tokenTypeTextField.resignFirstResponder()
        }
        
        self.tokenTextField.text = ""
        //self.apiTestButton.isEnabled = false
//        self.payButton.isEnabled = false
        
        let isTradeToken:Bool = (tokenType < 3)
        let isUserToken:Bool = !isTradeToken
        
        self.loading()
        
        //MARK: trade token
        if isTradeToken {
            //取得tradeToken
            let params = tradeTokenRequestData(paymentUIType: tokenType, merchantID: merchantData.merchantID)
            ECPayPaymentGatewayManager.sharedInstance().isAETest = testAESwitch.isOn
            ECPayPaymentGatewayManager.sharedInstance().eTestingTK(paymentUIType: tokenType,
                                                                                   is3D: three_d_Switch.isOn,
                                                                                   merchantID: merchantData.merchantID,
                                                                                   aesKey: merchantData.aesKey,
                                                                                   aesIV: merchantData.aesIV,
                                                                                   parameters: params){ (state) in
                
                self.stopLoading()

                print("state.callbackStateStatus = \(state.callbackStateStatus.toString())")
                print("state.callbackStateMessage = \(state.callbackStateMessage)")
                print("")

                if state.callbackStateStatus == .Success {

                    self.switchChanged(mySwitch: self.three_d_Switch)

                    let state_ = state as! TestingTokenCallbackState
                    self.tokenTextField.text = state_.Token
                    //self.merchantTradeNoTextField.text = String(state_.MerchantTradeNo)
                    //self.apiTestButton.isEnabled = true
//                    self.payButton.isEnabled = true

                } else {
                    let ac = UIAlertController(title: "提醒您", message: state.callbackStateMessage, preferredStyle: UIAlertController.Style.alert)
                    let aa = UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil)
                    ac.addAction(aa)
                    self.present(ac, animated: true, completion: nil)
                    self.resultTextView.text = state.callbackStateMessage
                }
            }
        }
        
        //MARK: user token
        if isUserToken {
            //取得userToken
            let params = userTokenRequestData(merchantData.merchantID)
            ECPayPaymentGatewayManager.sharedInstance().eTestUT(is3D: three_d_Switch.isOn,
                                                                                  merchantID: merchantData.merchantID,
                                                                                  aesKey: merchantData.aesKey,
                                                                                  aesIV: merchantData.aesIV,
                                                                                  parameters: params) { (state) in
                self.stopLoading()
                
                print("state.callbackStateStatus = \(state.callbackStateStatus.toString())")
                print("state.callbackStateMessage = \(state.callbackStateMessage)")
                print("")

                if state.callbackStateStatus == .Success {

                    self.switchChanged(mySwitch: self.three_d_Switch)

                    let state_ = state as! TestingTokenCallbackState
                    self.tokenTextField.text = state_.Token
                    //self.merchantTradeNoTextField.text = String(state_.MerchantTradeNo)
                    //self.apiTestButton.isEnabled = true
//                    self.payButton.isEnabled = true

                } else {
                    let ac = UIAlertController(title: "提醒您", message: state.callbackStateMessage, preferredStyle: UIAlertController.Style.alert)
                    let aa = UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil)
                    ac.addAction(aa)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func pay(_ sender: Any) {
        
        if tokenTypeTextField.isFirstResponder {
            tokenTypeTextField.resignFirstResponder()
        }
        
        if backgroundColorTextField.isFirstResponder {
            backgroundColorTextField.resignFirstResponder()
        }
        
        if
            let token = self.tokenTextField.text
            //,let merchantTradeNo = self.merchantTradeNoTextField.text
        {
            //
            ECPayPaymentGatewayManager.sharedInstance().createPayment(token: token,
                                                                      merchantID: "",
                                                                      useResultPage: use_resultPage_Switch.isOn ? 1 : 0,
                                                                      appStoreName: "測試的商店(\(ECPayPaymentGatewayManager.sharedInstance().sdkEnvironmentString()))",
                                                                      language: use_enUS_Switch.isOn ? "en-US" : "zh-TW")
            { (state) in
                //
                self.resultTextView.text = state.description
                
//                print(state)
//                print("")
                
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
                        print("\(order.TradeStatus ?? "")")
                        print("\(order.PaymentDate)")
                        print("\(order.TradeAmt ?? 0)")
                        print("\(order.PaymentType ?? "")")
                        print("\(order.ChargeFee ?? 0)")
                        print("\(order.TradeStatus ?? "")")
                        
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
                        print("\(card.PeriodType ?? "")")
                        print("\(card.Frequency ?? 0)")
                        print("\(card.ExecTimes ?? 0)")
                        print("\(card.PeriodAmount ?? 0)")
                        print("\(card.TotalSuccessTimes ?? 0)")
                        print("\(card.TotalSuccessAmount ?? 0)")
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
        }
    }
    @IBAction func apiTest(_ sender: Any) {
        
        ECPayPaymentGatewayManager.sharedInstance().testToLaunchApiTestUI(tokenType: self.tokenType,
                                                                          tokenTypeString: self.tokenTypeStrings[self.tokenType],
                                                                          token: tokenTextField.text!)
        { (state) in
            
            self.resultTextView.text = state.description
            print(state)
            print("")
            
            let ac = UIAlertController(title: "提醒您", message: "已經 callback，請看 console!", preferredStyle: UIAlertController.Style.alert)
            let aa = UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil)
            ac.addAction(aa)
            self.present(ac, animated: true, completion: nil)
        }
    }
    @IBAction func switchChanged(mySwitch: UISwitch) {
        //let value = mySwitch.isOn

        switch mySwitch {
        case three_d_Switch:
            
            self.tokenTextField.text = ""
            self.merchantTradeNoTextField.text = ""
            //self.apiTestButton.isEnabled = false
//            self.payButton.isEnabled = false
            self.resultTextView.text = ""
            
        case applePay_Switch:
            
            switchChanged(mySwitch: self.three_d_Switch)
            
            self.three_d_Switch.isOn = false
            let showHideViews = [three_d_Switch, three_d_stackVw]
            for view in showHideViews {
                view?.isHidden = mySwitch.isOn
            }
            if mySwitch.isOn == false {
                self.three_d_Switch.isOn = false
            }

        case testAESwitch:
            three_d_Switch.isOn = false
            three_d_stackVw.isHidden = mySwitch.isOn
        default:
            break
        }
        
    }
}
//MARK:- UIPickerViewDelegate / UIPickerViewDataSource
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tokenTypeStrings.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tokenTypeStrings[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tokenType = row
        self.tokenTypeChange()
        self.switchChanged(mySwitch: self.three_d_Switch) //切換類型時，強制把 token 等文字框欄位清空。
    }
}


extension ViewController {

    func tradeTokenRequestData(paymentUIType: Int = 0, merchantID: String) -> [String: Any] {
        let periodType:String = "M"
        let frequency:Int = 12 //至少要大於等於 1次以上。
                             //當 PeriodType 設為 D 時，最多可設 365次。
                             //當 PeriodType 設為 M 時，最多可設 12 次。
                             //當 PeriodType 設為 Y 時，最多可設 1 次。
        
        let execTimes:Int = 99 //至少要大於 1 次以上。
                             //當 PeriodType 設為 D 時，最多可設 999次。
                             //當 PeriodType 設為 M 時，最多可設 99 次。
                             //當 PeriodType 設為 Y 時，最多可設 9 次。
        let paymentListType = 0 //currentTestMode == TestMode.is3D ? "1" : "0"
        var totalAmount_ = 200
        var cardInfo = [
            "Redeem":"0",
            "PeriodAmount":paymentUIType == 0 ? totalAmount_ : 0, //當PaymentUIType為0時，此欄位必填 (必須等於TotalAmount)
            "PeriodType":periodType,
            "Frequency":frequency,
            "ExecTimes":execTimes,
            "OrderResultURL":"https://www.microsoft.com/",
            "PeriodReturnURL":"https://www.ecpay.com.tw/",
            "CreditInstallment":"3,12,24"
//            "CreditInstallment":"3,12,24",
//            "FlexibleInstallment":"30"
        ] as [String : Any]
        
        // tokenType:Int = 2 //0:定期定額, 1:國旅卡, 2:付款選擇清單頁, 3:用於非交易類型
        if tokenType == 1 {
            //國旅
            
//            "TravelStartDate":getMMDDYYYY(),
//            "TravelEndDate":getMMDDYYYY(),
//            "TravelCounty":"001",
            
            cardInfo["TravelStartDate"] = getMMDDYYYY()
            cardInfo["TravelEndDate"] = getMMDDYYYY()
            cardInfo["TravelCounty"] = "001"
            
        }
        if tokenType == 2 && flexibleInstallment_stackVw.isHidden == false && flexibleInstallment_Switch.isOn {
            totalAmount_ = 20000
            cardInfo["FlexibleInstallment"] = "30"
        }

        let decryptedDictionary
        =
        [
            "MerchantID": merchantID,
            "RememberCard": 1,
            "PaymentUIType": paymentUIType,
            "ChoosePaymentList": paymentListType, //0:全部，1:單純信用卡一次繳清
            "OrderInfo": [
               //"MerchantTradeNo": "4200000515202003205168406290",
                "MerchantTradeNo": Int(Date().timeIntervalSince1970 * 1000),
               "MerchantTradeDate": getCurrentDateString(), //"2018/09/03 18:35:20",
               "TotalAmount": totalAmount_,
               "ReturnURL":"https://tw.yahoo.com/",
               "TradeDesc":"測試交易",
               "ItemName":"測試商品"
            ],
            "CardInfo": cardInfo,
            "ATMInfo":[
                "ExpireDate":5
            ],
            "CVSInfo":[
                "StoreExpireDate":"10080",
                "Desc_1":"條碼一",
                "Desc_2":"條碼二",
                "Desc_3":"條碼三",
                "Desc_4":"條碼四"
            ],
            "BarcodeInfo":[
                "StoreExpireDate":5
            ],
            "ConsumerInfo": [
                "MerchantMemberID": "1234567",
                "Email": "test@gmail.com",
                "Phone": "0910000222",
                "Name": "黃小鴨",
                "CountryCode":"002",
                "Address": "台北市南港區三重路19-2號 6號棟樓之2, D"
            ],
            "CardList":[
                ["PayToken":"123456789","Card6No":"123456","Card4No":"1234","IsValid":1,"BankName":"玉山銀行","Code":"002"],
                ["PayToken":"987456123","Card6No":"654123","Card4No":"1111","IsValid":1,"BankName":"台新銀行","Code":"003"]
            ],
            "UnionPayInfo":[
                "OrderResultURL": "https://www.ecpay.com.tw/"
            ]
        ] as [String : Any]
        
        return decryptedDictionary
    }
    func userTokenRequestData(_ merchantID: String) -> [String: Any] {
        let decryptedDictionary: [String:Any]
        =
        [
            "PlatformID": merchantID,
            "MerchantID": merchantID,
            "ConsumerInfo": [
                "MerchantMemberID":"1234567",
                "Email": "test@gmail.com",
                "Phone": "0910000222",
                "Name": "黃小鴨",
                "CountryCode":"002",
                "Address": ""
            ],
        ] as [String:Any]
        
        return decryptedDictionary
    }
    func getMMDDYYYY() -> String {
        let date = Date()
        let format = DateFormatter()
        //format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        format.dateFormat = "MMddyyyy"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    func getCurrentDateString() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss"
        //format.dateFormat = "MMddyyyy"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let strColor = textField.text else{return}
        ECPayPaymentGatewayManager.sharedInstance().setTitleBarBackgroundColor(colorString: strColor)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
