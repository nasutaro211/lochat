//
//  FrameCollectionViewCell.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/04.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit

class FrameCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    func setUp(frame: Frame){
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        
//        let urlStr = "https://s3-ap-northeast-1.amazonaws.com/kakomon-share/" + frame.imagePath
//        //QRコードの中身を使って何かをする機能
//        let data = try! Data(contentsOf: URL(fileURLWithPath: urlStr))
//        imageView.image = UIImage(data: data)
    }

}
