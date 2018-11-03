//
//  RealmModels.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import Foundation
import RealmSwift

class Frame:Object{
    @objc dynamic var frameID = ""
    @objc dynamic var longitude:Float = 0.0
    @objc dynamic var latitude:Float = 0.0
    @objc dynamic var radiusMeter:Float = 0.0
    @objc dynamic var startTime = "yyyyMMddHHmmss"
    @objc dynamic var endTime = "yyyyMMddHHmmss"
    @objc dynamic var distance:Float = 0.0;
    
    override static func primaryKey() -> String? {
        return "frameID"
    }
    
    //   TODO: ここ
    static func returnMatchedFrames(lat:Float,long:Float,currentDate:Date)->Results<Frame>{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.string(from: currentDate)
        let realm = try! Realm()
        let frames = realm.objects(Frame.self)
        frames.forEach { (frame) in
            try! realm.write {
                frame.distance = pow(pow(frame.latitude - lat,2) - pow(frame.longitude-long,2),0.5)
            }
        }
        return frames.filter("(distance <= radiusMeter) AND (%@ <= endTime) AND (%@>=startTime)",date,date)
        
    }
}
