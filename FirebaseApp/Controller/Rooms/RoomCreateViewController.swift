//
//  RoomCreateViewController.swift
//  FirebaseApp
//
//  Created by George Heints on 10.05.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class RoomCreateViewController: UIViewController {

    var currentRoomID:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        themeSetup()
        topBarSetup()
        self.tabBarController?.tabBar.isHidden = true
        // Do any additional setup after loading the view.
        roomAddName.attributedPlaceholder = NSAttributedString(string: "Название комнаты", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        roomAddTitle.attributedPlaceholder = NSAttributedString(string: "Введите тему", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBOutlet weak var roomNumOfUsers: UITextField!
    @IBOutlet weak var roomAdminDisplay: UITextField!
    @IBOutlet weak var roomAddTitle: UITextField!
    @IBOutlet weak var roomAddName: UITextField!
    @IBOutlet weak var roomDisplayImage: UIImageView!
    @IBAction func roomAddImage(_ sender: Any) {
    }

    func themeSetup(){
        self.title = "Добавить комнату"

        self.view.backgroundColor = UIColor(red: 24.0/255.0, green: 34.0/255.0, blue: 45.0/255.0, alpha: 1.0)
    }

    func topBarSetup(){
        let testUIBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(ChangeUserDataVC.clickButton))
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem

    }
    @objc func clickButton(){
        handleAddRoom()
    }

    @objc func handleAddRoom() {
        guard let name = roomAddName.text else { return }
        guard let title = roomAddTitle.text else { return }
        guard let image = roomDisplayImage.image else { return }
        // 1. Upload the profile image to Firebase Storage
        self.uploadRoomImage(image: image) { url in

            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = name
                changeRequest?.photoURL = url
                if self.roomAddName.text != "" && self.roomAddTitle.text != ""{
                    changeRequest?.commitChanges { error in
                        if error == nil {
                            self.saveRoom(roomImageURL: url!) { success in
                                if success {
                                    print("Success!")
                                    self.successAction()


                                } else {
                                    self.resetForm()
                                }
                            }

                        } else {
                            print("Error: \(error!.localizedDescription)")
                            self.resetForm()
                        }
                    }
                }
                else{
                    self.resetForm()
                }
                //
            } else {
                self.resetForm()
            }

        }
    }

    //upload image
    func uploadRoomImage(image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("chatRooms/\(currentRoomID)")

        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }


        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                if let url = metaData?.downloadURL() {
                    completion(url)
                } else {
                    completion(nil)
                }
                // success!
            } else {
                // failed
                completion(nil)
            }
        }
    }

    //Save data from Room
    func saveRoom(roomImageURL:URL, completion: @escaping ((_ success:Bool)->())) {

        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let name = roomAddName.text else { return }
        guard let title = roomAddTitle.text else { return }
        let roomID: String = UUID().uuidString
        let limit = "0"
        currentRoomID = roomID
        print(currentRoomID)
        let priority = "1"
        let databaseRef = Database.database().reference().child("chatRooms/\(roomID)")
        let userObject = [
            "name": name,
            "amdinID": uid,
            "priority": priority,
            "roomID": currentRoomID,
            "title": title,
            "roomImageUrl": roomImageURL.absoluteString,
            "users" :["\(uid)"]

            ] as [String:Any]

        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
        }
    }

    //Reset
    func resetForm() {
        let alert = UIAlertController(title: "Проверьте заполнение полей", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Продолжить", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //Success
    func successAction() {
        let alert = UIAlertController(title: "Данные успешно изменены", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
