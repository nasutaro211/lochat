//
//  JoinigTabViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/04.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit
import RealmSwift

class JoinigTabViewController: CenterBigTabViewController {
    var eventColor = UIColor.black
    
    override var selectedIndex: Int{
        // タブ切り替え時に処理を行うため
        didSet {
            self.didChangeTab()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        let colorcode = realm.object(ofType: Event.self, forPrimaryKey: UserDefaults.standard.string(forKey: UDKey_joinedEventID))?.colorCode
        self.eventColor = UIColor(hex: colorcode!)
        button.removeTarget(self, action: #selector(self.to1View), for: .touchUpInside)
        button.addTarget(self, action: #selector(didPushCenterButton), for: .touchUpInside)
        tabBar.barTintColor = eventColor
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .white
        // Do any additional setup after loading the view.
    }
    
    @objc func didPushCenterButton(){
        switch self.selectedIndex {
        case 0:
            self.selectedIndex = 1
            break
        case 1:
            let navigationViewController = self.selectedViewController as! UINavigationController
            let cameraViewController = navigationViewController.viewControllers[0] as! CameraViewController
            cameraViewController.tapedShutterButton()
            break
        case 2:
            self.selectedIndex = 1
            break
        default:
            let navigationViewController = self.selectedViewController as! UINavigationController
            let cameraViewController = navigationViewController.viewControllers[0] as! CameraViewController
            cameraViewController.tapedShutterButton()
            break
        }
    }
    
    func changeButtonSize(){
        switch self.selectedIndex {
        case 0:
            button.setImage(UIImage(named: "joiningCenterTabButton")?.resize(width: mainFrame.width*0.3), for: .normal)
            button.layoutIfNeeded()
            break
        case 1:
            button.setImage(UIImage(named: "joiningCenterTabButton")?.resize(width: mainFrame.width*0.4), for: .normal)
            button.layoutIfNeeded()
            break
        case 2:
            button.setImage(UIImage(named: "joiningCenterTabButton")?.resize(width: mainFrame.width*0.3), for: .normal)
            button.layoutIfNeeded()
        default:
            button.setImage(UIImage(named: "joiningCenterTabButton")?.resize(width: mainFrame.width*0.4), for: .normal)
            button.layoutIfNeeded()
            break
        }
        button.sizeToFit()
    }
    
    func didChangeTab(){
        changeButtonSize()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
