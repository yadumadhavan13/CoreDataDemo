//
//  EmployeeTableViewController.swift
//  CoreDataTest
//
//  Created by YADU MADHAVAN on 28/08/22.
//

import UIKit
import CoreData

class EmployeeTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var family: Family?
    var items: [Person]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addSelected))
        self.fetchData()
    }

    func fetchData() {
        
      //  self.items = try! context.fetch(Person.fetchRequest())
        if let value = self.family?.person {
            self.items = value.toArray(Person.self)
        }
        self.tableView.reloadData()
    }
    
    @objc func addSelected() {
        let alert = UIAlertController(title: "Add Person", message: "Enter name", preferredStyle: .alert)
        alert.addTextField()
        let submitButton = UIAlertAction(title: "Add", style: .default) { action in
            let textfield = alert.textFields![0]
            let newPerson = Person(context: self.context)
            newPerson.name = textfield.text
            newPerson.age = 20
            newPerson.gender = "Male"
            newPerson.family = self.family
            do {
                try self.context.save()
            } catch {
            }
            self.fetchData()
        }
        alert.addAction(submitButton)
        self.present(alert, animated: true)
    }
    
    func editAction(index: Int) {
        let alert = UIAlertController(title: "Edit Person", message: "Add name", preferredStyle: .alert)
        alert.addTextField()
        let family = self.items?[index]
        let textfield = alert.textFields![0]
        textfield.text = family?.name ?? ""
        let saveButton = UIAlertAction(title: "Save", style: .default) { action in
            family?.name = textfield.text
            do {
                try self.context.save()
            } catch {
            }
            self.fetchData()
        }
        alert.addAction(saveButton)
        self.present(alert, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell", for: indexPath)
        cell.textLabel?.text = self.items?[indexPath.row].name ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            if let personToRemove = self.items?[indexPath.row] {
                self.context.delete(personToRemove)
                do {
                    try self.context.save()
                } catch {
                    print(error.localizedDescription)
                }
                self.fetchData()
            }
        }
        let editItem = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
            self.editAction(index: indexPath.row)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])
        return swipeActions
    }

}

extension NSSet {
    
    func toArray<S>(_ of: S.Type) -> [S] {
        let array = self.map({$0 as! S})
        return array
    }
    
}
