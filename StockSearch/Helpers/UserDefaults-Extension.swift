////
////  UserDefaults-Extension.swift
////  StockSearch
////
////  Created by William Choi on 12/2/20.
////
////https://elmland.blog/2018/12/17/save-load-structs-userdefaults/
//
//import Foundation
//
//extension UserDefaults {
//    open func setStruct<T: Codable>(_ value: T?, forKey defaultName: String){
//        let data = try? JSONEncoder().encode(value)
//        set(data, forKey: defaultName)
//    }
//    
//    open func structData<T>(_ type: T.Type, forKey defaultName: String) -> T? where T : Decodable {
//        guard let encodedData = data(forKey: defaultName) else {
//            return nil
//        }
//        
//        return try! JSONDecoder().decode(type, from: encodedData)
//    }
//    
//    open func setStructArray<T: Codable>(_ value: [T], forKey defaultName: String){
//        let data = value.map { try? JSONEncoder().encode($0) }
//        
//        set(data, forKey: defaultName)
//    }
//    
//    open func structArrayData<T>(_ type: T.Type, forKey defaultName: String) -> [T] where T : Decodable {
//        guard let encodedData = array(forKey: defaultName) as? [Data] else {
//            return []
//        }
//        
//        return encodedData.map { try! JSONDecoder().decode(type, from: $0) }
//    }
//}
//
////// Example
////struct Pizza: Codable {
////    let name: String
////    let price: Double
////}
////
////// struct array exmaple
////let allPizzasKey = "ALL_PIZZAS"
////UserDefaults.standard.setStructArray([Pizza(name: "Seafood", price: 6.00), Pizza(name: "Crudo", price: 5.50), Pizza(name: "Margherita", price: 3.50)], forKey: allPizzasKey)
////let pizzas: [Pizza] = UserDefaults.standard.structArrayData(Pizza.self, forKey: allPizzasKey)
////print("All pizzas: \(pizzas)")
////
////// struct exampl
////let myFavPizzaKey = "MY_FAV_PIZZA"
////UserDefaults.standard.setStruct(Pizza(name: "Seafood", price: 6.00), forKey: myFavPizzaKey)
////if let myFavPizza = UserDefaults.standard.structData(Pizza.self, forKey: myFavPizzaKey) {
////    print("My fav pizza: \(myFavPizza)")
////}
