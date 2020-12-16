//
//  PortfolioManager.swift
//  StockSearch
//
//  Created by William Choi on 11/16/20.
//

import Foundation

class PortfolioManager {
    
    private let favoritesOrderString = "favoritesOrder"
    private let portfolioOrderString = "portfolioOrder"
    
    func getBalance() -> Double {
        if let balance = UserDefaults.standard.value(forKey: "balance") as? Double {
            return balance
        } else {
            UserDefaults.standard.set(20000.00, forKey: "balance")
            return 20000.00
        }
    }
    
    func getPortfolio(success: @escaping ([PortfolioItem], [PortfolioItem]) -> ()) {
//        let portfolioOrder = UserDefaults.standard.structData([PortfolioStruct].self, forKey: portfolioOrderString) ?? []
        
        let portfolioOrder: [PortfolioStruct] = getPortfolioStructs()
        
        let favoritesOrder = UserDefaults.standard.value(forKey: favoritesOrderString) as? [String] ?? []
        
        var portfolioTickers: [String] = []
        
        for item in portfolioOrder {
            portfolioTickers.append(item.ticker)
        }
        
        let combinedTickers = portfolioTickers + favoritesOrder
        
        let unique = Array(Set(combinedTickers))
        
        APIManager.shared.getDailyList(tickers: unique) { combinedItems in
//            print(combinedItems)
            var portfolioItems: [PortfolioItem] = []
            var favoritesItems: [PortfolioItem] = []
            
            for portfolio in portfolioOrder {
                var item = combinedItems.filter() { $0.ticker == portfolio.ticker }[0]
                
                item.name = UserDefaults.standard.value(forKey: portfolio.ticker) as? String ?? "PM.getPortfolio default"
                
                item.numShares = portfolio.numShares
                
                portfolioItems.append(item)
            }
            
            var portfolioDictionary: [String: Double] = [:]
            
            for item in portfolioItems {
                portfolioDictionary[item.ticker] = item.numShares
            }
            
            for ticker in favoritesOrder {
                var item = combinedItems.filter(){ $0.ticker == ticker }[0]
                
                item.name = UserDefaults.standard.value(forKey: ticker) as? String ?? "PM.getPortfolio default"
                
                if let numShares = portfolioDictionary[ticker] {
                    item.numShares = numShares
                }
                
                favoritesItems.append(item)
            }
            
            success(portfolioItems, favoritesItems)
        }
        
    }
    
    func checkIfFavorite(ticker: String) -> Bool {
        if let favoritesOrder = UserDefaults.standard.value(forKey: favoritesOrderString) as? [String] {
            if favoritesOrder.contains(ticker) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func removeFavorite(ticker: String) {
        guard let favoritesOrder = UserDefaults.standard.value(forKey: favoritesOrderString) as? [String] else { assertionFailure(); return }
        
        let newOrder = favoritesOrder.filter { $0 != ticker }
        
        UserDefaults.standard.set(newOrder, forKey: favoritesOrderString)
    }
    
    func addFavorite(ticker: String, name: String = "Mgr Default") {
        if var favoritesOrder = UserDefaults.standard.value(forKey: favoritesOrderString) as? [String] {
            favoritesOrder.append(ticker)
            
            UserDefaults.standard.set(favoritesOrder, forKey: favoritesOrderString)
            UserDefaults.standard.set(name, forKey: ticker)
        } else {
            UserDefaults.standard.set([ticker], forKey: favoritesOrderString)
            UserDefaults.standard.set(name, forKey: ticker)
        }
    }
    
    func savePortfolio(_ portfolio: [PortfolioItem]) {
        var newPortfolioOrder = [PortfolioStruct]()
        
        for item in portfolio {
            let newItem = PortfolioStruct(ticker: item.ticker, numShares: item.numShares)
            newPortfolioOrder.append(newItem)
        }
        
        let data = try! JSONEncoder().encode(newPortfolioOrder)
        UserDefaults.standard.set(data, forKey: portfolioOrderString)
    }
    
    func saveFavorites(_ favorites: [PortfolioItem]) {
        var tickers = [String]()
        
        for favorite in favorites {
            tickers.append(favorite.ticker)
        }
        
        UserDefaults.standard.set(tickers, forKey: favoritesOrderString)
    }
    
    func getNumShares(ticker: String) -> Double {
        var portfolioOrder: [PortfolioStruct] = []
        
        if let portfolioData = UserDefaults.standard.object(forKey: portfolioOrderString) as? Data {
            guard let portfoliosDecoded = try? JSONDecoder().decode([PortfolioStruct].self, from: portfolioData) else {
                assertionFailure(); return 0.0
            }
            
            portfolioOrder = portfoliosDecoded
        }
        
        if portfolioOrder.count == 0 {
            return 0.0
        }
        
        let filtered = portfolioOrder.filter({ $0.ticker == ticker })
        
        if filtered.count > 0 {
            return portfolioOrder[0].numShares
        } else {
            return 0.0
        }
    }
    
    func buyShares(ticker: String, price: Double, shares: Double, name: String = "Buy Shares Default") {
        
        var portfolioOrder: [PortfolioStruct] = []
        if let portfolioData = UserDefaults.standard.object(forKey: portfolioOrderString) as? Data {
            guard let portfoliosDecoded = try? JSONDecoder().decode([PortfolioStruct].self, from: portfolioData) else {
                assertionFailure(); return
            }
            
            portfolioOrder = portfoliosDecoded
        }
        
        let newPortfolioItem = PortfolioStruct(ticker: ticker, numShares: shares)
        
        if portfolioOrder.count == 0 {
            let data = try! JSONEncoder().encode([newPortfolioItem])
            UserDefaults.standard.set(data, forKey: portfolioOrderString)
        } else {
            var alreadyExists = false
            
            var newPortfolioOrder = [PortfolioStruct]()
            
            for item in portfolioOrder {
                var newItem = PortfolioStruct(ticker: item.ticker, numShares: item.numShares)
                if item.ticker == ticker {
                    newItem.numShares = item.numShares + shares
                    alreadyExists = true
                }
                newPortfolioOrder.append(newItem)
            }
            
            if !alreadyExists {
                newPortfolioOrder.append(newPortfolioItem)
            }
            
            let data = try! JSONEncoder().encode(newPortfolioOrder)
            UserDefaults.standard.set(data, forKey: portfolioOrderString)
        }
        
        let newBalance = getBalance() - price * shares
        
        UserDefaults.standard.set(newBalance, forKey: "balance")
    }
    
    func sellShares(ticker: String, price: Double, shares: Double) {
        // Also update balance
        let portfolioStructs = getPortfolioStructs()
        
        var newPortfolioStructs: [PortfolioStruct] = []
        
        for item in portfolioStructs {
            var newItem = PortfolioStruct(ticker: item.ticker, numShares: item.numShares)
            if item.ticker == ticker {
                newItem.numShares -= shares
            }
            if newItem.numShares > 0.001 {
                newPortfolioStructs.append(newItem)
            }
        }
        
        let data = try! JSONEncoder().encode(newPortfolioStructs)
        UserDefaults.standard.set(data, forKey: portfolioOrderString)
        
        let newBalance = getBalance() + price * shares
        
        UserDefaults.standard.set(newBalance, forKey: "balance")
    }
    
    private func getPortfolioStructs() -> [PortfolioStruct] {
        var portfolioOrder: [PortfolioStruct] = []
        if let portfolioData = UserDefaults.standard.object(forKey: portfolioOrderString) as? Data {
            guard let portfoliosDecoded = try? JSONDecoder().decode([PortfolioStruct].self, from: portfolioData) else {
                assertionFailure(); return []
            }
            
            portfolioOrder = portfoliosDecoded
        }
        
        return portfolioOrder
    }

}

struct PortfolioStruct: Codable {
    let ticker: String
    var numShares: Double
}
