//
//  TradeSheetModalView.swift
//  StockSearch
//
//  Created by William Choi on 12/1/20.
//

import SwiftUI

struct TradeSheetModalView: View {
    
    @Binding var presenting: Bool
    
    var stockDetailViewModel: StockDetailViewModel
    var portfolioManager: PortfolioManager
    
    @State private var sharesRequested = ""
    @State private var successfullyBought = false
    @State private var showToast: Bool = false
    @State private var toastMessage = ""
    @State private var isBuying = true
    
    var body: some View {
        if successfullyBought {
            ZStack {
                Color.green
                
                VStack {
                    Spacer()
                    Text("Congratulations!").font(.system(size: 30)).foregroundColor(.white).bold().padding(.bottom, 12)
                    
                    let sellOrBuyText = isBuying ? "bought" : "sold"
                    let sharesText = (Double(sharesRequested) ?? 0) > 1 ? "shares" : "share"
                    Text("You have successfully \(sellOrBuyText) \(String(format: "%.0f", (Double(sharesRequested) ?? 0.0))) \(sharesText) of \(stockDetailViewModel.stockDetails?.ticker ?? "Stock Ticker")").foregroundColor(.white).font(.system(size: 14))
                    Spacer()
                    Button(action: dismissSelf, label: {
                        Text("Done").padding(.leading, 100).padding(.trailing, 100).padding(.top, 12).padding(.bottom, 12).background(Color.white).foregroundColor(.green).cornerRadius(40)
                    }).padding(.bottom, 24)
                }
            }.background(Color.green.edgesIgnoringSafeArea(.all))
        } else {
            VStack {
                HStack {
                    Button(action: dismissSelf, label : {
                        Image(systemName: "xmark").foregroundColor(.black)
                    })
                    Spacer()
                }
                Text("Trade \(stockDetailViewModel.stockDetails?.name ?? "Stock Name") shares").font(.system(size: 14)).bold().padding(.top, 12)
                Spacer()
                VStack {
                    HStack {
                        TextField("0", text: $sharesRequested).keyboardType(.decimalPad).font(.system(size: 60))
                        let sharesText = (Double(sharesRequested) ?? 0) > 1 ? "Shares" : "Share"
                        Text(sharesText).font(.system(size: 22))
                    }
                    HStack {
                        Spacer()
                        let pricePerShare = stockDetailViewModel.stockDetails?.last ?? 0
                        Text("x $\(String(format: "%.2f", pricePerShare))/share = $\(String(format: "%.2f", pricePerShare * (Double(sharesRequested) ?? 0.0)))").font(.system(size: 14)).padding(.top, 12).fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
                Text("$\(String(format: "%.2f", portfolioManager.getBalance())) available to buy \(stockDetailViewModel.stockDetails?.ticker ?? "Stock Ticker")").font(.system(size: 12)).foregroundColor(.gray)
                HStack {
                    Button(action: buyShares, label: {
                        Text("Buy").padding(.leading, 65).padding(.trailing, 65).padding(.top, 12).padding(.bottom, 12).background(Color.green).foregroundColor(.white).cornerRadius(40)
                    })
                    Spacer()
                    Button(action: sellShares, label: {
                        Text("Sell").padding(.leading, 65).padding(.trailing, 65).padding(.top, 12).padding(.bottom, 12).background(Color.green).foregroundColor(.white).cornerRadius(40)
                    })
                }
            }.padding(14).toast(isPresented: self.$showToast) {
                HStack {
                    Text(toastMessage).foregroundColor(.white)
                } //HStack
            } //toast
        }
    }
    
    func buyShares() {
        isBuying = true
        
        if let shares = Double(sharesRequested) {
            
            let price = stockDetailViewModel.stockDetails?.last ?? 0
            let ticker = stockDetailViewModel.stockDetails?.ticker ?? "Buy Default"
        
            if shares <= 0 {
                toastMessage = "Cannot buy fewer than 0 share"
                showToast = true
                return
            }
            
            let totalPrice = shares * price
            let balance = portfolioManager.getBalance()
            
            if totalPrice > balance {
                toastMessage = "Not enough money to buy"
                showToast = true
                return
            }
            
            successfullyBought = true
            
            portfolioManager.buyShares(ticker: ticker, price: price, shares: shares, name: stockDetailViewModel.stockDetails?.name ?? "Trade Sheet Default")
            
            return
            
        } else {
            toastMessage = "Please enter a valid amount"
            showToast = true
        }
    }
    
    func sellShares() {
        isBuying = false
        
        if let shares = Double(sharesRequested) {
            
            let ticker = stockDetailViewModel.stockDetails?.ticker ?? "Sell Default"
            
            let price = stockDetailViewModel.stockDetails?.last ?? 0
            let sharesOwned = portfolioManager.getNumShares(ticker: ticker)
            
            if shares <= 0 {
                toastMessage = "Cannot sell fewer than 0 share"
                showToast = true
                return
            }
        
            if shares > sharesOwned {
                toastMessage = "Not enough shares to sell"
                showToast = true
                return
            }
            
            successfullyBought = true
            
            portfolioManager.sellShares(ticker: ticker, price: price, shares: shares)
            
            return
            
        } else {
            toastMessage = "Please enter a valid amount"
            showToast = true
        }
    }
    
    func dismissSelf() {
        presenting = false
    }
}
