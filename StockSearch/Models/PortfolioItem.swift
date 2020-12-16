//
//  PortfolioItem.swift
//  StockSearch
//
//  Created by William Choi on 11/16/20.
//

import Foundation

struct PortfolioItem: Codable {
    var name: String
    let ticker: String
    var numShares: Double = 0.0
    var inFavorites: Bool = false
    var price: Double = 0.0
    var change: Double = 0.0
}

enum PortfolioItemType: String {
    case favorite
    case portfolio
}
