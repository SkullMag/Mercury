//
//  CollectionPickerViewController.swift
//  Definitions
//
//  Created by Олег Рыбалко on 20.08.2021.
//

import UIKit
import CoreData

class CollectionPickerViewController: UITableViewController {
    
    var collections = Array<Collection>()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var word: String!
    var wordAttributes: NSAttributedString!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let fetchRequest = NSFetchRequest<Collection>(entityName: "Collection")
        do {
            collections = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    @objc func saveChanges() {
        do {
            try context.save()
        } catch {
            print(error)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Collection")!
        
        
        var content = cell.defaultContentConfiguration()
        let collection = collections[indexPath.row]
        content.text = collection.name
        
        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        fetchRequest.predicate = NSPredicate(format: "word == %@", word.lowercased())
        
        do {
            let words: [Word] = try context.fetch(fetchRequest)
            if words.count != 0 && collection.words?.contains(words[0]) == true {
                cell.accessoryType = .checkmark
            }
        } catch {
            // No word found
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let collection = collections[indexPath.row]
        cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
        
        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        let predicate = NSPredicate(format: "word == %@", word.lowercased())
        var savedWord: [Word]
        fetchRequest.predicate = predicate
        
        do {
            savedWord = try context.fetch(fetchRequest)
            if cell.accessoryType == .checkmark {
                if savedWord.count != 0 {
                    if savedWord[0].collections?.contains(collection) == false {
                        collection.addToWords(savedWord[0])
                    }
                    // collections[indexPath.row].words = collections[indexPath.row].words!.adding(savedWord) as NSSet
                } else {
                    let newWord = Word(context: context)
                    newWord.setValue(word.lowercased(), forKey: "word")
                    newWord.setValue(wordAttributes, forKey: "attributes")
                    newWord.addToCollections(collections[indexPath.row])
                }
            } else {
                if savedWord.count != 0 {
                    if collection.words?.contains(savedWord[0]) == true {
                        collection.removeFromWords(savedWord[0])
                    }
                }
            }
        } catch {
            print(error)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }

}


//extension CollectionPickerViewController: UITableViewDelegate {
//
//}
//
//extension CollectionPickerViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//
//
//}
