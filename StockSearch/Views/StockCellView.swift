//
//  StockCellView.swift
//  StockSearch
//
//  Created by William Choi on 11/17/20.
//

import Foundation
import SwiftUI

struct StockCellView: View {
    var stock: PortfolioItem
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text(stock.ticker).bold().font(.system(size:22))
                if !(stock.numShares == 0) {
                    Text(String(format: "%.2f", stock.numShares) + " Shares").foregroundColor(.gray)
                } else {
                    Text("\(stock.name)").foregroundColor(.gray)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(String(format: "%.2f", stock.price)).bold()
                if stock.change < 0 {
                    HStack {
                        Image(systemName: "arrow.down.right")
                        Text(String(format: "%.2f", stock.change))
                    }.foregroundColor(.red)
                } else if stock.change > 0 {
                    HStack {
                        Image(systemName: "arrow.up.right")
                        Text(String(format: "%.2f", stock.change))
                    }.foregroundColor(.green)
                } else {
                    Text(String(format: "%.2f", stock.change))
                }
                
            }
        }
    }
    
    init(stock: PortfolioItem) {
        self.stock = stock
    }
}

//#if DEBUG
//struct StockCellView_Previews: PreviewProvider {
//   static var previews: some View {
//      Group {
//        StockCellView(stock: Stock(ticker: "Ticker1", numShares: 2))
//            .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
//            .previewDisplayName("iPhone 11 Pro")
//      }
//   }
//}
//#endif
