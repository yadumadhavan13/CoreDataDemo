//
//  DivisionsTableViewController.swift
//  CoreDataTest
//
//  Created by YADU MADHAVAN on 27/08/22.
//

import UIKit
import CoreData

class DivisionsTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Family]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addSelected))
        if self.validateData() {
            self.relationShipDemo()
        } else {
            self.fetchData()
        }
    }
    
    func relationShipDemo() {
        let family = Family(context: self.context)
        family.name = "Corleone"
        
        let person = Person(context: self.context)
        person.name = "Micheal"
        person.family = family
        
        do {
            try self.context.save()
        } catch {
        }
        self.fetchData()
    }
    
    func validateData() -> Bool {
        let fetchRequest = Family.fetchRequest()
        do {
            let count = try self.context.count(for: fetchRequest)
            return count == 0 ? true : false
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    func fetchData() {
        do {
            let request = Family.fetchRequest() as NSFetchRequest<Family>
            //            let predicate = NSPredicate(format: "name == %@", argumentArray: ["dilip"])
            //            request.predicate = predicate
            
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            self.items = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func addSelected() {
        let alert = UIAlertController(title: "Add Person", message: "Enter name", preferredStyle: .alert)
        alert.addTextField()
        let submitButton = UIAlertAction(title: "Add", style: .default) { action in
            let textfield = alert.textFields![0]
            
            let newFamily = Family(context: self.context)
            newFamily.name = textfield.text
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "divisionCell", for: indexPath)
        cell.textLabel?.text = self.items?[indexPath.row].name ?? ""
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showEmployeeSegue", sender: indexPath)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEmployeeSegue" {
            if let nextViewController = segue.destination as? EmployeeTableViewController {
                nextViewController.family = self.items?[(sender as! NSIndexPath).row]
            }
        }
    }
}
