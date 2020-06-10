//
//  SearchUsersService.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct SearchUsersService {

    static let shared = SearchUsersService()
    let session = URLSession(configuration: .default)

    func getUsers(_ parameters: [String: Any], completion: @escaping (Result<APIResponseSearchUsers>) -> Void) {

        let baseURL = "https://api.github.com" //Usually set in an Environment Object

        let headers = HTTPHeaders([
            "Accept": "application/json",
            "Content-Type": "application/json"])

        do {
            let request = try HTTPNetworkRequest.configureHTTPRequest(baseURL: baseURL,
                                                                      from: .search,
                                                                      with: parameters,
                                                                      includes: headers,
                                                                      contains: nil,
                                                                      and: .get)

            print("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
            print("😀 HEADERS: \(String(describing: headers))")

            session.dataTask(with: request) { (data, res, err) in

                if let response = res as? HTTPURLResponse, let unwrappedData = data {

                    let paginationNextPage = self.getNextPageFromHeaders(response: response)

                    let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                    switch result {

                    case .success:

                        do {
                            var jsonResult = try JSONDecoder().decode(APIResponseSearchUsers.self, from: unwrappedData)
                            jsonResult.nextPage = paginationNextPage

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

    // MARK: - Pagination Parse of Links fom Header Response
    private func getNextPageFromHeaders(response: HTTPURLResponse?) -> Int? {

        var nextPageInt: Int?
        if let linkHeader = response?.allHeaderFields["Link"] as? String {
            let links = linkHeader.components(separatedBy: ",")

            var dictionary: [String: String] = [:]
            links.forEach({
                let components = $0.components(separatedBy:"; ")
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
