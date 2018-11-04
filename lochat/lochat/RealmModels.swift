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
    
    convenience init(frameID: String, event: Event){
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
        
        self.frameID = frameID
        self.imagePath = json["image_path"] as! String
        self.longitude = (json["longitude"] as! NSNumber).floatValue
        self.latitude = (json["latitude"] as! NSNumber).floatValue
        self.radiusMeter = (json["distance"] as! NSNumber).floatValue
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
    
    
    
    convenience init(json: Dictionary<String, Any>){
        self.init()
        self.frameID = json["id"] as! String
        self.imagePath = json["image_path"] as! String
        self.longitude = (json["longitude"] as! NSNumber).floatValue
        self.latitude = (json["latitude"] as! NSNumber).floatValue
        self.radiusMeter = (json["distance"] as! NSNumber).floatValue
        self.startTime = Int(json["start_date"] as! String)!
        self.endTime = Int(json["end_date"] as! String)!
        
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
    @objc dynamic var colorCode = "000000"
    
    override static func primaryKey() -> String? {
        return "eventID"
    }
    
    
    
    func isHolded()->Bool{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = formatter.string(from: Date())
        
        if startDate <= dateString && endDate >= dateString{
            return true
        }
        return false
    }
    
    //    init(eventID: String){
    //        self.eventID = eventID
    //    }
    
    convenience init(eventURL: String){
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
        
        
        self.init()
        self.eventID = json["id"] as! String
        self.longitude = (json["longitude"] as! NSNumber).floatValue
        self.latitude = (json["latitude"] as! NSNumber).floatValue
        self.radiusMeter = (json["distance"] as! NSNumber).floatValue
        self.startDate = json["start_date"] as! String
        self.endDate = json["end_date"] as! String
        self.colorCode = json["color_code"] as! String
        //バリデーションをかけて
        if self.isHolded(){
            UserDefaults.standard.set(true, forKey: UDKey_isJoinning)
            UserDefaults.standard.set(self.eventID, forKey: UDKey_joinedEventID)
            let defaultFrameID = json["default_frame_id"] as! String
            self.defaultEventFrame = Frame(frameID: defaultFrameID, event: self)
            let localeFrameIDs = json["frame_ids"] as! Array<String>
            createFrames(frameIds: localeFrameIDs, eventID: self.eventID)
        }
    }
    
    func createFrames(frameIds: [String], eventID: String){
        frameIds.forEach { (frameID) in
            let urlStr =  "http://153.125.225.54:5000/frame_detail?frame_id=" + frameID
            var json:[String: Any] = [:]
            //QRコードの中身を使って何かをする機能
            let request = NSMutableURLRequest(url: URL(string: urlStr)!)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let data = data, let response = response {
                    print(response)
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                        self.addFrame(json: json, eventID: eventID)
                    } catch {
                        print("Serialize Error")
                    }
                } else {
                    print(error ?? "Error")
                }
            }
            task.resume()
        }

    }
    
    func addFrame(json: Dictionary<String, Any>, eventID: String){
        let realm = try! Realm()
        let event = realm.object(ofType: Event.self, forPrimaryKey: eventID)
        let frame = Frame.init(json: json)
        frame.event = event!
        try! realm.write {
            realm.add(frame, update: true)
        }
    }
    
}
