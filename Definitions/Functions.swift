//
//  Functions.swift
//  Definitions
//
//  Created by Олег Рыбалко on 15.09.2021.
//

import Foundation
import AVKit


func pronounceWord(word: String) {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: word)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-EN")
    synthesizer.speak(utterance)
}


func create(word: String, attributes: Dictionary<String, (String, String?)>) -> Word {
    let attributesString = NSMutableAttributedString()
    for (key, (line, example)) in attributes {
        let boldAttrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
                         NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
        let regularAtts = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                           NSAttributedString.Key.foregroundColor: UIColor.label]
        attributesString.append(NSAttributedString(string: key.capitalized + ": ", attributes: boldAttrs))
        attributesString.append(NSAttributedString(string: line, attributes: regularAtts))
        if let example = example {
            attributesString.append(NSAttributedString(string: "\nExample: ", attributes: boldAttrs))
            attributesString.append(NSAttributedString(string: example, attributes: regularAtts))
        }
        attributesString.append(NSAttributedString(string: "\n\n", attributes: regularAtts))
    }
    let wordToReturn = Word()
    wordToReturn.word = word
    wordToReturn.attributes = attributesString
    return wordToReturn
}
