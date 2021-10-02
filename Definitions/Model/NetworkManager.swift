//
//  NetworkManager.swift
//  Definitions
//
//  Created by Олег Рыбалко on 01.10.2021.
//

import Foundation
import UIKit


protocol NetworkManagerDelegate {
    func didRaiseError(error: Error)
}

typealias CompletionHandler = (_ word: Word) -> Void


struct NetworkManager {
    let dictionaryAPI = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    var delegate: NetworkManagerDelegate?
    
    func get(word: String, completionHandler: @escaping CompletionHandler) {
        var URLString = dictionaryAPI + word
        URLString = URLString.replacingOccurrences(of: " ", with: "%20")
        let request = URLRequest(url: URL(string: URLString)!)
        perform(request: request, word: word) { word in
            completionHandler(word)
        }
    }
    
    func perform(request: URLRequest, word: String, completionHandler: @escaping CompletionHandler) {
        URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                delegate?.didRaiseError(error: error!)
                return
            }
            let jsonData = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let jsonData = jsonData as? Array<Dictionary<String, Any>> {
                var attributes = Dictionary<String, (String, String?)>()
                for dictionaryWord in jsonData {
                    let meanings = dictionaryWord["meanings"] as? Array<Dictionary<String, Any>>
                    if word.lowercased() == dictionaryWord["word"] as? String {
                        for meaning in meanings! {
                            var partOfSpeech = meaning["partOfSpeech"] as? String
                            let definitions = meaning["definitions"] as? Array<Dictionary<String, Any>>
                            let definition = definitions?[0]["definition"] as! String
                            let example = definitions?[0]["example"] as? String
                            if partOfSpeech == nil {
                                partOfSpeech = "Phrase"
                            }
                            if attributes[partOfSpeech!] == nil {
                                attributes[partOfSpeech!] = (definition, example)
                            }
                        }
                        completionHandler(Definitions.create(word: word, attributes: attributes))
                    }
                }
            }
            
        }
    }
}
