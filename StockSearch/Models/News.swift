//
//  News.swift
//  StockSearch
//
//  Created by William Choi on 11/30/20.
//

import Foundation

struct News: Codable {
    let urlToImage: String
    let title: String
    let description: String
    let url: String
    let publishedAt: String
    let source: NewsSource
}

struct NewsSource: Codable {
    let name: String
}
