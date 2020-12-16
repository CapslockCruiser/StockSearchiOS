//
//  WebView.swift
//  StockSearch
//
//  Created by William Choi on 11/21/20.
//

// https://developer.apple.com/forums/thread/126986

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var title: String
    var ticker: String
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil

    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self, ticker: ticker)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.loadFileURL(url, allowingReadAccessTo: url)
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // you can access environment via context.environment here
        // Note that this method will be called A LOT
    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        let ticker: String

        init(_ parent: WebView, ticker: String) {
            self.parent = parent
            self.ticker = ticker
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.title = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
            webView.evaluateJavaScript("getData(\"\(ticker)\")", completionHandler: nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

struct Highstocks: View {
    @State var title: String = "High Stocks"
    @State var error: Error? = nil
    var ticker: String
    
    let url = Bundle.main.url(forResource: "highcharts", withExtension: "html")!
//    print(url)

    var body: some View {
        WebView(title: $title, ticker: ticker, url: url)
            .onLoadStatusChanged { loading, error in
                if loading {
//                    print("Loading started")
//                    print("Ticker is \(ticker)")
                    self.title = "Loading…"
                }
                else {
//                    print("Done loading.")
                    if let error = error {
                        self.error = error
                        if self.title.isEmpty {
                            self.title = "Error"
                        }
                    }
                    else if self.title.isEmpty {
                        self.title = "Some Place"
                    }
                }
        }
    }
}

//struct WebView_Previews: PreviewProvider {
//    static var previews: some View {
//        Display()
//    }
//}
