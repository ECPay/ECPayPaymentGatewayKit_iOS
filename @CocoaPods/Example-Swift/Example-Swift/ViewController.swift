//
//  ViewController.swift
//  Example-Swift
//
//  Created by Mingfeng Ho 何明峯 on 2020/5/7.
//  Copyright © 2020 ECPay. All rights reserved.
//

import UIKit
import ECPayPaymentGatewayKit
import PromiseKit
import CryptoSwift
import Alamofire

class ViewController: UIViewController {
    
    //MARK: - properties
    private var tokenType:Int = 2 //0:定期定額, 1:國旅卡, 2:付款選擇清單頁, 3:用於非交易類型
    private var tokenTypeStrings:[String] = ["0:定期定額", "1:國旅卡", "2:付款選擇頁", "3:非交易類型"]
    private lazy var tokenTypePickerView:UIPickerView
        = UIPickerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height * 0.3, width: UIScreen.main.bounds.size.width, height: 150))
    
    
    //MARK: - IBOutlet
    @IBOutlet var tokenTextField: UITextField!
    @IBOutlet var merchantTradeNoTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    @IBOutlet weak var versionLBL: UILabel!
    @IBOutlet weak var envLBL: UILabel!
    
    @IBOutlet weak var tokenTypeTextField: UITextField!
    
    @IBOutlet var tokenButton: UIButton!
    //@IBOutlet var apiTestButton: UIButton!
    @IBOutlet var payButton: UIButton!
    
    @IBOutlet weak var three_d_stackVw: UIStackView!
    @IBOutlet weak var three_d_Switch: UISwitch!
    @IBOutlet weak var use_resultPage_Switch: UISwitch!
    @IBOutlet weak var use_enUS_Switch: UISwitch!
    
    var merchantData: (merchantID: String, aesKey: String, aesIV: String) {
        get {
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
        payButton.isEnabled = false
        
        //three_d_stackVw.isHidden = !(envLBL.text! == "Stage")
        //three_d_stackVw.isHidden = true
        
        //MARK: tokenType
        tokenTypeTextField.inputView = tokenTypePickerView
        tokenTypePickerView.delegate = self as UIPickerViewDelegate
        tokenTypePickerView.dataSource = self as UIPickerViewDataSource
        
        tokenTypeChange()
        tokenTypePickerView.selectRow(tokenType, inComponent: 0, animated: false)
        
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
        self.payButton.isEnabled = false
        
        let isTradeToken:Bool = (tokenType < 3)
        let isUserToken:Bool = !isTradeToken
        
        self.loading()
        
        //MARK: trade token
        if isTradeToken {
            
            ECPayPaymentGatewayManager.sharedInstance().testToGetTestingTradeToken(paymentUIType: tokenType,
                                                                                   is3D: three_d_Switch.isOn,
                                                                                   merchantID: merchantData.merchantID,
                                                                                   aesKey: merchantData.aesKey,
                                                                                   aesIV: merchantData.aesIV){ (state) in
                
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
                    self.payButton.isEnabled = true

                } else {
                    let ac = UIAlertController(title: "提醒您", message: state.callbackStateMessage, preferredStyle: UIAlertController.Style.alert)
                    let aa = UIAlertAction(title: "好", style: UIAlertAction.Style.default, handler: nil)
                    ac.addAction(aa)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
        
        //MARK: user token
        if isUserToken {
            ECPayPaymentGatewayManager.sharedInstance().testToGetTestingUserToken(is3D: three_d_Switch.isOn,
                                                                                  merchantID: merchantData.merchantID,
                                                                                  aesKey: merchantData.aesKey,
                                                                                  aesIV: merchantData.aesIV) { (state) in
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
                    self.payButton.isEnabled = true

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
        if mySwitch.isEqual(self.three_d_Switch) {
            
            self.tokenTextField.text = ""
            self.merchantTradeNoTextField.text = ""
            //self.apiTestButton.isEnabled = false
            self.payButton.isEnabled = false
            self.resultTextView.text = ""
            
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
