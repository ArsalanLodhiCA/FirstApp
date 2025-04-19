//
//  APIService.swift
//  FirstApp
//
//  Created by Arsalan Lodhi on 4/17/25.
//
import Foundation

class APIService {
    static let shared = APIService()
    
    func askAI(question: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/ask") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["question": question]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // optional printing for debugging what JSON going to server
        if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Sending JSON to server:\n\(jsonString)")
        }

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // 🔍 Log network error if there is one
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                }

                // 🔍 Log HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Status code: \(httpResponse.statusCode)")
                }

                // 🔍 Log raw response body
                if let data = data {
                    print("📥 Raw response:")
                    print(String(data: data, encoding: .utf8) ?? "Unable to decode as UTF-8")
                }
            
            
            
            guard let data = data,
                  let result = try? JSONDecoder().decode(AIResponse.self, from: data) else {
                DispatchQueue.main.async {
                    completion("Sorry, there was an error.")
                }
                return
            }
            DispatchQueue.main.async {
                completion(result.answer)
            }
        }.resume()
    }
}

struct AIResponse: Codable {
    let answer: String
}

