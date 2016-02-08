//
//  ChooseFontViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 2/8/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit

class ChooseFontViewController: UITableViewController {
//UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let fontsAvailable: [String] = ["Apple Color Emoji", "Avenir", "Cochin", "Kailasa", "Menlo", "Palatino", "Papyrus", "Times New Roman", "Zapfino"]
    var chooseFontViewDelegate: ChooseFontViewProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "FontCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func closeView(sender: AnyObject) {
        closeViewController()
    }
    
    
    // MARK: UITableViewDelegate functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontsAvailable.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FontCell") as UITableViewCell!
        cell.textLabel?.text = fontsAvailable[indexPath.row]
        return cell
    }
    
    private func closeViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let font = fontsAvailable[indexPath.row]
        chooseFontViewDelegate?.selectedFont(font)
        closeViewController()
    }
}

// This protocol defines a method that will be implemented in the MemeEditorViewController to pass info of what font was selected in this table.
protocol ChooseFontViewProtocol {
    func selectedFont(font: String)
}