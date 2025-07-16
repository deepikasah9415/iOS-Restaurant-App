import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(String)
}

class APIService {
    private let baseURL = "https://uat.onebanc.ai"
    private let apiKey = "uonebancservceemultrS3cg8RaL30"
    
    // MARK: - Fetch Cuisine List with Items
    func fetchItemList(page: Int = 1, count: Int = 50, completion: @escaping (Result<APIResponse, APIError>) -> Void) {
        let endpoint = "/emulator/interview/get_item_list"
        let requestBody: [String: Any] = [
            "page": page,
            "count": count
        ]
        
        makeRequest(endpoint: endpoint, action: "get_item_list", body: requestBody, responseType: APIResponse.self, completion: completion)
    }
    
    // MARK: - Fetch All Cuisines
    func fetchAllCuisines(completion: @escaping (Result<[CuisineResponse], APIError>) -> Void) {
        var allCuisines: [CuisineResponse] = []
        let dispatchGroup = DispatchGroup()
        var finalError: APIError?
        
        // First fetch with a large count to get as many as possible in one request
        dispatchGroup.enter()
        fetchItemList(page: 1, count: 100) { [weak self] result in
            switch result {
            case .success(let response):
                allCuisines.append(contentsOf: response.cuisines)
                
                // If there are more pages, fetch them too
                if response.totalPages > 1 && response.page < response.totalPages {
                    let remainingPages = min(response.totalPages, 10) // Limit to 10 pages to avoid excessive API calls
                    
                    // Keep track of IDs we've already seen
                    var seenIds = Set<String>(allCuisines.map { $0.cuisineId })
                    
                    for page in 2...remainingPages {
                        dispatchGroup.enter()
                        self?.fetchItemList(page: page, count: 100) { pageResult in
                            switch pageResult {
                            case .success(let pageResponse):
                                // Only add cuisines we haven't seen before
                                for cuisine in pageResponse.cuisines {
                                    if !seenIds.contains(cuisine.cuisineId) {
                                        allCuisines.append(cuisine)
                                        seenIds.insert(cuisine.cuisineId)
                                    }
                                }
                            case .failure(let error):
                                finalError = error
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            case .failure(let error):
                finalError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = finalError {
                completion(.failure(error))
            } else {
                completion(.success(allCuisines))
            }
        }
    }
    
    // MARK: - Fetch Item Details by ID
    func fetchItemDetails(itemId: String, completion: @escaping (Result<ItemDetailsResponse, APIError>) -> Void) {
        let endpoint = "/emulator/interview/get_item_by_id"
        let requestBody: [String: Any] = [
            "item_id": itemId
        ]
        
        makeRequest(endpoint: endpoint, action: "get_item_by_id", body: requestBody, responseType: ItemDetailsResponse.self, completion: completion)
    }
    
    // MARK: - Fetch Items by Filter
    func fetchItemsByFilter(cuisineType: [String]? = nil, priceRange: [String: Int]? = nil, minRating: Double? = nil, completion: @escaping (Result<FilterAPIResponse, APIError>) -> Void) {
        let endpoint = "/emulator/interview/get_item_by_filter"
        
        var requestBody: [String: Any] = [:]
        
        if let cuisineType = cuisineType {
            requestBody["cuisine_type"] = cuisineType
        }
        
        if let priceRange = priceRange {
            requestBody["price_range"] = priceRange
        }
        
        if let minRating = minRating {
            requestBody["min_rating"] = minRating
        }
        
        makeRequest(endpoint: endpoint, action: "get_item_by_filter", body: requestBody, responseType: FilterAPIResponse.self, completion: completion)
    }
    
    // MARK: - Make Payment
    func makePayment(requestPayload: MakePaymentRequest, completion: @escaping (Result<PaymentResponse, APIError>) -> Void) {
        let endpoint = "/emulator/interview/make_payment"
        // Directly use the new makeRequest<E: Encodable, T: Decodable> overload
        makeRequest(endpoint: endpoint, action: "make_payment", encodableBody: requestPayload, responseType: PaymentResponse.self, completion: completion)
    }
    
    // MARK: - Generic Request Method (Original with [String: Any])
    private func makeRequest<T: Decodable>(endpoint: String, action: String, body: [String: Any], responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Partner-API-Key")
        request.setValue(action, forHTTPHeaderField: "X-Forward-Proxy-Action")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("🚀 API Request: \(action) - Body: \(body)")
        } catch {
            print("❌ Failed to serialize request body: \(error)")
            completion(.failure(.requestFailed(error)))
            return
        }
        
        commonDataTaskLogic(request: request, action: action, responseType: responseType, completion: completion)
    }

    // MARK: - Generic Request Method (New with Encodable body)
    private func makeRequest<E: Encodable, T: Decodable>(endpoint: String, action: String, encodableBody: E, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Partner-API-Key")
        request.setValue(action, forHTTPHeaderField: "X-Forward-Proxy-Action")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(encodableBody)
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                 print("🚀 API Request (Encodable): \(action) - Body String: \(bodyString)")
            } else {
                 print("🚀 API Request (Encodable): \(action) - Body: Could not print body string")
            }
        } catch {
            print("❌ Failed to serialize Encodable request body: \(error)")
            completion(.failure(.requestFailed(error)))
            return
        }
        
        commonDataTaskLogic(request: request, action: action, responseType: responseType, completion: completion)
    }

    // Extracted common URLSession.dataTask logic
    private func commonDataTaskLogic<T: Decodable>(request: URLRequest, action: String, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response: Response is not HTTPURLResponse")
                completion(.failure(.invalidResponse))
                return
            }
            
            print("📡 API Response: \(action) - Status: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(.invalidResponse))
                return
            }
            
            // Try to print the response data as string for debugging
            if let responseStr = String(data: data, encoding: .utf8) {
                print("📦 Response data: \(responseStr.prefix(500))")
            }
            
            // Handle HTTP status codes
            if !(200...299).contains(httpResponse.statusCode) {
                // Try to decode error response if possible
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["response_message"] as? String {
                    print("❌ Server error: \(errorMessage)")
                    completion(.failure(.serverError(errorMessage)))
                } else {
                    print("❌ HTTP error: \(httpResponse.statusCode)")
                    completion(.failure(.serverError("Server returned status code \(httpResponse.statusCode)")))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                print("❌ Decoding error: \(error)")
                // Print more details about the decoding error
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value of type \(type) not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type \(type): \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }
} 