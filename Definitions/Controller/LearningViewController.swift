//
//  LearningViewController.swift
//  Definitions
//
//  Created by Олег Рыбалко on 02.09.2021.
//

import UIKit

class LearningViewController: UIViewController {
    
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var definitionTextView: UITextView!
    @IBOutlet var forgotButton: UIButton!
    @IBOutlet var rememberButton: UIButton!
    @IBOutlet var wordCountLabel: UILabel!
    @IBOutlet weak var showDefinitionButton: UIButton!
    
    var wordNumber = 0
    var words: Array<Word>!
    var numberOfWords = 0
    var numberOfRemembered = 0
    var currentWord: Word?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definitionTextView.textContainerInset = UIEdgeInsets.zero
        self.definitionTextView.textContainer.lineFragmentPadding = 0
        self.definitionTextView.isEditable = false
        
        // self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: #selector(dismissController))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissController))
        
        numberOfWords = words.count
        
        self.rememberButton.layer.cornerRadius = self.rememberButton.frame.size.height / 2
        self.rememberButton.clipsToBounds = true
        
        self.forgotButton.layer.cornerRadius = self.forgotButton.frame.size.height / 2
        self.forgotButton.clipsToBounds = true
        
        nextWord()
    }
    
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func nextWord() -> Bool {
        self.wordNumber += 1
        if self.wordNumber > self.numberOfWords {
            return true
        } else {
            self.definitionTextView.text = ""
            currentWord = words.remove(at: 0)
            self.wordLabel.text = currentWord!.word!.capitalized
            self.wordCountLabel.text = String(self.wordNumber) + "/" + String(numberOfWords)
            return false
        }
    }
    
    func showResult() {
        let alert = UIAlertController(title: "You remember " + String(numberOfRemembered) + "/" + String(numberOfWords) + " words", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(_) in
            self.dismissController()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func rememberButtonPressed(_ sender: UIButton) {
        let status = nextWord()
        numberOfRemembered += 1
        if status == true {
            showResult()
        }
    }
    
    @IBAction func forgotButtonPressed(_ sender: UIButton) {
        let status = nextWord()
        if status == true {
            showResult()
        }
    }
    
    @IBAction func showDefinition(_ sender: UIButton) {
        if let currentText = showDefinitionButton.titleLabel?.text {
            if currentText == "Show the definition" {
                showDefinitionButton.setTitle("Hide the definition", for: .normal)
                self.definitionTextView.attributedText = currentWord!.attributes
            } else {
                showDefinitionButton.setTitle("Show the definition", for: .normal)
                self.definitionTextView.attributedText = NSAttributedString(string: "")
            }
        }
    }

}
