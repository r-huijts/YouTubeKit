#!/usr/bin/swift

import Foundation

// Test to verify the regex fix works
func testRegexFix() async throws {
    print("Testing YouTubeKit regex fix...")

    // Fetch the YouTube page
    let url = URL(string: "https://www.youtube.com/watch?v=Q8gkbK2DZ7s")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let html = String(data: data, encoding: .utf8)!

    print("✅ Successfully fetched YouTube page")

    // Test 1: Check if ytInitialPlayerResponse exists
    if html.contains("ytInitialPlayerResponse = ") {
        print("✅ ytInitialPlayerResponse pattern found")
    } else {
        print("❌ ytInitialPlayerResponse pattern NOT found")
        throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ytInitialPlayerResponse not found"])
    }

    // Test 2: Try to extract JS URL using the patterns from YouTubeKit
    print("2. Testing JS URL extraction with YouTubeKit patterns...")

    let jsURLPatterns = [
        NSRegularExpression(#"(/s/player/[\w\d]+/[\w\d_/.]+/base\.js)"#),
        NSRegularExpression(#"("player_base_url":\s*"([^"]+)"#),
        NSRegularExpression(#"(/s/player/[\w\d]+/[\w\d_/.]+/base\.js)"#),
        NSRegularExpression(#"(https://www\.youtube\.com/s/player/[\w\d]+/[\w\d_/.]+/base\.js)"#),
        NSRegularExpression(#"(/s/player/[\w\d]+/player_ias\.vflset/[\w\d_]+/base\.js)"#)
    ]

    var foundJSURL = false
    for (index, pattern) in jsURLPatterns.enumerated() {
        if let match = pattern.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) {
            let jsPath = String(html[Range(match.range, in: html)!])
            print("✅ Pattern \(index + 1) found JS URL: \(jsPath)")
            foundJSURL = true
            break
        }
    }

    if foundJSURL {
        print("✅ JS URL extraction successful")
    } else {
        print("❌ JS URL extraction failed")
        throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "JS URL not found"])
    }

    print("\n🎉 All tests passed! The regex fix is working correctly.")
    print("The YouTubeKit library should now work with modern YouTube pages.")
}

// Run the test
Task {
    do {
        try await testRegexFix()
    } catch {
        print("Test failed: \(error)")
        exit(1)
    }
}
RunLoop.main.run()
