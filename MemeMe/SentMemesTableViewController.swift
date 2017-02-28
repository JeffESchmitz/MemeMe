//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 2/28/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit

private let sentMemeTableCellId = "SentMemeTableCellId"

class SentMemesTableViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView!.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sentMemeTableCellId, for: indexPath)

        let meme = appDelegate.memes[indexPath.row]
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = String(format: "%@ - %@", meme.topText!, meme.bottomText!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.editedMemeIndex = indexPath.row
        navigationController?.pushViewController(detailController, animated: true)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the current meme (indexPath.row) from the meme collection
            appDelegate.memes.remove(at: indexPath.row)
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
