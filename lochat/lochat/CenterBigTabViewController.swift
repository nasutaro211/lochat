//
//  CenterBigTabViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/04.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit

class CenterBigTabViewController: UITabBarController {
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.setImage(UIImage(named: "centerTabButton")?.resize(width: mainFrame.width*0.3), for: .normal)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.to1View), for: .touchUpInside)
        
        tabBar.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(45)
        }
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .white
        tabBar.isTranslucent = false
        self.view.setNeedsDisplay()
    }
    
    @objc func to1View(){
        self.selectedIndex = 1
    }
    
    //TODO: 選択されているのが何番かを表示するきのうを実装(tabの上に横線的なもの)
    func explainSelected(){
//        let hyoujiView = UIView()
//        hyoujiView.frame.size = mainFrame.width*0.7
//        switch self.selectedIndex {
//        case 0:
//            <#code#>
//        case 1:
//            break
//        case 2:
//        default:
//            <#code#>
//        }
    }

}
