//
//  globals.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

let mainFrame = UIScreen.main.bounds

let UDKey_userID = "userID"
let UDKey_userName = "userName"
let UDKey_isJoinning = "isJoinning"
let UDKey_joinedEventID = "joinedEventID"
let mainColor = UIColor.red

let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]



func realmInit(){
    //Realm初期化
    var dirNames = try! FileManager.default.contentsOfDirectory(atPath: docDir)
    print(dirNames)
    for dirName in dirNames{
        do {
            try FileManager.default.removeItem(atPath: docDir + "/" + dirName)
        }catch{
            print(error)
        }
    }
    dirNames = try! FileManager.default.contentsOfDirectory(atPath: docDir)
    print(dirNames)
    if let bundleId = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: bundleId)
    }
//    //追加
//    let realm = try! Realm()
//    var eventJsonStr = "{\"default_frame_id\":\"MRXF5YK32pcCtD0tIlSW\",\"distance\":20,\"end_date\":\"20181104235959\",\"frame_ids\":[\"MRXF5YK32pcCtD0tIlSW\"],\"id\":\"v9CaqOsb8UMgLMen6GkU\",\"latitude\":34.687333,\"longitude\":135.525956,\"start_date\":\"20181102183000\"}"
//    let eventData = eventJsonStr.data(using: .utf8)!
//    let eventJsonArray = try! JSONSerialization.jsonObject(with: eventData, options : .allowFragments) as! Dictionary<String,Any>
//    let event = Event(json: eventJsonArray)
//    try! realm.write {
//        realm.add(event)
//    }
//    UserDefaults.standard.set(event.eventID, forKey: UDKey_joinedEventID)
//
//    var frameJsonStr = "{\"distance\":10000000.0,\"event_id\":\"v9CaqOsb8UMgLMen6GkU\",\"id\":\"MRXF5YK32pcCtD0tIlSW\",\"image_path\":\"lochat/frames/v9CaqOsb8UMgLMen6GkU/3e5508d2-df90-11e8-ae95-2e27a388055e.jpg\",\"latitude\":34.687333,\"longitude\":135.525956}"
//    var frameData = frameJsonStr.data(using: .utf8)!
//    var frameArray = try! JSONSerialization.jsonObject(with: frameData, options: .allowFragments) as! Dictionary<String, Any>
//    var frame = Frame(json: frameArray)
//    frame.event = event
//    try! realm.write {
//        realm.add(frame)
//    }
    
}
