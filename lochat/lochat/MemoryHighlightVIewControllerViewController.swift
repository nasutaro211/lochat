//
//  MemoryHighlightVIewControllerViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/04.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit

class MemoryHighlightVIewControllerViewController: UIViewController {
    let imagePaths = ["abc", "def", "ghi", "jkl", "nmo", "pqr", "stu" ]
    var imageViews = Array<UIImageView>()
    
    var imageView0 = UIImageView()
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()
    var imageView3 = UIImageView()
    var imageView4 = UIImageView()
    var imageView5 = UIImageView()
    var imageView6 = UIImageView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setImages()
    }
    
    func setImages(){
        imageViews.append(imageView0)
        imageViews.append(imageView1)
        imageViews.append(imageView2)
        imageViews.append(imageView3)
        imageViews.append(imageView4)
        imageViews.append(imageView5)
        imageViews.append(imageView6)
        
        for i in 0..<7{
            view.addSubview(imageViews[i])
            imageViews[i].image = UIImage(named: imagePaths[i])
            imageViews[i].contentMode = .scaleAspectFit
            imageViews[i].snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
            view.sendSubviewToBack(imageViews[i])
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        for i in 0..<6{
            UIView.animateKeyframes(withDuration: 3.0, delay: 3.0*Double(i), options: .init(rawValue: 0), animations: {
                self.imageViews[i].alpha = 0
            }, completion: nil)
        }
    }
    
}





