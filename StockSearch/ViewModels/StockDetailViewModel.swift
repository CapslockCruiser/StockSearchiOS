//
//  StockDetailViewModel.swift
//  StockSearch
//
//  Created by William Choi on 11/20/20.
//

import SwiftUI
import Combine

final class StockDetailViewModel: ObservableObject {
    private let apiManager: APIManager
    private let portfolioManager: PortfolioManager
    
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var loading = true
    @Published var stockDetails: StockDetails?
    @Published var isFavorited = false
    @Published var numShares: Double
    @Published var news: [News] = []
    
    var ticker: String = ""
    
    func setTicker(ticker: String) {
        self.ticker = ticker
//        print(self.ticker)
    }
    
    func getData() {
//        print("Getting stock detail data")
        self.isFavorited = self.portfolioManager.checkIfFavorite(ticker: self.ticker)
        
        apiManager.getStockDetails(ticker: ticker) { details in
            DispatchQueue.main.async {
                self.numShares = self.portfolioManager.getNumShares(ticker: self.ticker)
                self.loading = false
                self.stockDetails = details
                self.objectWillChange.send()
            }
        }
        
    }
    
    func getNews() {
        APIManager.shared.getNews(ticker: ticker) { news in
            self.news = news
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    func toggleFavorites() {
        if isFavorited {
            portfolioManager.removeFavorite(ticker: ticker)
            isFavorited = false
            self.objectWillChange.send()
        } else {
            portfolioManager.addFavorite(ticker: ticker, name: stockDetails?.name ?? "Details Default")
            isFavorited = true
            self.objectWillChange.send()
        }
    }
    
    func updateNumShares() {
        if let ticker = stockDetails?.ticker {
            numShares = portfolioManager.getNumShares(ticker: ticker)
            self.objectWillChange.send()
        }
    }
    
    
    init(apiManager: APIManager = APIManager(), portfolioManager: PortfolioManager = PortfolioManager()) {
        self.apiManager = apiManager
        self.portfolioManager = portfolioManager
        
        self.numShares = self.portfolioManager.getNumShares(ticker: ticker)
    }
}
