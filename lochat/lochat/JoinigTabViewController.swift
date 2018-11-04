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
        button.addTarget(self, action: #selector(didPushCenterButton), for: .touchUpInside)
        tabBar.barTintColor = eventColor
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .white
        // Do any additional setup after loading the view.
    }
    
    @objc func didPushCenterButton(){
        switch tabBarController?.selectedIndex {
        case 0:
            tabBarController?.selectedIndex = 1
            break
        case 1:
            let cameraViewController = self.selectedViewController as! CameraViewController
            cameraViewController.tapedShutterButton()
            break
        case 2:
            tabBarController?.selectedIndex = 1
            break
        default:
            break
        }
    }
    
    func changeButtonSize(){
        switch tabBarController?.selectedIndex {
        case 0:
            button.setImage(UIImage(named: "joiningCenterTabButton")?.resize(width: mainFrame.width*0.3), for: .normal)
            break
        case 1:
            button.setImage(UIImage(named: "joiningCenterTabButton")?.resize(width: mainFrame.width*0.4), for: .normal)
            break
        case 2:
            button.setImage(UIImage(named: "joiningCenterTabButton")?.resize(width: mainFrame.width*0.3), for: .normal)
        default:
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
