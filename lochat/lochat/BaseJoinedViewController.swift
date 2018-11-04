//
//  BaseJoinedViewController.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/04.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit
import RealmSwift

class BaseJoinedViewController: UIViewController {
    var eventColor = UIColor()

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        let colorcode = realm.object(ofType: Event.self, forPrimaryKey: UserDefaults.standard.string(forKey: UDKey_joinedEventID))?.colorCode
        self.eventColor = UIColor(hex: colorcode!)
        navigationController?.navigationBar.barTintColor = eventColor
        navigationItem.titleView = UIImageView(image: UIImage(named: "navImage")?.resize(width: mainFrame.width*0.5))
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
