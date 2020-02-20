//
//  ViewController.swift
//  PaycoOnlinePaymentDemo
//
//  Created by artist on 2020/02/20.
//  Copyright © 2020 NHN Payco. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var payButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("온라인 결제", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(goOnLinePay), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .black
        
        self.view.addSubview(payButton)
        
        payButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        payButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    @objc func goOnLinePay() {
        self.present(PaycoOnlinePaymentWebViewController(), animated: true, completion: nil)
    }


}

