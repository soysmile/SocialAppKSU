//
//  ChangeUserDataVC.swift
//  FirebaseApp
//
//  Created by George Heints on 25.04.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import Firebase

class ChangeUserDataVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker:UIImagePickerController!

    //Change image button action
    @IBAction func changeProfileImage(_ sender: Any) {
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }

    //Quit button action
    @IBAction func quitButton(_ sender: Any) {
        do{
            try! Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        }catch let error{
            print(error.localizedDescription)
        }
        
    }

    //Password change button action
    @IBAction func passwordChangeBtn(_ sender: Any) {

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.resetPassword(email: user.email)
            }

        }, withCancel: nil)

    }

    @IBOutlet weak var userProfileDisplayBirth: UITextField!
    @IBOutlet weak var changeProfileDataPicker: UIDatePicker!
    @IBOutlet weak var userProfileTelephone: UITextField!
    @IBOutlet weak var userProfileJob: UITextField!
    @IBOutlet weak var userProfilePassword: UITextField!
    @IBOutlet weak var userProfileRole: UITextField!
    @IBOutlet weak var userProfileCourse: UITextField!
    @IBOutlet weak var userProfileUsername: UITextField!
    @IBOutlet weak var userProfileEmail: UITextField!
    @IBOutlet weak var userProfileName: UITextField!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
        Auth.auth().currentUser?.reload()
    }

    //ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        userProfileDisplayBirth.text = dateFormatter.string(from: changeProfileDataPicker.date)
        themeSetup()
        UserSetup()
        topBarSetup()
        hideKeyboard()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }

    //imagepicker dismiss
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    //Pick Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userProfileImage.contentMode = .scaleAspectFit
            self.userProfileImage.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func topBarSetup(){
        let testUIBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(ChangeUserDataVC.clickButton))
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem
    
    }
    @objc func clickButton(){
        handleSignUp()
    }
    func themeSetup(){
        self.title = "Изменить профиль"
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = UIColor(red: 24.0/255.0, green: 34.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        changeProfileDataPicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    func UserSetup() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.fillData(user)
            }
            
        }, withCancel: nil)
    }
    
    func fillData(_ user: User){
        do{

            userProfileImage.translatesAutoresizingMaskIntoConstraints = false
            userProfileImage.layer.cornerRadius = 64
            userProfileImage.layer.masksToBounds = true
            userProfileImage.contentMode = .scaleAspectFill
            userProfileName.text = user.name
            userProfileEmail.text = user.email
            userProfileCourse.text = user.course
            userProfileUsername.text = user.email
            userProfilePassword.text = user.password
            userProfileTelephone.text = user.telNumber
            userProfileDisplayBirth.text = user.birthDate
            userProfileJob.text = user.job
            if let profileImageUrl = user.profileImageUrl {
                userProfileImage.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
            if user.role == "user"{
                userProfileRole.text = "Пользователь"
            }
            else if user.role == "guest"{
                userProfileRole.text = "Гость"
            }
            else if user.role == "teacher"{
                userProfileRole.text = "Преподаватель"
            }
            else if user.role == "admin"{
                userProfileRole.text = "Администратор"
            }
            else{
                userProfileRole.text = "Ошибка! Свяжитесь с администрацией"
            }

        }catch let error{
            print(error.localizedDescription)
        }
        
    }
    
    //Update User
    @objc func handleSignUp() {
        guard let username = userProfileName.text else { return }
        guard let email = userProfileEmail.text else { return }
        guard let image = userProfileImage.image else { return }

        // 1. Upload the profile image to Firebase Storage
        
        self.uploadProfileImage(image) { url in
            
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.photoURL = url
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        print("data stored")
                        
                        //self.dismiss(animated: false, completion: nil)
                        //
                        self.saveProfile(username: username, profileImageURL: url!) { success in
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
            } else {
                self.resetForm()
            }
            
        }
    }
    
    func resetForm() {
        let alert = UIAlertController(title: "Ошибка изменения данных", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Продолжить", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func successAction() {
        let alert = UIAlertController(title: "Данные успешно изменены", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        UserSetup()
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("users/\(uid)")
        
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

    //Reset password func
    func resetPassword(email: String?){
        Auth.auth().sendPasswordReset(withEmail: email!, completion: { (error) in
            //Make sure you execute the following code on the main queue
            DispatchQueue.main.async {
                //Use "if let" to access the error, if it is non-nil
                if let error = error {
                    let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error.localizedDescription, preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                } else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            }
        })
    }


    //Save data from ChangeUserData
    func saveProfile(username:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"

        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let username = userProfileName.text else { return }
        guard let email = userProfileEmail.text else { return }
        guard let course = userProfileCourse.text else { return }
        guard let password = userProfilePassword.text else { return }
        guard let job = userProfileJob.text else { return }
        guard let telNumber = userProfileTelephone.text else { return }
        let dataPicker = dateFormatter.string(from: changeProfileDataPicker.date)
        //let creationDate = Auth.auth().currentUser?.metadata.creationDate
        let databaseRef = Database.database().reference().child("users/\(uid)")
        
        let userObject = [
            "name": username,
            "email": email,
            "profileImageUrl": profileImageURL.absoluteString,
            "course": course,
            "password" : password,
            "job" : job,
            "telNumber" : telNumber,
            "birthDate" : dataPicker
            ] as [String:Any]
        
        databaseRef.updateChildValues(userObject) { error, ref in
            completion(error == nil)
        }
    }
        
    
}
