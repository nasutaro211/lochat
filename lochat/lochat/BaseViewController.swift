//
//  BaseViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //イメージビューをタイトルに
        let imageView = UIImageView(image: UIImage(named: "navImage")?.resize(width: mainFrame.width*0.5))
        imageView.frame.size = CGSize(width: mainFrame.width*0.5 , height: 30)
        navigationItem.titleView = imageView
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
        //右側ノボタン
        let configItem = UIBarButtonItem(image: UIImage(named: "config"), style: .plain, target: self, action: #selector(self.toConfig))
        navigationItem.setRightBarButton(configItem, animated: true)
        navigationController?.navigationBar.isTranslucent = false
        extendedLayoutIncludesOpaqueBars = true
        //真ん中のボタンを大きくする
        
    }
    
    @objc func toConfig(){
        //TODO: コンフィグの設定用
        let desitnation = UIViewController()
        self.present(desitnation, animated: true, completion: nil)
    }
    
}
