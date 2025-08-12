import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    // For iOS Simulator, use localhost instead of 10.0.2.2 (which is Android emulator specific)
    var baseURL: URL = URL(string: "http://localhost:8000/api/")!  // For iOS Simulator
    // var baseURL: URL = URL(string: "http://192.168.1.100:8000/api/")!  // For physical device (replace with your IP)

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()

    // Test network connectivity
    func testConnection() async -> Bool {
        do {
            // First, test basic connectivity to the base URL
            let baseTestURL = baseURL
            var baseRequest = URLRequest(url: baseTestURL)
            baseRequest.httpMethod = "GET"
            baseRequest.timeoutInterval = 10
            
            print("🧪 Testing basic connectivity to: \(baseTestURL.absoluteString)")
            
            let (baseData, baseResponse) = try await session.data(for: baseRequest)
            if let httpResponse = baseResponse as? HTTPURLResponse {
                print("✅ Basic connectivity successful: \(httpResponse.statusCode)")
                if let responseString = String(data: baseData, encoding: .utf8) {
                    print("📄 Base response: \(responseString)")
                }
            }
            
            // Now test with a specific endpoint
            let testURL = baseURL.appendingPathComponent("notes/")
            var request = URLRequest(url: testURL)
            request.httpMethod = "GET"
            request.timeoutInterval = 10
            
            print("🧪 Testing endpoint: \(testURL.absoluteString)")
            
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Endpoint test successful: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Endpoint response: \(responseString)")
                }
                return true
            }
            return false
        } catch {
            print("❌ Connection test failed: \(error)")
            if let urlError = error as? URLError {
                print("🔍 URL Error code: \(urlError.code.rawValue)")
                print("🔍 URL Error description: \(urlError.localizedDescription)")
            }
            return false
        }
    }

    private func isTokenExpiringSoon() -> Bool {
        guard let data = KeychainManager.shared.get(TokenKeys.expiry),
              let str = String(data: data, encoding: .utf8),
              let expiryMs = Double(str) else { return false }
        let buffer: Double = 5 * 60 * 1000 // 5 min
        return Date().timeIntervalSince1970 * 1000 >= (expiryMs - buffer)
    }

    func perform<T: Decodable>(_ request: URLRequest, decode: T.Type) async throws -> T {
        print("🌐 Network request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        print("🔍 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Request body: \(bodyString)")
        }
        
        // Refresh token if expiring
        if isTokenExpiringSoon() {
            try? await AuthService.shared.refreshTokenIfPossible()
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { 
                print("❌ Invalid response type")
                throw URLError(.badServerResponse) 
            }
            
            print("📡 Response status: \(http.statusCode)")
            print("📡 Response headers: \(http.allHeaderFields)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Response body: \(responseString)")
            }

            // If unauthorized, attempt one refresh and retry
            if http.statusCode == 401 {
                print("🔄 Token expired, attempting refresh...")
                try await AuthService.shared.refreshTokenIfPossible()
                var retry = request
                if let token = AuthService.shared.currentAccessToken() {
                    retry.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                let (data2, response2) = try await session.data(for: retry)
                guard let http2 = response2 as? HTTPURLResponse else { throw URLError(.badServerResponse) }
                guard (200..<300).contains(http2.statusCode) else {
                    throw try JSONDecoder().decode(APIErrorResponse.self, from: data2)
                }
                return try JSONDecoder().decode(T.self, from: data2)
            }

            guard (200..<300).contains(http.statusCode) else {
                if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) { 
                    print("❌ API Error: \(apiError.detail)")
                    throw apiError 
                }
                print("❌ HTTP Error: \(http.statusCode)")
                throw URLError(.badServerResponse)
            }

            print("✅ Request successful")
            
            // Try to decode the response
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                print("✅ Response decoded successfully")
                return decoded
            } catch {
                print("❌ Failed to decode response: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Raw response that failed to decode: \(responseString)")
                }
                throw error
            }
        } catch {
            print("❌ Network error: \(error)")
            if let urlError = error as? URLError {
                print("🔍 URL Error code: \(urlError.code.rawValue)")
                print("🔍 URL Error description: \(urlError.localizedDescription)")
            }
            throw error
        }
    }

    func performNoContent(_ request: URLRequest) async throws {
        print("🌐 Network request (no content): \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown")")
        
        // Refresh if needed
        if isTokenExpiringSoon() { try? await AuthService.shared.refreshTokenIfPossible() }
        
        do {
            let (_, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
            
            print("📡 Response status: \(http.statusCode)")
            
            if http.statusCode == 401 {
                try await AuthService.shared.refreshTokenIfPossible()
                _ = try await session.data(for: request)
                return
            }
            guard (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
            
            print("✅ Request successful")
        } catch {
            print("❌ Network error: \(error)")
            if let urlError = error as? URLError {
                print("🔍 URL Error code: \(urlError.code.rawValue)")
                print("🔍 URL Error description: \(urlError.localizedDescription)")
            }
            throw error
        }
    }
}

extension URLRequest {
    static func authorized(path: String, method: String = "GET", body: Data? = nil) -> URLRequest {
        let url = NetworkManager.shared.baseURL.appendingPathComponent(path)
        print("🔗 Constructed URL: \(url.absoluteString)")
        print("🔗 Base URL: \(NetworkManager.shared.baseURL.absoluteString)")
        print("🔗 Path component: \(path)")
        print("🔗 Final URL: \(url.absoluteString)")
        
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthService.shared.currentAccessToken() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }
}


