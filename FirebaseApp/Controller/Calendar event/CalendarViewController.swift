//
//  CalendarViewController.swift
//  FirebaseApp
//
//  Created by George Heints on 11.04.2018.
//  Copyright © 2018 Robert Canton. All rights reserved.
//

import UIKit
import EventKit
class CalendarViewController: UIViewController {

    let str : String = "lorem ispum"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    let appleEventStore = EKEventStore()
    var calendars: [EKCalendar]?
    func generateEvent() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status)
        {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // User has access
            print("User has access to calendar")
            self.addAppleEvents()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            noPermission()
        }
    }
    func noPermission()
    {
        print("User has to change settings...goto settings to view access")
    }
    func requestAccessToCalendar() {
        appleEventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                DispatchQueue.main.async {
                    print("User has access to calendar")
                    self.addAppleEvents()
                }
            } else {
                DispatchQueue.main.async{
                    self.noPermission()
                }
            }
        })
    }
    func addAppleEvents()
    {
        let event:EKEvent = EKEvent(eventStore: appleEventStore)
        event.title = "Test Event for user"
        event.startDate = NSDate() as Date
        event.endDate = NSDate() as Date
        event.notes = "This is a note for user"
        event.calendar = appleEventStore.defaultCalendarForNewEvents
        
        do {
            try appleEventStore.save(event, span: .thisEvent)
            print("events added with dates:")
        } catch let e as NSError {
            print(e.description)
            return
        }
        print("Saved Event")
    }
}
