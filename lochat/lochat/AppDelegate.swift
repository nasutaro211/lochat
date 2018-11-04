//
//  AppDelegate.swift
//  lochat
//
//  Created by 中田　優樹 on 2018/11/03.
//  Copyright © 2018年 nakatayuki. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        realmInit()
        
        if UserDefaults.standard.string(forKey: UDKey_userID) == nil {
            UserDefaults.standard.set(UUID.init().uuidString, forKey: UDKey_userID)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if UserDefaults.standard.bool(forKey: UDKey_isJoinning) {
            //参加している時
            let realm = try! Realm()
            let joinningEvent = realm.object(ofType: Event.self, forPrimaryKey: UserDefaults.standard.string(forKey: UDKey_joinedEventID))
            if joinningEvent!.isHolded() {
                //イベント中だった時イベント開催tabページへ
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabJoiningViewController")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()

            }else{
                //イベントが終了していた時
                UserDefaults.standard.set(false, forKey: UDKey_isJoinning)
                //TODO:サーバーにGETリクエストしてImagePath配列のJSONデータをEventに保存しておく
                //ログアウト後のページに戻る
                if let tabvc = self.window!.rootViewController as? UITabBarController  {
                    tabvc.selectedIndex = 1 // 0 が一番左のタブ
                    let destination = tabvc.viewControllers![1] as! EntranceViewController
                    destination.isJustLogout = true
                    destination.logoutedEvent = realm.object(ofType: Event.self, forPrimaryKey: UserDefaults.standard.string(forKey: UDKey_joinedEventID))
                }
            }
        }else{
            //参加していない時
            if let tabvc = self.window!.rootViewController as? UITabBarController  {
                tabvc.selectedIndex = 1 // 0 が一番左のタブ
            }
        }
        
        FirebaseApp.configure()


        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

