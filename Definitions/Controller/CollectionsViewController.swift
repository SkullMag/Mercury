//
//  CollectionsViewController.swift
//  Definitions
//
//  Created by Олег Рыбалко on 18.08.2021.
//

import UIKit
import CoreData

class CollectionsViewController: UIViewController {
    
    @IBOutlet var collectionsTableView: UITableView!
    
    var collections = Array<Collection>()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionsTableView.delegate = self
        collectionsTableView.dataSource = self
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createCollection))
        // rightBarButtonItem.customView?.clipsToBounds = true
        
        self.navigationItem.rightBarButtonItem =
        rightBarButtonItem

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let fetchRequest = NSFetchRequest<Collection>(entityName: "Collection")
        do {
            collections = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        collectionsTableView.reloadData()
    }
    
    @objc func createCollection() {
        let alert = UIAlertController(title: "New Collection", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        })
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {(action) in
            let collection = Collection(context: self.context)
            let collectionName = alert.textFields![0].text
            if collectionName?.isEmpty == false {
                collection.name = collectionName
                do {
                    try self.context.save()
                    self.collectionsTableView.reloadData()
                } catch {
                    
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension CollectionsViewController: UITableViewDelegate {
    
}

extension CollectionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.accessoryType = .disclosureIndicator
        
        var content = cell.defaultContentConfiguration()
        let collection = collections[indexPath.row]
        
        let headlineFont = UIFont.boldSystemFont(ofSize: 20)
        
        content.textProperties.font = headlineFont
        content.text = collection.name
        
        content.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .footnote)
        content.secondaryTextProperties.color = UIColor.gray
        content.secondaryText = String(collection.words!.count) + " words"
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameItem = UIContextualAction(style: .normal, title: "Rename", handler: {(contextualAction, view, boolValue) in
            let newTitleAlert = UIAlertController(title: "New title", message: nil, preferredStyle: .alert)
            newTitleAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            newTitleAlert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action) in
                self.collections[indexPath.row].name = newTitleAlert.textFields![0].text
                do {
                    try self.context.save()
                } catch {
                    print(error)
                }
                self.collectionsTableView.deselectRow(at: indexPath, animated: true)
                self.collectionsTableView.reloadData()
            }))
            newTitleAlert.addTextField(configurationHandler: {(textField) in
                textField.placeholder = "Name"
                textField.text = self.collections[indexPath.row].name
            })
            self.present(newTitleAlert, animated: true, completion: nil)
        })
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete", handler: {(contextualAction, view, boolValue) in
            self.context.delete(self.collections[indexPath.row])
            do {
                try self.context.save()
                tableView.reloadData()
            } catch {
                print(error)
            }
        })
        renameItem.backgroundColor = .orange
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, renameItem])

        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = collections[indexPath.row]
        let collectionName = collection.name
        let words = collection.words!
        if words.count != 0 {
            let wordsViewController = WordsViewController.init()
            wordsViewController.title = collectionName
            wordsViewController.collection = collection
            let navigationController = UINavigationController(rootViewController: wordsViewController)
            //wordsView.tableView(wordsView.tableView, numberOfRowsInSection: 1)
            //wordsView.navigationItem.title = "Title"
            tableView.deselectRow(at: indexPath, animated: true)
            self.present(navigationController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No words in " + collectionName!, message: nil, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.dismiss(animated: true, completion: nil)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    
}
