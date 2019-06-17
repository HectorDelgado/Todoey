//
//  ViewController.swift
//  Todoey
//
//  Created by Hector Delgado on 6/6/19.
//  Copyright © 2019 Hector Delgado. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let colorHex = selectedCategory?.color else {fatalError()}
        
        
        title = selectedCategory?.name
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9Bf6")
    }
    
    //MARK: - Nav Bar Setup
    
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        searchBar.barTintColor = navBarColor
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    
    //MARK: - TableView Delegate Methods
    
    // Determines number of rows to display in TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    // Inflates a reusable TableView cell with a list item
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
    
    // Toggle checkmark when a row is clicked
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone  
                }
            } catch {
                print("Error saving done status. \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - CRUD Operations
    
    // CREATE Operation
    // Adds new Item object to the TableView
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    super.updateModel(at: indexPath)
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting category. \(error)")
            }
        }
    }
    
    
    //MARK: - Add new list item
    
    // Uses UIAlertController to attempt to add a new item to the list.
    // Adds nothing if the user cancels the action or the textfield is empty
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let addItemAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if textField.text?.isEmpty ?? true {
                print("TextField is empty")
            } else {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                            
                            
                        }
                    } catch {
                        print("Error saving new items. \(error)")
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
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

//MARK: - SearchBar Delegate
extension TodoListViewController: UISearchBarDelegate {
    
    // Queries the contents of the SearchBar and updates the TableView to
    // display the results of items matching the results
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
        
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

