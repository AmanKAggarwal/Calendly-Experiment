//
//  CalendlyBooking.swift
//  ALUM
// This is a file used to store a dummy button for testing functionality of
// booking an event via calendly. Note that the majority of the code in here will be transferred to
// the profile view code once the PR has been updated
//
//  Created by Adhithya Ananthan on 4/12/23.
//

import Foundation
import SwiftUI
import WebKit

extension UIDevice {
    var modelName: String {
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        return identifier
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
        #endif
    }
}

struct CalendlyBooking: View  {
    @State public var showWebView = false
    public var urlString: String = "https://calendly.com/aananthanregina/30min"
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                showWebView.toggle()
                print("Button Pushed")
            }
            label: {
                Text("View My Calendly")
                .font(Font.custom("Metropolis-Regular", size: 17, relativeTo: .headline))
            }
            .sheet(isPresented: $showWebView) {
                CalendlyView(url: URL(string: urlString)!)
            }
            .frame(width: 358)
            .padding(.bottom, 26)
        }
    }
    
}

struct CalendlyView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
//        webViewConfiguration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.configuration.userContentController.add(context.coordinator, name: "myHandler")
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let htmlPath = Bundle.main.path(forResource: "index", ofType: "html")!
        let htmlUrl = URL(string: "http://localhost:8000/hello?link=https://calendly.com/akaggarw-1/30min?month=2023-04")!
        let request = URLRequest(url: htmlUrl)
        /*
        let request = URLRequest(url: url)
        uiView.load(request)
         */
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(webView: self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var webView: CalendlyView
        
        init(webView: CalendlyView) {
            self.webView = webView
        }
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                  if let domain = webView.url?.host {
                      print("Domain: \(domain)")
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let messageBody = message.body as? String {
                print("Received message: \(messageBody) - \(UIDevice.current.modelName)")
            }
        }
    }
}

struct CalendlyBooking_Previews: PreviewProvider {
    
    static var previews: some View {
        CalendlyBooking()
    }
}
