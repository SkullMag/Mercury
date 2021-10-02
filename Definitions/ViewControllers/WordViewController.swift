//
//  WordViewController.swift
//  Definitions
//
//  Created by Олег Рыбалко on 20.08.2021.
//

import UIKit

class WordViewController: UIViewController {
    
    @IBOutlet var definitionTextView: UITextView!
    
    var attributedText: NSAttributedString!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        definitionTextView.attributedText = attributedText
        self.definitionTextView.textContainerInset = UIEdgeInsets.zero
        self.definitionTextView.textContainer.lineFragmentPadding = 0
        self.definitionTextView.isEditable = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "volume.2.fill"), style: .plain, target: self, action: #selector(pronounce))
        // self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .play)

        // Do any additional setup after loading the view.
    }
    
    @objc func pronounce() {
        Definitions.pronounceWord(word: self.title!)
    }

}
