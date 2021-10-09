//
//  WordsViewController.swift
//  Definitions
//
//  Created by Олег Рыбалко on 18.08.2021.
//

import UIKit
import CoreData

class WordsViewController: UITableViewController {
    
    var wordsArray = Array<Word>()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var collection: Collection!
    
    var wordsDictionary = Dictionary<Character, Array<Word>>()

    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.tableView.register(WordCell.self, forCellReuseIdentifier: "WordCell")
        
        let rightBarButtonItem = UIBarButtonItem(title: "Learn", style: .plain, target: self, action: #selector(learnWords))
        
        self.navigationItem.rightBarButtonItem =
        rightBarButtonItem
        
        wordsArray = (collection.words!.allObjects as! Array<Word>).sorted(by: { word1, word2 in
            word1.word! < word2.word!
        })
    }
    
    @objc func learnWords() {
        
        let learningNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LearningNavigationController") as UINavigationController
        learningNavigationController.modalPresentationStyle = .fullScreen
        let learningViewController = learningNavigationController.viewControllers[0] as! LearningViewController
        learningViewController.words = wordsArray.shuffled()
        self.present(learningNavigationController, animated: true, completion: nil)
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.words!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        var content = cell.defaultContentConfiguration()
        content.text = wordsArray[indexPath.row].word!.capitalized
        content.textProperties.font = UIFont.systemFont(ofSize: 16)
        // content.textProperties.alignment = .center
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWord = wordsArray[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let wordViewNavigation = storyboard.instantiateViewController(identifier: "WordView") as! UINavigationController
        wordViewNavigation.navigationBar.prefersLargeTitles = true
        let wordView = wordViewNavigation.viewControllers[0] as! WordViewController
        
        wordView.title = selectedWord.word!.capitalized
        wordView.attributedText = selectedWord.attributes
        
        tableView.deselectRow(at: indexPath, animated: true)

        self.present(wordViewNavigation, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            collection.removeFromWords(wordsArray[indexPath.row])
            do {
                try context.save()
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }

}
