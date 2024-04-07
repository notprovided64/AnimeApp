import SwiftUI
import WebKit

struct PlayerWebView: UIViewRepresentable {
    var url: URL
    @ObservedObject var model: PlayerViewModel
    
    let nextAction: ()->Void
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: PlayerWebView
        
        init(_ parent: PlayerWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(enableRemotePlaybackScript)
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "ContentBlockingRules",
            encodedContentRuleList: blockRules) { (contentRuleList, error) in
                if error != nil {
                    print("failed to compile")
                    return
                }
                print("ruleList compiled")
                
                let js = """
                document.body.style.backgroundColor = 'black';
                """

                webView.configuration.userContentController.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
                webView.configuration.userContentController.add(contentRuleList!)
                webView.configuration.userContentController.add(ContentController(self), name: "callbackHandler")
                webView.configuration.allowsAirPlayForMediaPlayback = true
        }
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false

        model.webView = webView
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class ContentController: NSObject, WKScriptMessageHandler {
        var parent: PlayerWebView
        
        init(_ parent: PlayerWebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if(message.name == "callbackHandler") {
                if let callback = message.body as? String {
                    if callback == "next" {
                        parent.nextAction()
                    }
                    if callback == "done" {
                        parent.model.showWebview = true
                    }
                }
            }
        }
    }

}

class PlayerViewModel: ObservableObject {
    var webView: WKWebView? {
        @MainActor
        didSet {
            Task {
                self.loadingWebView = false
            }
        }
    }
    @Published var loadingWebView = true
    @Published var showWebview = false
}


struct PlayerWebView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerWebView(url: URL(string: "https://gogohd.net/streaming.php?id=Mzk3Mzc")!, model: PlayerViewModel(), nextAction: {} )
            .aspectRatio(16/9, contentMode: .fit)
    }
}

let blockRules = """
[
    {
        "trigger": {
            "url-filter": "https://gogohd.net"
        },
        "action": {
            "type": "css-display-none",
            "selector": "*[style*='z-index: 2147483647 !important']"
        }
    },
    {
        "trigger": {
            "url-filter": ".*"
        },
        "action": {
            "type": "css-display-none",
            "selector": "*[class^='pl-']"
        }
    },
    {
        "trigger": {
            "url-filter": "https://gogohd.net"
        },
        "action": {
            "type": "css-display-none",
            "selector": "a"
        }
    }
]
"""

let enableRemotePlaybackScript = """
let video = document.querySelector("video");

video.removeAttribute("disableremoteplayback");
video.removeAttribute("webkit-playsinline");
video.removeAttribute("playsinline");
video.removeAttribute("x-webkit-wirelessvideoplaybackdisabled");

jwplayer().on('complete', function() {
    window.webkit.messageHandlers.callbackHandler.postMessage("next");
});

//video.onended = function(e) {
//    window.webkit.messageHandlers.callbackHandler.postMessage("next");
//}
"""
