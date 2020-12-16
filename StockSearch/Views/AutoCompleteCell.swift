//
//  AutoCompleteCell.swift
//  StockSearch
//
//  Created by William Choi on 11/19/20.
//

import SwiftUI

struct AutoCompleteCell: View {
    var autoComplete: AutoComplete
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(autoComplete.ticker).bold().font(.system(size:22))
            Text(autoComplete.name).foregroundColor(.gray)
        }
    }
}

//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//   static var previews: some View {
//      Group {
//        AutoCompleteCell(name: "Here", ticker: "Ticker 1")
//      }
//   }
//}
//#endif
