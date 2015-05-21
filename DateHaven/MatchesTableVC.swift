//
//  MatchesTableVC.swift
//  DateHaven
//
//  Created by Jim Aven on 5/20/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import UIKit

class MatchesTableVC: UITableViewController {
    
    
    var matches:[AMatch] = []
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView = UIImageView(image: UIImage(named: "chat-header"))
        let leftBarBtnItem = UIBarButtonItem(image: UIImage(named: "nav-back-button"), style:UIBarButtonItemStyle.Plain, target: self, action: "goToPreviousVC:")
        navigationItem.setLeftBarButtonItem(leftBarBtnItem, animated: true)
        
        fetchMatches ({
            matched in
            self.matches = matched
            self.tableView.reloadData()
        
        })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToPreviousVC(button:UIBarButtonItem){
        pageController.goToPreviousVC()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return matches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UserCell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserCell

        let user = matches[indexPath.row].user
        cell.nameLabel.text = user.name
        user.getPhoto ({
            image in
            cell.avatarImageView.image = image
        })

        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
