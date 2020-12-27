//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Alex on 21/12/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    private var categories: Results<Category>?
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let hexColor = categories?[0].color {
            
            guard let navBar = navigationController?.navigationBar else {fatalError("No navigation bar")}
            navBar.barTintColor = HexColor(hexColor)?.darken(byPercentage: 0.1)
        }
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.title
            
            if let color = HexColor(category.color) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }
        
        
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write{
                    category.items.forEach() { item in
                        self.realm.delete(item)
                    }
                    self.realm.delete(category)
                }
            } catch {
                print("Error while delete category, \(error)")
            }
        }
    }
}
