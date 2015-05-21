//
//  User.swift
//  DateHaven
//
//  Created by Jim Aven on 5/15/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import Foundation

struct User {
    let id: String
    let name: String
    private let pfUser: PFUser
    
    func getPhoto(callback:(UIImage) -> ()) {
        let imageFile = pfUser.objectForKey("picture") as! PFFile
        imageFile.getDataInBackgroundWithBlock({
            data, error in
            
            if error != nil {
                println("error in image:\(error?.localizedDescription)")
            }
            
            if let data = data {
                callback(UIImage(data: data)!)
            }
        })
    }
}

func pfUserToUser(user: PFUser)->User {
    return User(id: user.objectId!, name: user.objectForKey("firstName") as! String, pfUser: user)
}

func currentUser() -> User? {
    if let user = PFUser.currentUser() {
        return pfUserToUser(user)
    }
    return nil
}

func fetchUnviewedUsers(callback:([User]) -> ()) {
    
    PFQuery(className: "Action")
    .whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
        .findObjectsInBackgroundWithBlock( {
        objects, error in
        if error != nil {
        println(error!.localizedDescription)
        }
        else {
            let seenIDs = map(objects!, {$0.objectForKey("toUser")!})
            PFUser.query()!
            .whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
            .whereKey("objectId", notContainedIn: seenIDs)
            .findObjectsInBackgroundWithBlock({
                objects, error in
                if let pfUsers = objects as? [PFUser] {
                    let users = map(pfUsers, {pfUserToUser($0)})
                    callback(users)
                }
            })
        }
    })
    
    PFUser.query()!
        .whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        .findObjectsInBackgroundWithBlock({
            objects, error in
            if let pfUsers = objects as? [PFUser] {
                let users = map(pfUsers, {pfUserToUser($0)})
                callback(users)
            }
            }
    )
}

func saveSkip(user: User) {
    
    let skip = PFObject(className: "Action")
    skip["byUser"] = PFUser.currentUser()!.objectId!
    skip["type"] = "skipped"
    skip.saveInBackground()
}

func saveLike(user:User) {
    
    let liked = PFObject(className: "Action")
    liked["byUser"] = PFUser.currentUser()!.objectId!
    liked["toUser"] = user.id
    liked["type"] = "liked"
    liked.saveInBackgroundWithBlock({
        success, error in
        if error != nil {
            println("save like error: \(error!.localizedDescription)")
        }
        else {
            PFQuery(className: "Action")
            .whereKey("byUser", equalTo: user.id)
            .whereKey("toUser", equalTo: PFUser.currentUser()!.objectId!)
            .whereKey("type", equalTo: "liked")
            .getFirstObjectInBackgroundWithBlock({
                
                object, error in
                
                var matched = false
                if object != nil {
                    matched = true
                    object!["type"] = "matched"
                    object!.saveInBackgroundWithBlock(nil)
                }
                
                let match = PFObject(className: "Action")
                match.setObject(PFUser.currentUser()!.objectId!, forKey:"byUser")
                match.setObject(matched ? "matched" : "liked", forKey:"type")
                match.saveInBackgroundWithBlock(nil)
            })
        }
    })
}