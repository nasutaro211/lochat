//
//  CameraViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit
import CoreLocation

class CameraViewController: UIViewController, CLLocationManagerDelegate{
    
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
        let latitude1 = location?.coordinate.latitude
        let longitude1 = location?.coordinate.longitude
        let latitude = latitude1!
        let longitude = longitude1!
        Frame.returnMatchedFrames(lat: Float(latitude), long: Float(longitude))
        print("latitude: \(latitude1)\nlongitude:\(longitude1)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization")
    }

}

