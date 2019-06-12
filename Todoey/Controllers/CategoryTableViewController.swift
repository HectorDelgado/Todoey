//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Hector Delgado on 6/10/19.
//  Copyright © 2019 Hector Delgado. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var categoryArray = [Category]()
    
    let appContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Segue Setup
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    //MARK: - CRUD Operations
    
    // CREATE operation
    // Adds new Category object to the TableView
    func insertItem(categoryName: String) {
        let newCategory = Category(context: appContext)
        newCategory.name = categoryName
        
        categoryArray.append(newCategory)
        
        updateItems()
    }
    
    // READ operation
    // Loads Category objects based on NSFetchRequest filter.
    // Retrieves all items if no request is passed in as an argument.
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try appContext.fetch(request)
        } catch {
            print("Error fetching data from context. \(error)")
        }
    }
    
    // UPDATE operation
    // Saves the current contents to the NSPersistentContainer and reloads the TableView.
    func updateItems() {
        do {
            try appContext.save()
        } catch {
            print("Error saving context. \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // DELETE Operation
    // Removes an item from the NSPersistentContainer at the given position.
    func deleteItem(itemPosition: Int) {
        appContext.delete(categoryArray[itemPosition])
        categoryArray.remove(at: itemPosition)
        updateItems()
    }
    
    
    //MARK: - Add Button
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addAlertAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            if textField.text?.isEmpty ?? true {
                print("Error. Textfield is Empty")
            } else {
                
                self.insertItem(categoryName: textField.text!)
                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Action cancelled")
        }
        
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alertController.addAction(addAlertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

}
