//
//  ExampleViewController.swift
//  Example-Swift
//
//  Created by ECPay.
//  Copyright © 2024 GWPaymentGateway. All rights reserved.
//

import UIKit
import ECPayPaymentGatewayKit
import PromiseKit
import CryptoSwift
import Alamofire

class ExampleViewController: UIViewController {
    
    @IBOutlet weak var exampleInfoLabel: UILabel!
    @IBOutlet weak var sdkResultStackView: UIStackView!
    @IBOutlet weak var sdkResultTextView: UITextView!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var userResultPageTextField: UITextField!
    @IBOutlet weak var appStoreNameTextField: UITextField!
    @IBOutlet weak var isUseApplePayButtonTextField: UITextField!
    @IBOutlet weak var titleBarBackgroundColorTextField: UITextField!
    @IBOutlet weak var applePayButtonStackView: UIStackView!
    @IBOutlet weak var applePayButtonContainerView: UIView!
    
    @IBOutlet weak var closeSDKResultButton: UIButton!
    @IBOutlet weak var callSDKButton: UIButton!
    @IBOutlet weak var openDocumentationButton: UIButton!
    @IBAction func onButtonTapped(_ sender: UIButton) {
        switch sender {
        case closeSDKResultButton:
            sdkResultStackView.isHidden = true
            sdkResultTextView.text = nil
        case callSDKButton:
            callSDK()
        case openDocumentationButton:
            guard let url = URL(string: "https://developers.ecpay.com.tw/?p=9222") else { return }
            UIApplication.shared.open(url)
        default:
            break
        }
    }
    
    private var pickerData: PickerDataSource = PickerDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareExampleInfoLabel()
        prepareSDKResult()
        prepareTextFields()
        prepareApplePay()
    }
    
    func prepareExampleInfoLabel() {
        var info = [String]()
        let sdk = ECPayPaymentGatewayManager.sharedInstance()
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            info.append(bundleVersion)
        }
        info.append(sdk.sdkEnvironmentString())
        info.append(" ")
        exampleInfoLabel.text = info.joined(separator: " ")
    }
    func prepareSDKResult() {
        sdkResultStackView.isHidden = true
        sdkResultTextView.text = nil
    }
    func prepareTextFields() {
        let inputTextFields: [UITextField] = [tokenTextField, languageTextField, userResultPageTextField, appStoreNameTextField, isUseApplePayButtonTextField, titleBarBackgroundColorTextField]
        for (_, item) in inputTextFields.enumerated() {
//            print(index)
            item.delegate = self
        }
        
        let pickerTextFields: [UITextField] = [languageTextField, userResultPageTextField, isUseApplePayButtonTextField]
        for (_, item) in pickerTextFields.enumerated() {
//            print(index)
            item.inputView = UIPickerView()
            (item.inputView as? UIPickerView)?.delegate = self
            (item.inputView as? UIPickerView)?.dataSource = self
        }
    }
    func prepareApplePay() {
        view.layoutIfNeeded()
        let appleButtonView = ApplePayButton.loadViewFromXib()!
        applePayButtonContainerView.addSubview(appleButtonView)
        appleButtonView.frame = applePayButtonContainerView.bounds
        appleButtonView.onClickApplePayButton = { [weak self] in
            self?.callSDK()
        }
        applePayButtonStackView.isHidden = !callSDKButton.isHidden
    }
    func applePayButtonDisplayFunction(isUseApplePayButtonTxt txt: String) {
        if txt == "是" {
            callSDKButton.isHidden = true
        } else {
            callSDKButton.isHidden = false
        }
        applePayButtonStackView.isHidden = !callSDKButton.isHidden
    }
    func dumpSDKResult(createPaymentCallbackState state: CreatePaymentCallbackState) {
        sdkResultStackView.isHidden = false
        sdkResultTextView.text = state.description
    }
}

extension ExampleViewController {
    func callSDK() {
        let sdk = ECPayPaymentGatewayManager.sharedInstance()
        let param = prepareSDKParam()
        loading()
        sdk.createPayment(token: param.token ?? "",
                          useResultPage: param.useResultPage ?? 0,
                          appStoreName: param.appStoreName ?? "測試商店",
                          language: param.language ?? "zh-TW",
                          isUseApplePayButton: param.isUseApplePayButton ?? true) { [weak self] state in
            
            self?.stopLoading()
            guard let cs = state as? CreatePaymentCallbackState else { return }
            
            self?.dumpSDKResult(createPaymentCallbackState: cs)
            
            switch cs.callbackStateStatus {
            case .Success:
//                print(cs.description)
                break
            case .Fail, .Exit, .Cancel, .Unknown:
                let alert = UIAlertController(title: "Alert", message: cs.callbackStateMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default))
                self?.present(alert, animated: true)
            default:
                break
            }
        }
    }
    func prepareSDKParam() -> SDKParamModel {
        var model = SDKParamModel()
        model.token = tokenTextField.text
        model.useResultPage = (userResultPageTextField.text! == "否" ? 0 : 1)
        model.appStoreName = appStoreNameTextField.text ?? "測試商店"
        model.language = (languageTextField.text! == "en-US" ? "en-US" : "zh-TW")
        model.isUseApplePayButton = (isUseApplePayButtonTextField.text! == "是" ? true : false)
        return model
    }
}

extension ExampleViewController {
    struct PickerDataSource {
        var languageDatas: [String] = ["zh-TW", "en-US"]
        var userResultPageDatas: [String] = ["是", "否"]
        var isUseApplePayButtonDatas: [String] = ["是", "否"]
    }
    struct SDKParamModel {
        var token: String?
        var merchantID: String?
        var useResultPage: Int?
        var appStoreName: String?
        var language: String?
        var isUseApplePayButton: Bool?
    }
}

extension ExampleViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case tokenTextField:
            break
        case appStoreNameTextField:
            break
        case titleBarBackgroundColorTextField:
            break
        case languageTextField, userResultPageTextField, isUseApplePayButtonTextField:
            break
        default:
            break
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case tokenTextField:
            break
        case appStoreNameTextField:
            break
        case titleBarBackgroundColorTextField:
            let sdk = ECPayPaymentGatewayManager.sharedInstance()
            sdk.setTitleBarBackgroundColor(colorString: textField.text!)
        case languageTextField, userResultPageTextField, isUseApplePayButtonTextField:
            if let pv = textField.inputView as? UIPickerView {
                let row = pv.selectedRow(inComponent: 0)
                textField.text = pickerView(pv, titleForRow: row, forComponent: 0)
            }
            if textField == isUseApplePayButtonTextField,
               let txt = textField.text {
                applePayButtonDisplayFunction(isUseApplePayButtonTxt: txt)
            }
            break
        default:
            break
        }
    }
}
extension ExampleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var length = 0
        switch pickerView {
        case languageTextField.inputView as? UIPickerView:
            length = pickerData.languageDatas.count
        case userResultPageTextField.inputView as? UIPickerView:
            length = pickerData.userResultPageDatas.count
        case isUseApplePayButtonTextField.inputView as? UIPickerView:
            length = pickerData.isUseApplePayButtonDatas.count
        default:
            print("嘟 nothing")
        }
        return length
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var txt: String?
        switch pickerView {
        case languageTextField.inputView as? UIPickerView:
            txt = pickerData.languageDatas[row]
        case userResultPageTextField.inputView as? UIPickerView:
            txt = pickerData.userResultPageDatas[row]
        case isUseApplePayButtonTextField.inputView as? UIPickerView:
            txt = pickerData.isUseApplePayButtonDatas[row]
        default:
            print("嘟 nothing")
        }
        return txt
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case isUseApplePayButtonTextField.inputView as? UIPickerView:
            guard let txt = self.pickerView(pickerView, titleForRow: row, forComponent: component) else { return }
            applePayButtonDisplayFunction(isUseApplePayButtonTxt: txt)
        default:
            print("嘟 nothing")
        }
    }
    
}
