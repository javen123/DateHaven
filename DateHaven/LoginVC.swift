//
//  LoginVC.swift
//  DateHaven
//
//  Created by Jim Aven on 5/15/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnPressed(sender: UIButton) {
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "user_about_me", "user_birthday"], block: {
            user, error in
            if user == nil {
                println("Uh oh. The user cancelled the Facebook Login.")
            }
            else if user!.isNew {
                
                let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me?fields=picture,first_name,birthday,gender", parameters: nil)
                graphRequest.startWithCompletionHandler({
                    
                    connection, result, error in
                    
                    var r = result as! NSDictionary
                    user!["firstName"] = r["first_name"]
                    user!["gender"] = r["gender"]
                    user!["picture"] = ((r["picture"] as! NSDictionary)["data"] as! NSDictionary) ["url"]
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    user!["birthday"] = dateFormatter.dateFromString(r["birthday"] as! String)
                    
                    
                    let pictureURL = ((r["picture"] as! NSDictionary)["data"] as! NSDictionary) ["url"] as! String
                    let url = NSURL(string: pictureURL)
                    let request = NSURLRequest(URL: url!)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                        response, data, error in
                        
                        let imageFile = PFFile(name: "avatar.jpg", data: data)
                        user!["picture"] = imageFile
                        user!.saveInBackgroundWithBlock(nil)
                    })
                    
                    user!.saveInBackgroundWithBlock({
                        success, error in
                        println(success)
                        println(error)
                    })
                    }
                )
                println("User signed up and logged in through Facebook!")
            }
            else {
                println("User logged in through Facebook!")
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CardsNavController") as? UIViewController
            
            self.presentViewController(vc!, animated: true, completion: nil)
        })
    }
    
    
}
