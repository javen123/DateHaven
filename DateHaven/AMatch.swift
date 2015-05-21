//
//  AMatch.swift
//  DateHaven
//
//  Created by Jim Aven on 5/20/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import Foundation

struct AMatch {
    let id: String
    let user: User
}

func fetchMatches (callback:([AMatch]) -> ()) {
    
    
    
    let query = PFQuery(className: "Action")
    query.whereKey("byUser", equalTo: PFUser.currentUser()!.objectId!)
    query.whereKey("type", equalTo: "matched")
    query.findObjectsInBackgroundWithBlock({
      objects, error in
        if error != nil {
            println(error!.localizedDescription)
        }
        else {
            if let matches = objects as? [PFObject] {
                
                var tupArray = [(String,String)]()
                var userIDs = [String]()
                var tup:(String,String)!
                
                for x in matches {
                    
                    let matchUserId = x.objectId! as String
                    let matchToUser = x.objectForKey("toUser") as! String
                    tup = (matchUserId,matchToUser)
                    tupArray.append(tup)
                }
                
                for x in tupArray {
                    userIDs.append(x.1)
                }
                
                PFUser.query()!
                .whereKey("objectId", containedIn: userIDs)
                .orderByAscending("objectId")
                .findObjectsInBackgroundWithBlock({
                    
                    objects, error in
                    
                    if let users = objects as? [PFUser] {
                        var m = Array<AMatch>()
                        for (index, user) in enumerate(users) {
                            m.append(AMatch(id: tupArray[index].0, user: pfUserToUser(user)))
                        }
                        callback(m)
                    }
                    
                })
                
            }
        }
    })
}
