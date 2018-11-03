//
//  RealmModels.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import Foundation
import Realm

class Frame:Object{
    @objc dynamic var frameID = ""
    @objc dynamic var longitude:Float = 0.0
    @objc dynamic var latitude:Float = 0.0
    @objc dynamic var radiusMeter:Float = 0.0
    
    override static func primaryKey() -> String? {
        return "frameID"
    }
    
    //    TODO: ここ
//    static func returnMatchedFrames()->Array<Frame>{
//
//    }
}
