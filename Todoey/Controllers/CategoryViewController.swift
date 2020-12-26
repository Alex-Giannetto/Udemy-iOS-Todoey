//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Alex on 21/12/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    private var categories: Results<Category>?
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new todoey category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textfield = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: "Add category", style: .default) { (action) in
            if let textValue = textfield.text{
                
                let category = Category()
                category.title = textValue
                self.saveData(category: category)
            }
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].title ?? ""
        return cell
    }
    
    // On cell click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier != "goToItems"){
            return
        }
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
    
    //MARK: - DATA
    func loadCategories(){
        categories = realm.objects(Category.self)
    }
    
    func saveData(category: Category){
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        self.tableView.reloadData()
    }
}
