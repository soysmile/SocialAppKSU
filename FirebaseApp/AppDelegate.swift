//
//  AppDelegate.swift
//  FirebaseApp
//
//  Created by George Heints on 22.03.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

let primaryColor = UIColor(red: 210/255, green: 109/255, blue: 180/255, alpha: 1)
let secondaryColor = UIColor(red: 52/255, green: 148/255, blue: 230/255, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        UIApplication.shared.statusBarStyle = .lightContent
        let navigationBarAppearace = UINavigationBar.appearance()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationBarAppearace.barTintColor = UIColor(red: 34.0/255.0, green: 48.0/255.0, blue: 63.0/255.0, alpha: 1.0)
        
        UITabBar.appearance().barTintColor = UIColor(red: 34.0/255.0, green: 48.0/255.0, blue: 63.0/255.0, alpha: 1.0)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()

        changeRequest?.commitChanges { error in
            if error == nil {
                self.saveProfile(isOnline: "Не в сети") { success in
                    if success {
                        print("FALSE!")

                    } else {
                        //TODO
                    }
                }

            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
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
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()

        changeRequest?.commitChanges { error in
            if error == nil {
                self.saveProfile(isOnline: "В сети") { success in
                    if success {
                        print("TRUE!")

                    } else {
                        //TODO
                    }
                }

            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
       // let ref = Database.database().reference.child("isOnline").child(user)
       // ref.setValue(true) // YES
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func saveProfile(isOnline: String, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var onlineStatus = isOnline
        let databaseRef = Database.database().reference().child("users/\(uid)")
        let userObject = [
            "isOnline": onlineStatus
            ] as [String:Any]

        databaseRef.updateChildValues(userObject) { error, ref in
            completion(error == nil)
        }
    }

}

