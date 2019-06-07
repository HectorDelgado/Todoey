//
//  ViewController.swift
//  Todoey
//
//  Created by Hector Delgado on 6/6/19.
//  Copyright © 2019 Hector Delgado. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let userDefaultsName = "TodoListArray"  // Name of UserDefaults storage
    let defaults = UserDefaults.standard    // Standard instance of UserDefaults

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem1 = Item()
        let newItem2 = Item()
        let newItem3 = Item()
        
        newItem1.title = "Find Mike"
        newItem2.title = "Buy Eggos"
        newItem3.title = "Destory Demogorgon"
        
        itemArray.append(newItem1)
        itemArray.append(newItem2)
        itemArray.append(newItem3)
        
        if let storedItems = defaults.array(forKey: userDefaultsName) as? [Item] {
            itemArray = storedItems
        }
    }
    
    //Mark -- Define various propeties for the TableView
    
    // Determines number of rows to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Returns a UITableViewCell inflated with data from itemArray
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].isDone ? .checkmark : .none

        return cell
    }
    
    // Toggle between checked and unchecked accessory for list item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //Mark - Add new list item
    
    // Uses UIAlertController to attempt to add a new item to the list.
    // Adds nothing if the user cancels the action or the textfield is empty
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let addItemAction = UIAlertAction(title: "Add Item", style: .default, handler: { (action) in
            if textField.text?.isEmpty ?? true {
                print("TextField is empty")
                
                
            } else {
                let newItem = Item()
                newItem.title = textField.text!
                
                self.itemArray.append(newItem)
                self.defaults.set(self.itemArray, forKey: self.userDefaultsName)
                self.tableView.reloadData()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Action Cancelled")
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(addItemAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

