//
//  CameraViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class CameraViewController: UIViewController, CLLocationManagerDelegate{
    
    var usableFrame: [Frame] = []
    
    var locationManager: CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        // Do any additional setup after loading the view.
    }
    
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self //delegateが位置情報に関する変更などを担っている
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse{
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let now = Date()
        updateFrames(latitude: Float(latitude!), longitude: Float(longitude!))
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
    }
    
    func updateFrames(latitude: Float, longitude: Float){
        var newUsableFrame: [Frame] = []
        Frame.returnMatchedFrames(lat: latitude, long: longitude).forEach { (frame) in
            newUsableFrame.append(frame)
        }
        usableFrame = newUsableFrame
        //TODO: フロントをアップデートする機能もつける
    }
}

