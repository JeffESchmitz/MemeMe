//
//  ChooseFontViewController.swift
//  MemeMe
//
//  Created by Jeff Schmitz on 2/8/16.
//  Copyright © 2016 Jeff Schmitz. All rights reserved.
//

import UIKit

// This protocol defines a method that will be implemented in the MemeEditorViewController to pass info of what font was selected in this table.
protocol ChooseFontViewProtocol {
    func selectedFont(_ font: String)
}

class ChooseFontViewController: UITableViewController {
    
    let fontsAvailable: [String] = ["Apple Color Emoji", "Avenir", "Cochin", "HelveticaNeue-CondensedBlack", "Kailasa", "Menlo", "Palatino", "Papyrus", "Times New Roman", "Zapfino"]
    var chooseFontViewDelegate: ChooseFontViewProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FontCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    @IBAction func closeView(_ sender: AnyObject) {
        closeViewController()
    }
    
    
    // MARK: UITableViewDelegate functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontsAvailable.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontCell") as UITableViewCell!
        cell?.textLabel?.text = fontsAvailable[indexPath.row]
        return cell!
    }
    
    fileprivate func closeViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let font = fontsAvailable[indexPath.row]
        chooseFontViewDelegate?.selectedFont(font)
        closeViewController()
    }
}
