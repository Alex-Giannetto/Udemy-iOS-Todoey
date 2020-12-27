import UIKit
import RealmSwift
import ChameleonFramework

// MARK: - Default
class TodoListViewController: SwipeTableViewController {
    
    public var selectedCategory: Category? {
        didSet{
            self.loadItems()
            if let title = selectedCategory?.title {
                self.title = title
            }
        }
    }
    
    private let realm = try! Realm()
    private var items: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let hexColor = selectedCategory?.color {
            
            guard let navBar = navigationController?.navigationBar else {fatalError("No navigation bar")}
            navBar.barTintColor = UIColor(hexString: hexColor)
            searchBar.barTintColor = UIColor(hexString: hexColor)
            if let color = HexColor(selectedCategory!.color){
                navBar.tintColor = ContrastColorOf(color, returnFlat: true)
            }
            
        }
    }
    
    //MARK: - TableView Datasource methods
    
    // Create Cells
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    // Create Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = HexColor(selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)

            }
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
    
    // DELETE
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row]{
            do {
                try realm.write{
                    self.realm.delete(item)
                }
            } catch {
                print("Error while deleting item, \(error)")
            }
        }
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
