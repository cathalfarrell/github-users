//
//  UserService.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation
import Alamofire

struct UserService {

    static let shared = UserService()
    let session = URLSession(configuration: .default)

    func getUser(_ userName: String, completion: @escaping (Result<APIResponseUser>) -> Void) {

        let requestPath = "\(baseURL)users/\(userName)"
        print("😀 Requesting Path: \(requestPath)")

        AF.request(requestPath).responseJSON { (response) in

            /*
            print(response.request)   // original url request
            print(response.response) // http url response
            print(response.result)  // response serialization result
            */

            let result = HTTPNetworkResponse.handleNetworkResponse(for: response.response)

            switch result {

            case .success:

                if let unwrappedData = response.data {
                    do {
                        let jsonResult = try JSONDecoder().decode(APIResponseUser.self, from: unwrappedData)
                        completion(Result.success(jsonResult))
                    } catch let err {
                        print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                        completion(Result.failure(err))
                    }
                }
            case .failure(let err):
                print("🛑 FAILED: \(result) error:\(err)")
                completion(Result.failure(err))
            }
        }
    }
}
