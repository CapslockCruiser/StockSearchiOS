//
//  NewsCell.swift
//  StockSearch
//
//  Created by William Choi on 11/30/20.
//

import SwiftUI

struct NewsCell: View {
    
    var news: News
    var isFirst: Bool
    let imageSize: CGFloat = 80
    @State private var image: Image = Image("SplashScreenImage")
    @State private var timeElapsed: String = "Some time"
    
    var body: some View {
        
        if isFirst {
            ZStack {
                Color(.white)
//                RoundedRectangle(cornerRadius: 6.0).background(Color.white)
                VStack(alignment: .leading) {
                    image.resizable().aspectRatio(contentMode: .fill).contentShape(Rectangle()).cornerRadius(6.0)
                    Text("\(news.source.name)   \(timeElapsed)").foregroundColor(.gray).font(.system(size: 12))
                    Text(news.title).bold().font(.system(size: 14)).lineLimit(nil).fixedSize(horizontal: false, vertical: true)
                }
            }.cornerRadius(6.0).contextMenu(ContextMenu(menuItems: {
                Button(action: {
                    guard let url = URL(string: news.url) else { print("Invalid news url \(news.url)"); return }
                    UIApplication.shared.open(url)
                }, label: {
                    Label(
                        title: { Text("Open in Safari") },
                        icon: { Image(systemName: "safari") }
                    )
                })
                Button(action: {
                    let titleText = "Check%20out%20this%20link:"
//                    let titleText = news.title.filter { !$0.isWhitespace }
                    let urlString = "https://twitter.com/intent/tweet?text=\(titleText)&url=\(news.url)&hashtags=CSCI571StockApp"
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    } else {
                        print("Couldn't parse \(urlString)")
                    }
                }, label: {
                    Label(
                        title: { Text("Shared on Twitter") },
                        icon: { Image(systemName: "square.and.arrow.up") }
                    )
                })
                })).onAppear(perform: {
                    APIManager.shared.getImage(urlToImage: news.urlToImage) {
                        self.image = $0
                        self.timeElapsed = getTimeSinceText(originTime: news.publishedAt)
                    }
            })
//              ZStack {
//                Color(.white)
//                VStack(alignment: .leading) {
//                    image.resizable().aspectRatio(contentMode: .fill).contentShape(Rectangle()).cornerRadius(6.0)
//                    Text("\(news.source.name)   \(timeElapsed)").foregroundColor(.gray).font(.system(size: 12))
//                    Text(news.title).bold().font(.system(size: 14))
//                }.contextMenu(ContextMenu(menuItems: {
//                    Button(action: {
//                        guard let url = URL(string: news.url) else { print("Invalid news url \(news.url)"); return }
//                        UIApplication.shared.open(url)
//                    }, label: {
//                        Label(
//                            title: { Text("Open in Safari") },
//                            icon: { Image(systemName: "safari") }
//                        )
//                    })
//                    Button(action: {
//                        let titleText = "Check%20out%20this%20link:%20\(news.url)%20#CSCI571StockApp"
//    //                    let titleText = news.title.filter { !$0.isWhitespace }
//                        let urlString = "https://twitter.com/intent/tweet?text=\(titleText)&url=\(news.url)"
//                        if let url = URL(string: urlString) {
//                            UIApplication.shared.open(url)
//                        } else {
//                            print("Couldn't parse \(urlString)")
//                        }
//                    }, label: {
//                        Label(
//                            title: { Text("Shared on Twitter") },
//                            icon: { Image(systemName: "square.and.arrow.up") }
//                        )
//                    })
//                    })).onAppear(perform: {
//                        APIManager.shared.getImage(urlToImage: news.urlToImage) {
//                            self.image = $0
//                            self.timeElapsed = getTimeSinceText(originTime: news.publishedAt)
//                            print(news.publishedAt)
//                        }
//                })
//            }
        } else {
            ZStack {
                Color(.white)
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(news.source.name)   \(timeElapsed)").foregroundColor(.gray).font(.system(size: 12))
                        Text(news.title).bold().font(.system(size: 14)).lineLimit(4)
                        Spacer()
                    }
                    Spacer()
                    image.resizable().scaledToFill().frame(width: imageSize, height: imageSize, alignment: .center).contentShape(Rectangle()).cornerRadius(6.0)
                }
            }.cornerRadius(6.0).contextMenu(ContextMenu(menuItems: {
                Button(action: {
                    guard let url = URL(string: news.url) else { print("Invalid news url \(news.url)"); return }
                    UIApplication.shared.open(url)
                }, label: {
                    Label(
                        title: { Text("Open in Safari") },
                        icon: { Image(systemName: "safari") }
                    )
                })
                Button(action: {
                    let titleText = "Check%20out%20this%20link:"
//                    let titleText = news.title.filter { !$0.isWhitespace }
                    let urlString = "https://twitter.com/intent/tweet?text=\(titleText)&url=\(news.url)&hashtags=CSCI571StockApp"
                    if let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    } else {
                        print("Couldn't parse \(urlString)")
                    }
                }, label: {
                    Label(
                        title: { Text("Shared on Twitter") },
                        icon: { Image(systemName: "square.and.arrow.up") }
                    )
                })
                })).onAppear(perform: {
                    APIManager.shared.getImage(urlToImage: news.urlToImage) {
                        self.image = $0
                        self.timeElapsed = getTimeSinceText(originTime: news.publishedAt)
                    }
            })
        }
    }
}

func getTimeSinceText(originTime: String) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    guard let originDate = dateFormatter.date(from: originTime) else {
        return ""
    }
    
    let elapsedTime = Date().timeIntervalSince(originDate)
    
    if elapsedTime < 3600 {
        return "\(Int(elapsedTime / 60)) minutes ago"
    } else if 3601 < elapsedTime && elapsedTime < 86400 {
        return "\(Int(elapsedTime / 3600)) hours ago"
    } else {
        return "\(Int(elapsedTime / 86400)) days ago"
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
