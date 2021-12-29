//
//  UIViewController+Loading.swift
//  ECPayPaymentGatewayKit
//
//  Created by Aaron Yen on 2020/5/27.
//  Copyright © 2020 ECPay. All rights reserved.
//

import UIKit

typealias VC = UIViewController
extension UIViewController {
    static func topUI() -> UIViewController? {
        guard
            let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController
        else {
            return nil
        }
        var topController = rootViewController
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        return topController
    }
}
extension UIViewController {
    func loadingViewTag() -> Int {
        return 9074444
    }
    func loading() {
        
        let maskView = UIView()
        maskView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.55)
        maskView.tag = loadingViewTag()
        maskView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(maskView)
        
        let chrysanthemumView = UIActivityIndicatorView()
        maskView.addSubview(chrysanthemumView)
        chrysanthemumView.translatesAutoresizingMaskIntoConstraints = false
        chrysanthemumView.startAnimating()

        let views = ["vw": view, "maskVw": maskView, "chrysanthemumVw": chrysanthemumView]
        
        let offset:Int = 0
        
        let topConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(offset))-[maskVw]",
                                                            options: NSLayoutConstraint.FormatOptions.alignAllTop,
                                                            metrics: nil,
                                                            views: views as [String:Any])
        
        let bottomConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[maskVw]-(\(offset))-|",
                                                               options: NSLayoutConstraint.FormatOptions.alignAllBottom,
                                                               metrics: nil,
                                                               views: views as [String:Any])
        
        let leadingConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(offset))-[maskVw]",
                                                               options: NSLayoutConstraint.FormatOptions.alignAllLeading,
                                                               metrics: nil,
                                                               views: views as [String:Any])
        
        let trailingConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[maskVw]-(\(offset))-|",
                                                                 options: NSLayoutConstraint.FormatOptions.alignAllTrailing,
                                                                 metrics: nil,
                                                                 views: views as [String:Any])
        view.addConstraints(topConstraints)
        view.addConstraints(bottomConstraints)
        view.addConstraints(leadingConstraints)
        view.addConstraints(trailingConstraints)

        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[maskVw]-(<=0)-[chrysanthemumVw]",
                                                                   options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                   metrics: nil,
                                                                   views: views as [String : Any])
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[maskVw]-(<=0)-[chrysanthemumVw]",
                                                                 options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: views as [String : Any])
        maskView.addConstraints(horizontalConstraints)
        maskView.addConstraints(verticalConstraints)
        
    }
    func stopLoading() {
        
        if let view = view.viewWithTag(loadingViewTag()) {
            view.removeFromSuperview()
        }
        
    }
}

//MARK:- child view controller
//
//  https://zhuanlan.zhihu.com/p/31644386
//
extension UIViewController {

    func add(_ child: UIViewController) {
        self.add(child, on: self.view)
    }
    func add(_ child: UIViewController, on v:UIView) {
        addChild(child)
        v.addSubview(child.view)
    //            child.view.snp.makeConstraints { (make) in
    //                make.top.left.bottom.right.equalToSuperview()
    //            }
        
        child.didMove(toParent: self)
    }
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

//extension UIViewController {
//    func addLeftBarQuitButton() {
//        
//        let leftButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
//        
//        let image = UIImage(named: "ap_btn_left_white_bold_arrow",in: Bundle.ECPayPaymentGatewayKit,compatibleWith: nil)
//        if #available(iOS 11.0, *) {
//            leftButton.frame = CGRect.init(x: 0, y: 0, width: 32, height: 30)
//            leftButton.setImage(image, for: UIControl.State.normal)
//        } else {
//            leftButton.frame = CGRect.init(x: 0, y: 0, width: (image?.size.width ?? 32) - 1, height: 30)
//            leftButton.setImage(image, for: UIControl.State.normal)
//        }
//        
////        leftButton.tag = LeftBarButtonType.quit.rawValue
//        leftButton.addTarget(self
//            , action: #selector(dismiss(animated:completion:))
//            , for: UIControl.Event.touchUpInside
//        )
//        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
//    }
//    
//    func addLeftBarCustomActionQuitButton(action:@escaping () -> Void) {
//        
//        let leftButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
//        
//        let image = UIImage(named: "ap_btn_left_white_bold_arrow",in: Bundle.ECPayPaymentGatewayKit,compatibleWith: nil)
//        if #available(iOS 11.0, *) {
//            leftButton.frame = CGRect.init(x: 0, y: 0, width: 32, height: 30)
//            leftButton.setImage(image, for: UIControl.State.normal)
//        } else {
//            leftButton.frame = CGRect.init(x: 0, y: 0, width: (image?.size.width ?? 32) - 1, height: 30)
//            leftButton.setImage(image, for: UIControl.State.normal)
//        }
//        
////        leftButton.tag = LeftBarButtonType.quit.rawValue
//        leftButton.addAction(for: UIControl.Event.touchUpInside) { (button) in
//            action()
//        }
//        
//        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
//    }
//}
