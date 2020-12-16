//
//  AutoCompleteManager.swift
//  StockSearch
//
//  Created by William Choi on 11/20/20.
//

import Foundation

final class AutoCompleteManager {
    
    private let apiURL = "http://stocksearchapp-env.eba-d3k23mdx.us-east-1.elasticbeanstalk.com/api/"
//    private let apiURL = URL(string: "http://localhost:8000/api/")
    
    func getMatchedStocks(searchTerm: String, success: @escaping ([AutoComplete]) -> Void) {
        guard let encoded = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            assertionFailure(); return
        }
        
        let encodedSearchTerm = String(describing: encoded)
        
        let urlString = apiURL + "autocomplete/?string=\(encodedSearchTerm)"
        guard let url = URL(string: urlString) else {
            assertionFailure(); return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
//                print("Here")n
            if let response = data {
                var jsonResponse: [AutoComplete] = []
                do {
                    jsonResponse = try JSONDecoder().decode([AutoComplete].self, from: response)
                    success(jsonResponse)
//                        print(self.autocompleteList)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}

struct AutoComplete: Codable {
    var name: String
    var ticker: String
}
