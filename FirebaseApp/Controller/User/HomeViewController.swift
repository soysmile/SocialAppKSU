//
//  HomeViewController.swift
//  FirebaseApp
//
//  Created by George Heints on 22.03.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import RxSwift

class HomeViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var users = [User]()
    var currentUserArray = [User]()
    var RoomArray = [Rooms]()
    var currentRoomArray = [Rooms]()
    var filteredArray = [User]()
    let contactsCellId = "cellId"
    let roomsCellId = "roomCellId"

    //numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if  segmentedControl.selectedSegmentIndex == 0
        {

            print("index 1: \(currentUserArray.count)")
            return currentUserArray.count
        }
        else{
            print("index 2: \(currentRoomArray.count)")
            return currentRoomArray.count
        }
    }
    
    //cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if  segmentedControl.selectedSegmentIndex == 0
        {

            // setup here
            let cell = tableView.dequeueReusableCell(withIdentifier: contactsCellId, for: indexPath) as! UserCell

            let user = currentUserArray[indexPath.row]

            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.isOnline

            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = .clear

            if let profileImageUrl = user.profileImageUrl {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }

            return cell
        }
        else{

            // setup here
            let cell = tableView.dequeueReusableCell(withIdentifier: roomsCellId, for: indexPath) as! UserCell

            let user = currentRoomArray[indexPath.row]

            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.title

            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = .clear

            if let profileImageUrl = user.roomImageUrl {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
            return cell
        }
    }
    
    //heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
    
    var messageController: MessagesController?
    //didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        do{
            let selectedUser = self.currentUserArray[indexPath.row]
            print(selectedUser.id)
            self.showChatControllerForUsers(selectedUser)

        }catch let error{
            print(error.localizedDescription)
        }

    }

    //Show Chat Controller for User
    func showChatControllerForUsers(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    //segmented control action
    @IBAction func indexChanged(_ sender: Any) {

        switch segmentedControl.selectedSegmentIndex{
        case 0:
            getRole()
            usersDisplayTableView.reloadData()
        case 1:
            getRole()
            usersDisplayTableView.reloadData()
        default:
            print("Something goes wrong!")
        }
    }
    //outlet connected
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var usersDisplayTableView: UITableView!
    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet weak var roomsSearchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.alpha = 0.1
        getRole()
        setUpSearchBar()
        setUpTableView()
        alterLayout()

        //top title
        self.title = "Контакты"
    }


    //setData for contacts
    func setData(_ user: User){

        //if USER
        if user.role == "user"{
            Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.id = snapshot.key
                    self.users.append(user)
                    self.currentUserArray =  self.users.filter({$0.role == "teacher" || $0.role == "user" || $0.role == "admin"})
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.usersDisplayTableView.reloadData()
                    })

                    user.name = dictionary["name"] as? String
                }

            }, withCancel: nil)


            self.usersDisplayTableView.reloadData()
        }
            //if GUEST
        else if user.role == "guest"{
            Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.id = snapshot.key
                    self.users.append(user)
                    self.currentUserArray =  self.users.filter({$0.role == "admin"})
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.usersDisplayTableView.reloadData()
                    })

                    user.name = dictionary["name"] as? String
                }

            }, withCancel: nil)


            self.usersDisplayTableView.reloadData()
        }
            //if ADMIN
        else if user.role == "admin"{
            Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.id = snapshot.key
                    self.users.append(user)
                    self.currentUserArray = self.users.filter({$0.role == "admin" || $0.role == "user" || $0.role == "guest" || $0.role == "teacher"})
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.usersDisplayTableView.reloadData()
                    })

                    user.name = dictionary["name"] as? String
                }

            }, withCancel: nil)


            self.usersDisplayTableView.reloadData()

        }

    }

    //setUp for rooms
    func setRoomsData(_ user: User){

        //if USER
        if user.role == "user"{
            Database.database().reference().child("chatRooms").observe(.childAdded, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let room = Rooms(dictionary: dictionary)
                    print("Room\(room)")
                    room.roomID = snapshot.key
                    self.RoomArray.append(room)
                    self.currentRoomArray =  self.RoomArray
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.usersDisplayTableView.reloadData()
                    })

                    room.name = dictionary["name"] as? String
                }

            }, withCancel: nil)

            self.usersDisplayTableView.reloadData()
        }
            //if GUEST
        else if user.role == "guest"{
            Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.id = snapshot.key
                    self.users.append(user)
                    self.currentUserArray =  self.users.filter({$0.role == "admin"})
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.usersDisplayTableView.reloadData()
                    })

                    user.name = dictionary["name"] as? String
                }

            }, withCancel: nil)


            self.usersDisplayTableView.reloadData()
        }
            //if ADMIN
        else if user.role == "admin"{
            Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(dictionary: dictionary)
                    user.id = snapshot.key
                    self.users.append(user)
                    self.currentUserArray = self.users.filter({$0.role == "admin" || $0.role == "user" || $0.role == "guest" || $0.role == "teacher"})
                    //this will crash because of background thread, so lets use dispatch_async to fix
                    DispatchQueue.main.async(execute: {
                        self.usersDisplayTableView.reloadData()
                    })

                    user.name = dictionary["name"] as? String
                }

            }, withCancel: nil)


            self.usersDisplayTableView.reloadData()

        }

    }
    //func setRole
    func getRole(){
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        self.users.removeAll()
        self.RoomArray.removeAll()
        self.currentRoomArray.removeAll()
        self.currentUserArray.removeAll()
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                print(user.role)
                if self.segmentedControl.selectedSegmentIndex == 0{
                    self.setData(user)
                }
                else{
                    self.setRoomsData(user)
                }

            }

        }, withCancel: nil)

    }


    //Search bar logics
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty  else {
            getRole()
            usersDisplayTableView.reloadData()
            return
            
        }

        currentUserArray = currentUserArray.filter({ user -> Bool in
            user.name!.lowercased().contains(searchText.lowercased())
        })
        usersDisplayTableView.reloadData()
        
    }

    //SearchBar placeholder
    func alterLayout() {
        userSearchBar.placeholder = "Search groups by Name"
    }

    //SearchBar tecnical setup
    private func setUpSearchBar() {
        //userSearchBar.showsScopeBar = true
        userSearchBar.delegate = self
    }

    //TableView setup
    private func setUpTableView() {
        self.tabBarController?.tabBar.isHidden = false
        definesPresentationContext = true
        usersDisplayTableView.delegate = self
        usersDisplayTableView.dataSource = self
        usersDisplayTableView.addSubview(self.refreshControl)
        usersDisplayTableView.backgroundColor = .clear
        usersDisplayTableView.separatorColor = UIColor.black
        self.view.backgroundColor = UIColor(red: 24.0/255.0, green: 34.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        usersDisplayTableView.register(UserCell.self, forCellReuseIdentifier: contactsCellId)
        usersDisplayTableView.register(UserCell.self, forCellReuseIdentifier: roomsCellId)
    }

    //Pull to update refresh control
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(HomeViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.white

        return refreshControl
    }()

    //Handle refresh control
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {

        getRole()
        self.usersDisplayTableView.reloadData()
        refreshControl.endRefreshing()
    }
}


