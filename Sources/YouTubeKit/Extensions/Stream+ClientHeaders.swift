//
//  Stream+ClientHeaders.swift
//  YouTubeKit
//
//  Created for client context tracking
//

import Foundation

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public extension Stream {
    
    /// Get the complete set of headers needed for playback authentication
    var playbackHeaders: [String: String] {
        guard let client = extractionClient else {
            return [:]
        }
        
        var headers = client.headers
        
        // Add common headers for all clients
        headers["Accept"] = "*/*"
        headers["Accept-Language"] = "en-US,en;q=0.9"
        headers["Accept-Encoding"] = "gzip, deflate"
        headers["Connection"] = "keep-alive"
        
        // Add client-specific security headers
        switch client {
        case .web, .webEmbed, .webSafari:
            headers["Origin"] = "https://www.youtube.com"
            headers["Referer"] = "https://www.youtube.com/"
            headers["Sec-Fetch-Site"] = "same-origin"
            headers["Sec-Fetch-Mode"] = "cors"
            headers["Sec-Fetch-Dest"] = "empty"
            
        case .ios, .iosMusic:
            headers["Accept-Encoding"] = "gzip, deflate, br"
            
        default:
            break
        }
        
        return headers
    }
    
    /// Get a description of which client extracted this stream
    var clientDescription: String {
        guard let client = extractionClient else {
            return "Remote/Unknown"
        }
        
        let info = client.clientInfo
        return "\(info.name) v\(info.version) (ID: \(info.internalID))"
    }
    
    /// Whether this stream requires client-specific headers for playback
    var requiresClientHeaders: Bool {
        return extractionClient != nil
    }
    
    /// Get the extraction client name as a string
    var clientName: String {
        return extractionClient?.rawValue ?? "unknown"
    }
}
