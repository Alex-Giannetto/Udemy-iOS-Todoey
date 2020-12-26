import UIKit
import RealmSwift

// MARK: - Default
class TodoListViewController: UITableViewController {
    
    public var selectedCategory: Category? {
        didSet{
            self.loadItems()
        }
    }
    
    private let realm = try! Realm()
    private var items: Results<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView Datasource methods
    
    // Create Cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    // Create Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let item = items?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }
        return cell
    }
    
    // Check an item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Add new item
    
    // ADD
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add new todoey item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textfield = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: "Add item", style: .default) { (action) in
            if let textValue = textfield.text, let category = self.selectedCategory {
                do {
                    try self.realm.write{
                        let item = Item()
                        item.title = textValue
                        category.items.append(item)
                    }
                    self.tableView.reloadData()
                } catch {
                    print("Error, \(error)")
                }
            }
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    // LOAD
    func loadItems(){
        items = selectedCategory?.items.sorted(byKeyPath: "createdAt", ascending: true)
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            loadItems()
            items = items?
                .filter("title CONTAINS[cd] %@", searchText)
                .sorted(byKeyPath: "title", ascending: true)
            
            tableView.reloadData();
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            return
        }
        self.searchBarSearchButtonClicked(searchBar)
    }
}
