//
//  PortfolioViewModel.swift
//  StockSearch
//
//  Created by William Choi on 11/16/20.
//

import Foundation
import Combine

final class PortfolioViewModel: ObservableObject {
    
    @Published var portfolio: [PortfolioItem] = []
    @Published var favorites: [PortfolioItem] = []
    @Published var netWorth: Double = 20000.0
    @Published var loading = true
    private var balance: Double = 0.0
    
    let objectWillChange = ObservableObjectPublisher()
    
    private let portfolioManager: PortfolioManager
    
    private var timer: Timer = Timer()
    
    init(portfolioManager: PortfolioManager = PortfolioManager()) {
        self.portfolioManager = portfolioManager
        
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { timer in
            print("Grabbing fresh market data for 15 second update")
//            self.getData()
        }
        
    }
    
    func removeFavorite(index: Int) {
        portfolioManager.removeFavorite(ticker: favorites[index].ticker)
        favorites.remove(at: index)
    }
    
    func movePortfolioItem(source: IndexSet, destination: Int) {
        portfolio.move(fromOffsets: source, toOffset: destination)
        portfolioManager.savePortfolio(portfolio)
    }
    
    func moveFavoritesItem(source: IndexSet, destination: Int) {
        favorites.move(fromOffsets: source, toOffset: destination)
        portfolioManager.saveFavorites(favorites)
    }
    
    func getData() {
        self.balance = self.portfolioManager.getBalance()
        
        self.portfolioManager.getPortfolio() { portfolio, favorites in
            self.portfolio = portfolio
            self.favorites = favorites
            
            var total: Double = self.balance
            
            for item in self.portfolio {
                total += item.price * item.numShares
            }
            
            self.netWorth = total
            
            self.loading = false
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
        }
    }
}
