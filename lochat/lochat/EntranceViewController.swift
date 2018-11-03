//
//  EntranceViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit

class EntranceViewController: BaseViewController {
    var isJustLogout = false
    var logoutedEvent:Event?
    @IBOutlet var toQRButton: UIButton!
    @IBOutlet var backImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        setBackImage()
    }
    
    @objc func didPushToQRButton(){
        let destination = QRViewController()
        self.present(destination, animated: true, completion: nil)
    }
}

extension EntranceViewController{
    func setButton(){
        toQRButton.addTarget(self, action: #selector(self.didPushToQRButton), for: .touchUpInside)
    }
    func setBackImage(){
        //TOOD: 画像が来たらここでviewの背景とイメージを指定する
        self.view.backgroundColor = .white
    }
}
