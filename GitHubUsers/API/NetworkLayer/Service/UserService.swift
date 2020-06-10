//
//  UserService.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct UserService {

    static let shared = UserService()
    let session = URLSession(configuration: .default)

    func getUser(_ userName: String, completion: @escaping (Result<APIResponseUser>) -> Void) {
        let baseURL = "https://api.github.com" //Usually set in an Environment Object

        let headers = HTTPHeaders([
            "Accept": "application/json",
            "Content-Type": "application/json"])

        do {
            let request = try HTTPNetworkRequest.configureHTTPRequest(userName,
                                                                      baseURL: baseURL,
                                                                      from: .user,
                                                                      with: nil,
                                                                      includes: headers,
                                                                      contains: nil,
                                                                      and: .get)

            print("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
            print("😀 HEADERS: \(String(describing: headers))")

            session.dataTask(with: request) { (data, res, err) in

                if let response = res as? HTTPURLResponse, let unwrappedData = data {

                    let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                    switch result {

                    case .success:

                        do {
                            let jsonResult = try JSONDecoder().decode(APIResponseUser.self, from: unwrappedData)
                            completion(Result.success(jsonResult))
                        } catch let err {
                            print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                            completion(Result.failure(err))
                        }

                         //Print Response

                         /*
                         print("✅ HEADER RESPONSE: \(response)")
                         print("✅ Response for: \(request.url?.absoluteString)")
                         unwrappedData.printJSONResponse()
                         */

                    case .failure(let err):
                        print("🛑 FAILED: \(result) error:\(err)")
                        completion(Result.failure(err))
                    }
                }

                if let err = err {
                    print("🛑 ERROR: \(err.localizedDescription)")
                    completion(Result.failure(err))
                }

                }.resume()
        } catch let err {

            completion(Result.failure(err))
        }
    }
}
