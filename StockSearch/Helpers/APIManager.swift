//
//  APIManager.swift
//  StockSearch
//
//  Created by William Choi on 11/13/20.
//

import Foundation
import SwiftUI

class APIManager {
    
    static let shared = APIManager()
    
    private let apiURL = "http://stocksearchapp-env.eba-d3k23mdx.us-east-1.elasticbeanstalk.com/api/"
//    private let apiURL = "http://localhost:8000/api/"
    
    // Daily list URL http://stocksearchapp-env.eba-d3k23mdx.us-east-1.elasticbeanstalk.com/api/daily-list?ticker=aapl,msft
    
    func getStockDetails(ticker: String, success: @escaping (StockDetails) -> Void) {
        let urlString = apiURL + "summary/?ticker=\(ticker)"
        guard let url = URL(string: urlString) else { assertionFailure(); return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
//            print(url.absoluteURL)
            
            if let response = data {
                var jsonResponse: StockDetails
                do {
                    jsonResponse = try JSONDecoder().decode(StockDetails.self, from: response)
                    success(jsonResponse)
                } catch let error {
                    print(error)
                }
            }
            
        }.resume()
    }
    
    func getDailyList(tickers: [String], success: @escaping ([PortfolioItem]) -> Void) {
//        com/api/daily-list?ticker=msft,aapl,
        let tickersString = tickers.map{String($0)}.joined(separator: ",")
        
        let urlString = apiURL + "daily-list/?ticker=\(tickersString)"
        guard let url = URL(string: urlString) else { assertionFailure(); return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
//            print(url.absoluteURL)
            
            if let response = data {
                var jsonResponse: [DailyAPIResult]
                do {
                    jsonResponse = try JSONDecoder().decode([DailyAPIResult].self, from: response)
                    
                    var portfolioItems: [PortfolioItem] = []
                    
                    for ticker in tickers {
                        for response in jsonResponse {
                            if ticker == response.ticker {
                                let stockName = UserDefaults.standard.value(forKey: ticker) as? String ?? "APIMgr Default"
                                
                                let change = response.last - response.prevClose
                                let item = PortfolioItem(name: stockName, ticker: response.ticker, numShares: 0.0, inFavorites: false, price: response.last, change: change)
                                
                                portfolioItems.append(item)
                            }
                        }
                    }
                    
                    success(portfolioItems)
                    
                } catch let error {
                    print(error)
                }
            }
            
        }.resume()
    }
    
    func getNews(ticker: String, success: @escaping ([News]) -> Void) {
        let urlString = apiURL + "news/?ticker=\(ticker)"
        guard let url = URL(string: urlString) else { assertionFailure(); return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
//            print(url.absoluteURL)
            
            if let response = data {
                var jsonResponse: [News]
                do {
                    jsonResponse = try JSONDecoder().decode([News].self, from: response)
//                    print(jsonResponse)
                    success(jsonResponse)
                } catch let error {
                    print(error)
                }
            }
            
        }.resume()
    }
    
    func getImage(urlToImage: String, success: @escaping (Image) -> Void) {
        guard let url = URL(string: urlToImage) else { assertionFailure(); return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
//            print(url.absoluteURL)
            
            if let response = data {
                do {
                    guard let image = UIImage(data: response) else {
                        success(Image(systemName: "link")); return
                    }
                    
                    success(Image(uiImage: image))
                }
            }
            
        }.resume()
    }
    
}

struct StockDetails: Codable {
    let description: String
    let ticker: String
    let name: String
    let exchangeCode: String
    let timestamp: String
    let change: Double
    let changePercent: Double
    let last: Double
    let prevClose: Double
    let open: Double
    let high: Double
    let low: Double
    var mid: Double?
    var volume: Double
    var bidSize: Double?
    var askSize: Double?
    var askPrice: Double?
}

struct DailyAPIResult: Codable {
    let timestamp: String
    let bidPrice: Double?
    let low: Double
    var bidSize: Double?
    let prevClose: Double
    let quoteTimestamp: String
    let last: Double
    let askSize: Double?
    let volume: Int
    let lastSize: Double?
    let ticker: String
    let high: Double
    let tngoLast: Double
    let askPrice: Double?
    let open: Double
    let lastSaleTimestamp: String
    let mid: Double?
}
