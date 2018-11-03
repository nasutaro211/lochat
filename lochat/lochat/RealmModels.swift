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
    @objc dynamic var imagePath = ""
    @objc dynamic var longitude:Float = 0.0
    @objc dynamic var latitude:Float = 0.0
    @objc dynamic var radiusMeter:Float = 0.0
    @objc dynamic var event: Event!
    @objc dynamic var startTime = 20181102190000
    @objc dynamic var endTime = 20181104235959
    @objc dynamic var distance:Float = 0.0;
    @objc dynamic var stilGot = false
    
    override static func primaryKey() -> String? {
        return "frameID"
    }
    
    convenience init(frameID: String, event: Event, afterAllSuccess: (() -> Void)?){
        self.init()
        
        let urlStr = "https://lochat-python.herokuapp.com/frame_detail?frame_id=" + frameID
        var json:[String: Any] = [:]
        //QRコードの中身を使って何かをする機能
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let request = NSMutableURLRequest(url: URL(string: urlStr)!)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let data = data, let response = response {
                    print(response)
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                    } catch {
                        print("Serialize Error")
                    }
                } else {
                    print(error ?? "Error")
                }
                semaphore.signal()
            }
            task.resume()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        DispatchQueue.main.async {
            self.frameID = frameID
            self.imagePath = json["image_path"] as! String
            self.longitude = (json["longitude"] as! NSNumber).floatValue
            self.latitude = (json["latitude"] as! NSNumber).floatValue
            self.radiusMeter = (json["distance"] as! NSNumber).floatValue
            guard afterAllSuccess != nil else{
                return
            }
            afterAllSuccess!()
        }
    }
    
    
    static func returnMatchedFrames(lat:Float,long:Float)->Results<Frame>{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = Int(formatter.string(from: Date()))
        let realm = try! Realm()
        let frames = realm.objects(Frame.self)
        frames.forEach { (frame) in
            try! realm.write {
                frame.distance = pow(pow(frame.latitude*110 - lat*110,2) - pow(frame.longitude*25-long*25,2),0.5)*1000
            }
        }
        return frames.filter("(distance < radiusMeter) AND (%@ < endTime) AND (%@ > startTime)",date,date)
//        let realm = try! Realm()
//        let frames = realm.objects(Frame.self)
//        return frames
        
    }
    
    static func createEventFrames(frameIds: [String], event: Event){
        //全部突っ込んで非同期に処理してお尻で合わせてcallback
//        let realm = try! Realm()
//        frameIds.forEach { (id) in
//            if event.defaultEventFrame?.frameID != id{
//                let newFrame = Frame(frameID: id, event: event, afterAllSuccess: nil)
//                try! realm.write{
//                    realm.add(newFrame)
//                }
//            }
//        }
    }
    
    convenience init(json: Dictionary<String, Any>){
        self.init()
        self.frameID = json["id"] as! String
        self.imagePath = json["image_path"] as! String
        self.longitude = (json["longitude"] as! NSNumber).floatValue
        self.latitude = (json["latitude"] as! NSNumber).floatValue
        self.radiusMeter = (json["distance"] as! NSNumber).floatValue
        
    }
}


class Event: Object{
    @objc dynamic var eventID = ""
    @objc dynamic var longitude:Float = 0.0
    @objc dynamic var latitude:Float = 0.0
    @objc dynamic var radiusMeter:Float = 0.0
    @objc dynamic var defaultEventFrame: Frame?
    let localeFrames = LinkingObjects(fromType: Frame.self, property: "event")
    @objc dynamic var startDate = "20181102183000"
    @objc dynamic var endDate = "20181104235959"
    @objc dynamic var highlightImagesJSONStr = ""
    
    func isHolded()->Bool{

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = formatter.string(from: Date())
 
        if startDate <= dateString && endDate >= dateString{
            return true
        }
        return false
    }
    
    convenience init(eventURL: String, afterAllSuccess: (() -> Void)?, afterFailed: @escaping ()->()){
        self.init()
        let urlStr = eventURL
        var json:[String: Any] = [:]
        //QRコードの中身を使って何かをする機能
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let request = NSMutableURLRequest(url: URL(string: urlStr)!)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let data = data, let response = response {
                    print(response)
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                    } catch {
                        print("Serialize Error")
                    }
                } else {
                    print(error ?? "Error")
                }
                semaphore.signal()
            }
            task.resume()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        DispatchQueue.main.async {
            let realm = try! Realm()
            try! realm.write {
                self.eventID = json["id"] as! String
                self.longitude = (json["longitude"] as! NSNumber).floatValue
                self.latitude = (json["latitude"] as! NSNumber).floatValue
                self.radiusMeter = (json["distance"] as! NSNumber).floatValue
                self.startDate = json["start_date"] as! String
                self.endDate = json["end_date"] as! String
                //バリデーションをかけて
                if self.isHolded(){
                    UserDefaults.standard.set(true, forKey: UDKey_isJoinning)
                    UserDefaults.standard.set(self.eventID, forKey: UDKey_joinedEventID)
                    realm.add(self)
                }else{
                    afterFailed()
                }
            }
            if self.isHolded(){
                let defaultFrameID = json["default_frame_id"] as! String
                self.defaultEventFrame = Frame(frameID: defaultFrameID, event: self, afterAllSuccess: afterAllSuccess)
                let localeFrameIDs = json["frame_ids"] as! Array<String>
                Frame.createEventFrames(frameIds: localeFrameIDs, event: self)
            }
        }
        

    }
    convenience init(json: Dictionary<String, Any>){
        self.init()
        self.eventID = json["id"] as! String
        self.longitude = (json["longitude"] as! NSNumber).floatValue
        self.latitude = (json["latitude"] as! NSNumber).floatValue
        self.radiusMeter = (json["distance"] as! NSNumber).floatValue
        self.startDate = json["start_date"] as! String
        self.endDate = json["end_date"] as! String
    }

}
