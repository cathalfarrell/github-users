//
//  SearchUsersService.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation
import Alamofire

let baseURL = "https://api.github.com/"

struct SearchUsersService {

    static let shared = SearchUsersService()
    let session = URLSession(configuration: .default)

    func getUsers(_ parameters: [String: Any], completion: @escaping (Result<APIResponseSearchUsers>) -> Void) {

        AF.request("\(baseURL)search/users",
            parameters: parameters,
            encoding: URLEncoding.queryString).responseJSON { (response) in

            /*
            print(response.request)   // original url request
            print(response.response) // http url response
            print(response.result)  // response serialization result
            */

            let result = HTTPNetworkResponse.handleNetworkResponse(for: response.response)
            let paginationNextPage = self.getNextPageFromHeaders(response: response.response)

            switch result {

            case .success:

                if let unwrappedData = response.data {
                    do {
                        var jsonResult = try JSONDecoder().decode(APIResponseSearchUsers.self, from: unwrappedData)
                        jsonResult.nextPage = paginationNextPage

                        completion(Result.success(jsonResult))
                    } catch let err {
                        print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                        completion(Result.failure(err))
                    }
                }
            case .failure(let err):
                print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                completion(Result.failure(err))
            }
        }
    }

    // MARK: - Pagination Parse of Links fom Header Response
    private func getNextPageFromHeaders(response: HTTPURLResponse?) -> Int? {

        var nextPageInt: Int?
        if let linkHeader = response?.allHeaderFields["Link"] as? String {
            let links = linkHeader.components(separatedBy: ",")

            var dictionary: [String: String] = [:]
            links.forEach({
                let components = $0.components(separatedBy: "; ")
                let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                dictionary[components[1]] = cleanPath
            })

            if let nextPagePath = dictionary["rel=\"next\""] {
                let cleanPath = nextPagePath.trimmingCharacters(in: CharacterSet(charactersIn: "< >"))
                nextPageInt = getNextPageNumber(from: cleanPath)
            }

        }
        return nextPageInt
    }

    func getNextPageNumber(from link: String?) -> Int? {
        guard let linkUrl = link, let url = URL(string: linkUrl) else {
            return nil
        }

        var pageNumber: Int?
        let urlParameters = url.params
        if let pageValue = urlParameters?["page"] {
            pageNumber = Int(pageValue)
        }

        return pageNumber
    }
}
