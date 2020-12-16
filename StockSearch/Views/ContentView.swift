//
//  ContentView.swift
//  StockSearch
//
//  Created by William Choi on 11/8/20.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var searchText: String = ""
    @State private var editMode = EditMode.inactive
    
    @ObservedObject var portfolioViewModel = PortfolioViewModel()
    @ObservedObject var searchBar: SearchBar = SearchBar()
            
    var body: some View {
        if self.portfolioViewModel.loading {
            NavigationView {
                VStack {
                    ProgressView().progressViewStyle(CircularProgressViewStyle()).padding(.top, -60)
                    Text("Fetching Data...").foregroundColor(.gray).padding(.top, -20)
                }
            }.navigationTitle(Text("Stocks")).onAppear(perform: { portfolioViewModel.getData() })
        } else {
            NavigationView {
                List {
                    if !searchBar.text.isEmpty {
                        ForEach(searchBar.autoCompleteList, id: \.ticker) { autoComplete in
                            NavigationLink(
                                destination: StockDetailView(ticker: autoComplete.ticker),
                                label: {
                                    AutoCompleteCell(autoComplete: autoComplete)
                                })
                        }
                    } else {
                        Text(Date(), style: .date).bold().foregroundColor(.gray).font(.system(size:24))
                        Section(header: Text("PORTFOLIO")) {
                            VStack(alignment: .leading) {
                                Text("Net Worth").font(.system(size:24))
                                let netWorthString = String(format: "%.2f", self.portfolioViewModel.netWorth)
                                Text("\(netWorthString)").bold().font(.system(size:24))
                            }
                            ForEach(portfolioViewModel.portfolio, id: \.ticker) { portfolioItem in
                                NavigationLink(
                                    destination: StockDetailView(ticker: portfolioItem.ticker),
                                    label: {
                                        StockCellView(stock: portfolioItem)
                                    })
                            }
                            .onDelete(perform: deletePortfolio)
                            .onMove(perform: movePortfolio)
                        }
                        Section(header: Text("FAVORITES")) {
                            ForEach(portfolioViewModel.favorites, id: \.ticker) { portfolioItem in
                                NavigationLink(
                                    destination: StockDetailView(ticker: portfolioItem.ticker),
                                    label: {
                                        StockCellView(stock: portfolioItem)
                                    })
                                }.onDelete(perform: deleteFavorite)
                            .onMove(perform: moveFavorites)
                        }
                        VStack {
                            Spacer()
                            HStack {
                                
                                Spacer()
                                Link("Powered by Tiingo", destination: URL(string: "https://www.tiingo.com")!).foregroundColor(.gray).font(.system(size:12))
                                Spacer()
                            }
                            Spacer()
                        }.onAppear(perform: { portfolioViewModel.getData() })
                    }
                }.navigationTitle(Text("Stocks")).add(self.searchBar).navigationBarItems(trailing: EditButton()).environment(\.editMode, $editMode).listStyle(PlainListStyle())
//                .onAppear(perform: { portfolioViewModel.getData() })
            }
        }
    }
    
    private func deleteFavorite(offsets: IndexSet) {
//        print("Deleting favorites item at \(offsets.startIndex)")
        portfolioViewModel.removeFavorite(index: offsets[offsets.startIndex])
    }
    
    private func deletePortfolio(offsets: IndexSet) {
        print("Deleting portfolio item at \(offsets)")
    }
    
    private func movePortfolio(source: IndexSet, destination: Int) {
        portfolioViewModel.movePortfolioItem(source: source, destination: destination)
    }
    
    private func moveFavorites(source: IndexSet, destination: Int) {
        portfolioViewModel.moveFavoritesItem(source: source, destination: destination)
    }
}
