//
//  ViewController.swift
//  Todoey
//
//  Created by Hector Delgado on 6/6/19.
//  Copyright © 2019 Hector Delgado. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()    // Array of Item objects for todo-list
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let appContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    
    //MARK: - Define various propeties for the TableView
    
    // Determines number of rows to display in TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Inflates a reusable TableView cell with a list item
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].isDone ? .checkmark : .none

        return cell
    }
    
    // Toggle checkmark when a row is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        
        
//        appContext.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add new list item
    
    // Uses UIAlertController to attempt to add a new item to the list.
    // Adds nothing if the user cancels the action or the textfield is empty
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let addItemAction = UIAlertAction(title: "Add Item", style: .default, handler: { (action) in
            if textField.text?.isEmpty ?? true {
                print("TextField is empty")
            } else {
                
                let newItem = Item(context: self.appContext)
                newItem.title = textField.text!
                newItem.isDone = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newItem)
                
                self.saveItems()
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
    
    func saveItems() {
        do {
           try appContext.save()
        } catch {
           print("Error saving context. \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try appContext.fetch(request)
        } catch {
            print("Error fetching data from context. \(error)")
        }
    }
    
    
}

extension TodoListViewController: UISearchBarDelegate {
    
    // Queries the contents of the SearchBar and updates the TableView to
    // display the results of items matching the results
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let requestPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: requestPredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            
            
            // Run on the msin Queue
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

