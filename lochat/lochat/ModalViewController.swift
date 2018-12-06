//
//  ModalViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/04.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    let rView = UIView()
    let imageView = UIImageView()
    let button = UIButton()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(hex: "000000", alpha: 0)
        view.addSubview(rView)
        rView.addSubview(imageView)
        rView.addSubview(button)
        
        imageView.image = UIImage(named: "finish")
        imageView.contentMode = .scaleAspectFit
        
        rView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalToSuperview().multipliedBy(065)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        button.snp.makeConstraints { (make) in
            make.width.equalToSuperview().priority(999)
            make.height.equalToSuperview().priority(999)
            make.centerY.equalToSuperview().priority(999)
            make.centerX.equalToSuperview().priority(999)
        }
        
        button.addTarget(self, action: #selector(self.didPushButton), for: .touchUpInside)

    }
    
    @objc func didPushButton(){
        let destination = MemoryHighlightVIewControllerViewController()
        destination.modalTransitionStyle = .crossDissolve
        present(destination, animated: true, completion: nil)
    }
}
