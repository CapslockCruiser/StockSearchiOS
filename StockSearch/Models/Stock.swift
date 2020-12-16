//
//  Stock.swift
//  StockSearch
//
//  Created by William Choi on 11/13/20.
//

import Foundation

struct Stock {
    let ticker: String
    var numShares: Double
    var inFavorites: Bool = false
    var name: String = "Stock Name"
    var price: Double = 100
    var change: Double = 0.2
}
