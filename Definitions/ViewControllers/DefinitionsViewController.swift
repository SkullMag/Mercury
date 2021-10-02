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
    
    //var container: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Definitions"
        
        self.definitionTextView.textContainerInset = UIEdgeInsets.zero
        self.definitionTextView.textContainer.lineFragmentPadding = 0
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        self.addToFavouritesButton.isHidden = true
        self.pronounceButton.isHidden = true
        
        self.searchField.delegate = self
    }
    
    func display_error() {
        DispatchQueue.main.async {
            self.wordLabel.text = self.searchField.text
            self.definitionTextView.text = ""
            let string = NSMutableAttributedString()
            string.append(NSAttributedString(string: "Try another word", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.systemGreen]))
            self.definitionTextView.attributedText = string
            self.activityIndicator.stopAnimating()
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
        if let word = searchField.text {
            let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
            fetchRequest.predicate = NSPredicate(format: "word == %@", word.lowercased())
            do {
                let result = try context.fetch(fetchRequest)
                if result.count != 0 {
                    self.wordLabel.text = result.first!.word!.capitalized
                    self.definitionTextView.attributedText = result.first!.attributes
                    self.addToFavouritesButton.isHidden = false
                    self.pronounceButton.isHidden = false
                    self.activityIndicator.stopAnimating()
                    return
                }
            } catch {
                print(error)
            }
            if word == self.wordLabel.text {
                self.activityIndicator.stopAnimating()
                return
            }
            var URLString: String = "https://api.dictionaryapi.dev/api/v2/entries/en/" + word
            URLString = URLString.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: URLString)
        
            if let url = url {
                let searchedWord = self.searchField.text
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("smth went wrong while request")
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                        return
                    }
                    let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonData = jsonData as? Array<Dictionary<String, Any>>{
                        //var result: Array<String> = []
                        var result = Dictionary<String, (String, String?)>()
                        for word in jsonData {
                            let meanings = word["meanings"] as? Array<Dictionary<String, Any>>
                            if searchedWord!.lowercased() == word["word"] as? String {
                                for meaning in meanings! {
                                    var partOfSpeech = meaning["partOfSpeech"] as? String
                                    let definitions = meaning["definitions"] as? Array<Dictionary<String, Any>>
                                    let definition = definitions?[0]["definition"] as! String
                                    let example = definitions?[0]["example"] as? String
                                    if partOfSpeech == nil {
                                        partOfSpeech = "Phrase"
                                    }
                                    if result[partOfSpeech!] == nil {
                                        result[partOfSpeech!] = (definition, example)
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.definitionTextView.text = ""
                            
                            if self.definitionTextView.text.isEmpty {
                                self.display_error()
                            } else {
                                self.addToFavouritesButton.isHidden = false
                                self.pronounceButton.isHidden = false
                            }
                            self.wordLabel.text = self.searchField.text
                        }
                    } else {
                        self.display_error()
                    }
                }.resume()
            } else {
                self.display_error()
            }
        } else {
            print("type smth in")
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


func addBoldText(fullString: String, boldPartOfString: String, baseFont: UIFont, boldFont: UIFont) -> NSAttributedString {
    let baseFontAttribute = [NSAttributedString.Key.font : baseFont]
    let boldFontAttribute = [NSAttributedString.Key.font : boldFont]

    let attributedString = NSMutableAttributedString(string: fullString, attributes: baseFontAttribute)

    attributedString.addAttributes(boldFontAttribute, range: NSRange(fullString.range(of: boldPartOfString) ?? fullString.startIndex..<fullString.endIndex, in: fullString))

    return attributedString
}
