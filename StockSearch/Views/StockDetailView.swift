//
//  StockDetailView.swift
//  StockSearch
//
//  Created by William Choi on 11/16/20.
//

import SwiftUI
import Combine

struct StockDetailView: View {
    @ObservedObject var stockDetailViewModel = StockDetailViewModel()
    @State private var webViewTitle = "Web View"
    @State private var isExpanded: Bool = false
    @State private var showingTradeSheet = false
    
    var ticker: String
    
    private let paddingAmount = CGFloat(12)
    
    var body: some View {
        if stockDetailViewModel.loading {
            VStack {
                ProgressView().progressViewStyle(CircularProgressViewStyle()).padding(.top, -60)
                Text("Fetching Data...").foregroundColor(.gray).padding(.top, -20)
            }.onAppear(perform: {
                self.stockDetailViewModel.getData()
                self.stockDetailViewModel.getNews()
            })
        } else {
            ScrollView() {
                VStack(alignment: .leading) {
                    Group {
        //                Text(stockDetailViewModel.stockDetails?.ticker ?? "Ticker").bold().font(.system(size:24))
                        Text(stockDetailViewModel.stockDetails?.name ?? "Stock Name").bold().foregroundColor(.gray).font(.system(size:14)).padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                        HStack {
                            if let price = stockDetailViewModel.stockDetails?.last {
                                let priceString = String(format: "%.2f", price)
                                Text("$\(priceString)").bold().font(.system(size:24))
                            }
                            if let change = stockDetailViewModel.stockDetails?.change {
                                if change < 0 {
                                    Text("($\(String(format: "%.2f", change)))").foregroundColor(.red).font(.system(size:16))
                                } else if change > 0 {
                                    Text("($\(String(format: "%.2f", change)))").foregroundColor(.green).font(.system(size:16))
                                } else {
                                    Text("($\(String(format: "%.2f", change)))").foregroundColor(.black).font(.system(size:16))
                                }
                            }
                        }.padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                        Highstocks(ticker: ticker).frame(width: 360, height: 420, alignment: .center)
                    } // End of Group
                    Group {
                        Text("Portfolio").font(.system(size: 22)).padding(.top, 12).padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                        HStack {
                            if stockDetailViewModel.numShares > 0 {
                                let marketValue = stockDetailViewModel.numShares * (stockDetailViewModel.stockDetails?.last ?? 0)
                                VStack(alignment: .leading) {
                                    Text("Shares owned: \(String(format: "%.4f", stockDetailViewModel.numShares))").font(.system(size:14))
                                    Text("Market Value: $ \(String(format: "%.2f", marketValue))").font(.system(size:14))
                                }
                            } else {
                                if stockDetailViewModel.numShares == 0 {
                                    VStack(alignment: .leading) {
                                        Text("You have 0 shares of \(ticker)").font(.system(size:14))
                                        Text("Start trading!").font(.system(size:14))
                                    }
                                } else {
                                    let marketValue = stockDetailViewModel.numShares * (stockDetailViewModel.stockDetails?.last ?? 0)
                                    VStack(alignment: .leading) {
                                        Text("Shares Owned: \(String(format: "%.4f", stockDetailViewModel.numShares))").font(.system(size:14))
                                        Text("Market Value: $\(String(format: "%.2f", marketValue))").font(.system(size:14))
                                    }
                                }
                            }
                            Spacer().onChange(of: showingTradeSheet) {_ in
                                if showingTradeSheet == false {
                                    stockDetailViewModel.updateNumShares()
                                }
                            }
                            Button(action: showTradeView, label: {
                                Text("Trade").padding(.leading, 50).padding(.trailing, 50).padding(.top, 12).padding(.bottom, 12).background(Color.green).foregroundColor(.white).cornerRadius(40)
                            }).sheet(isPresented: $showingTradeSheet, content: {
                                TradeSheetModalView(presenting: $showingTradeSheet, stockDetailViewModel: stockDetailViewModel, portfolioManager: PortfolioManager())
                            })
                        }.padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                    } // End of Portfolio group
                    Group {
                        Text("Stats").font(.system(size: 22)).padding(.top, 12).padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                        ScrollView(.horizontal) {
                            let gridItems = [
                                GridItem(.flexible(), spacing: 0, alignment: .leading),
                                GridItem(.flexible(), spacing: 0, alignment: .leading),
                                GridItem(.flexible(), spacing: 0, alignment: .leading)
                            ]
                            LazyHGrid(rows: gridItems) {
                                let last = stockDetailViewModel.stockDetails?.last ?? 0.0
                                let open = stockDetailViewModel.stockDetails?.open ?? 0.0
                                let high = stockDetailViewModel.stockDetails?.high ?? 0.0
                                let low = stockDetailViewModel.stockDetails?.low ?? 0.0
                                let mid = stockDetailViewModel.stockDetails?.mid ?? 0.0
                                let volume = stockDetailViewModel.stockDetails?.volume ?? 0
                                let bidPrice = stockDetailViewModel.stockDetails?.askPrice ?? 0.0
                                
                                Text("Current Price: \(String(format: "%.2f", last))").font(.system(size:14))
                                Text("Open Price: \(String(format: "%.2f", open))").font(.system(size:14))
                                Text("High: \(String(format: "%.2f", high))").font(.system(size:14))
                                Text("Low: \(String(format: "%.2f", low))").font(.system(size:14))
                                Text("Mid: \(String(format: "%.2f", mid))").font(.system(size:14))
                                Text("Volume: \(String(format: "%.0f", volume))").font(.system(size:14))
                                Text("Bid Price: \(String(format: "%.2f", bidPrice))").font(.system(size:14))
                            }.frame(height: 72)
                        }.padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                    } // End of Stats group
                    Group {
                        Text("About").font(.system(size: 22)).padding(.top, 12).padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
    //                    Text(stockDetailViewModel.stockDetails?.description ?? "Description")
                        
    //                    https://stackoverflow.com/questions/63741474/how-to-implement-a-read-more-style-button-at-the-end-of-a-text-in-swiftui
                        VStack(alignment: .leading) {
                            Text(stockDetailViewModel.stockDetails?.description ?? "Could not retriev company description").font(.system(size:14)).lineLimit(isExpanded ? nil: 2).padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                            Button(action: {
                                isExpanded.toggle()
                            }) {
                                HStack {
                                    Spacer()
                                    Text(isExpanded ? "Show less" : "Show more").font(.caption).bold().foregroundColor(.gray)
                                }.padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                            }
                            
                        }
//                        Text(stockDetailViewModel.stockDetails?.description ?? "Could not retrieve company description.").font(.system(size:14))
//                            .lineLimit(isExpanded ? nil : 3)
//                            .overlay(
//                                GeometryReader { proxy in
//                                    Button(action: {
//                                        isExpanded.toggle()
//                                    }) {
//                                        Text(isExpanded ? "Show less" : "Show more")
//                                            .font(.caption).bold()
//                                            .foregroundColor(.gray)
//                                            .padding(.leading, 8.0)
//                                            .padding(.top, 4.0)
//                                            .background(Color.white)
//                                    }
//                                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomTrailing)
//                                }
//                            ).padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                    } // End of About group
                    Group {
                        VStack(alignment: .leading) {
                            Text("News").font(.system(size: 22)).padding(.top, 12).padding(.bottom, 4)
                            let newsCount = stockDetailViewModel.news.count
                            if newsCount > 0 {
                                let firstNews = stockDetailViewModel.news[0]
                                NewsCell(news: firstNews, isFirst: true).onTapGesture {
                                    guard let url = URL(string: firstNews.url) else { print("Invalid news url \(firstNews.url)"); return }
                                    UIApplication.shared.open(url)
                                }
                                Divider().padding(8)
                                ForEach(stockDetailViewModel.news[1..<newsCount], id: \.url) { news in
                                    NewsCell(news: news, isFirst: false).onTapGesture {
                                        guard let url = URL(string: news.url) else { print("Invalid news url \(news.url)"); return }
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }.padding(.leading, paddingAmount).padding(.trailing, paddingAmount)
                    } // End of News group
                } // End of VStack
            }.navigationTitle(stockDetailViewModel.stockDetails?.ticker ?? "Ticker")
                .navigationBarItems(trailing: Button(action: {
                    self.stockDetailViewModel.toggleFavorites()
                }, label: {
                    if stockDetailViewModel.isFavorited {
                        Image(systemName: "plus.circle.fill")
                    } else {
                        Image(systemName: "plus.circle")
                    }
                })).padding(.leading, 8).padding(.trailing, 8)
        }
    }
    
    func showTradeView() {
        showingTradeSheet = true
    }
    
    init(ticker: String) {
        self.ticker = ticker
        
        stockDetailViewModel.setTicker(ticker: ticker)
    }
    
}
