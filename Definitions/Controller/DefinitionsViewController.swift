//
//  ViewController.swift
//  Definitions
//
//  Created by Олег Рыбалко on 11.08.2021.
//

import UIKit
import CoreData
import AVKit


class DefinitionsViewController: UIViewController {
    @IBOutlet var searchField: UISearchBar!
    @IBOutlet var definitionTextView: UITextView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var addToFavouritesButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var pronounceButton: UIButton!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    var networkManager = NetworkManager()
    
    //var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Definitions"
        
        self.definitionTextView.textContainerInset = UIEdgeInsets.zero
        self.definitionTextView.textContainer.lineFragmentPadding = 0
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        self.addToFavouritesButton.isHidden = true
        self.pronounceButton.isHidden = true
        
        networkManager.delegate = self
        
        self.searchField.delegate = self
    }
    
    func displayError() {
        DispatchQueue.main.async {
            self.pronounceButton.isHidden = true
            self.addToFavouritesButton.isHidden = true
            self.wordLabel.text = self.searchField.text
            self.definitionTextView.text = ""
            let string = NSMutableAttributedString()
            string.append(NSAttributedString(string: "Try another word", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.systemGreen]))
            self.definitionTextView.attributedText = string
            self.activityIndicator.stopAnimating()
        }
    }
    
    func show(word: DictionaryWord) {
        DispatchQueue.main.async {
            self.wordLabel.text = word.word
            self.definitionTextView.attributedText = word.attributes
            self.activityIndicator.stopAnimating()
            self.addToFavouritesButton.isHidden = false
            self.pronounceButton.isHidden = false
        }
    }
    
    @IBAction func addToFavourites(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let collectionPickerNavigation = storyboard.instantiateViewController(identifier: "CollectionPickerNavigation") as! UINavigationController
        let collectionPicker = (collectionPickerNavigation.viewControllers[0] as! CollectionPickerViewController)
        collectionPicker.word = self.wordLabel.text
        collectionPicker.wordAttributes = self.definitionTextView.attributedText
        
        self.present(collectionPickerNavigation, animated: true, completion: nil)
    }

    @IBAction func searchButton(_ sender: UIButton) {
        activityIndicator.startAnimating()
        search()
    }
    
    @IBAction func pronounceWord(_ sender: UIButton) {
        Definitions.pronounceWord(word: self.wordLabel.text!)
    }
    
    func search() {
        searchField.endEditing(true)
        self.addToFavouritesButton.isSelected = false
        self.definitionTextView.flashScrollIndicators()

        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        guard let word = searchField.text else { return }
        fetchRequest.predicate = NSPredicate(format: "word == %@", word.lowercased())
        guard let result = try? context.fetch(fetchRequest) else {
            displayError()
            return
        }
        if result.count != 0 {
            self.wordLabel.text = result.first!.word!.capitalized
            self.definitionTextView.attributedText = result.first!.attributes
            self.addToFavouritesButton.isHidden = false
            self.pronounceButton.isHidden = false
            self.activityIndicator.stopAnimating()
            return
        }
            
        if word == self.wordLabel.text {
            self.activityIndicator.stopAnimating()
            return
        }
        networkManager.get(word: word) { dictionaryWord in
            self.show(word: dictionaryWord)
        }
            
    }
    
}

extension DefinitionsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchButton.isEnabled = self.searchField.text!.isEmpty ? false : true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == false {
            self.activityIndicator.startAnimating()
            search()
        }
    }
}

extension DefinitionsViewController: NetworkManagerDelegate {
    func didRaiseError() {
        self.displayError()
    }
    
}
