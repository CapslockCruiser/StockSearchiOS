//
//  Environment.swift
//  StockSearch
//
//  Created by William Choi on 11/18/20.
//

import Foundation

struct Environment {
    var production: Bool
    var apiURL: URL
    
    init(isProduction: Bool) {
        self.production = isProduction
        
        if !self.production {
            self.apiURL = URL(string: "http://stocksearchapp-env.eba-d3k23mdx.us-east-1.elasticbeanstalk.com/api/")!
        } else {
            self.apiURL = URL(string: "http://localhost:8000/api/")!
        }
    }
}
