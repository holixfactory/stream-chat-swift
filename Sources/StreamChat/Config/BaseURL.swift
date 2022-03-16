//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation

/// A struct representing base URL for `ChatClient`.
public struct BaseURL: CustomStringConvertible {
    /// The base url for StreamChat data center located in the US East Cost.
    public static let usEast = BaseURL(urlString: "https://chat-proxy-us-east.stream-io-api.com/")!
    
    /// The base url for StreamChat data center located in Dublin.
    public static let dublin = BaseURL(urlString: "https://chat-proxy-dublin.stream-io-api.com/")!
    
    /// The base url for StreamChat data center located in Singapore.
    public static let singapore = BaseURL(urlString: "https://chat-proxy-singapore.stream-io-api.com/")!
    
    /// The base url for StreamChat data center located in Sydney.
    public static let sydney = BaseURL(urlString: "https://chat-proxy-sydney.stream-io-api.com/")!
    
    let restAPIBaseURL: URL
    let webSocketBaseURL: URL
    
    public var description: String { restAPIBaseURL.absoluteString }
    
    /// Create a base URL from an URL string.
    ///
    /// - Parameter urlString: a Stream Chat server location url string.
    init?(urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.init(url: url)
    }
    
    /// Init with a custom server URL.
    ///
    /// - Parameter url: an URL
    public init(url: URL) {
        var urlString = url.absoluteString
        
        // Remove a scheme prefix.
        for prefix in ["https:", "http:", "wss:", "ws:"] {
            if urlString.hasPrefix(prefix) {
                urlString = String(urlString.suffix(urlString.count - prefix.count))
                break
            }
        }
        
        urlString = urlString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("USE_MOCK_SERVER") {
            let env = ProcessInfo.processInfo.environment
            let httpHost = env["MOCK_SERVER_HTTP_HOST"] ?? "https://\(urlString)/"
            let websocketHost = env["MOCK_SERVER_WEBSOCKET_HOST"] ?? "wss://\(urlString)/"
            let port = env["MOCK_SERVER_PORT"] ?? "443"
            restAPIBaseURL = URL(string: "\(httpHost):\(port)/")!
            webSocketBaseURL = URL(string: "\(websocketHost):\(port)/")!
            return
        }
        #endif
        
        restAPIBaseURL = URL(string: "https://\(urlString)/")!
        webSocketBaseURL = URL(string: "wss://\(urlString)/")!
    }
}
