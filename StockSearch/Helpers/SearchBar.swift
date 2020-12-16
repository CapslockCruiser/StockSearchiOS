//
//  SearchBar.swift
//  SwiftUI_Search_Bar_in_Navigation_Bar
//
//  Created by Geri Borbás on 2020. 04. 27..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//
import SwiftUI
import Combine

class SearchBar: NSObject, ObservableObject {
    
    @Published var text: String = ""
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    var autoCompleteManager: AutoCompleteManager
//    let objectWillChange = ObservableObjectPublisher()
    
    @Published var autoCompleteList: [AutoComplete] = []
    
    override init() {
        self.autoCompleteManager = AutoCompleteManager()
        super.init()
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
    }
}

extension SearchBar: UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        
        // Publish search bar text changes.
        let debouncer = Debouncer(delay: 0.5)
        
        debouncer.run { [weak self] in
            guard let strongSelf = self else { assertionFailure(); return }
            if let searchBarText = searchController.searchBar.text {
                strongSelf.text = searchBarText
                
                if strongSelf.text.count > 2 {
                    strongSelf.autoCompleteManager.getMatchedStocks(searchTerm: strongSelf.text) { acList in
                        DispatchQueue.main.async {
                            strongSelf.autoCompleteList = acList
                            strongSelf.objectWillChange.send()
                        }
                    }
                } else {
                    strongSelf.autoCompleteList = []
                    strongSelf.objectWillChange.send()
                }
            }
        }
    }
}

struct SearchBarModifier: ViewModifier {
    
    let searchBar: SearchBar
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver { viewController in
                    viewController.navigationItem.searchController = self.searchBar.searchController
                }
                    .frame(width: 0, height: 0)
            )
    }
}

extension View {
    
    func add(_ searchBar: SearchBar) -> some View {
        return self.modifier(SearchBarModifier(searchBar: searchBar))
    }
}
