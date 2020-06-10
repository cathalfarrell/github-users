//
//  HTTPNetworkRequest.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

public typealias HTTPParameters = [String: Any]?
public typealias HTTPHeaders = [String: Any]?

struct HTTPNetworkRequest {

    /// Set the body, method, headers, and paramaters of the request
    static func configureHTTPRequest(_ identifier: String = "", baseURL: String = "", from route: HTTPNetworkRoute,
                                     with parameters: HTTPParameters, includes headers: HTTPHeaders,
                                     contains body: Data?, and method: HTTPMethod) throws -> URLRequest {

        var requestURL = "\(baseURL)/\(route.rawValue)"
        requestURL = requestURL.replacingOccurrences(of: ":id", with: identifier)
        print("😀 RequestURL: \(requestURL)")
        guard let url = URL(string: requestURL) else { throw HTTPNetworkError.missingURL}

        /*
         *** NOTES ABOUT REQUEST ***
         
         * You can use the simple initializer if you'd like:
            var request = URLRequest(url: url)
         * The timeoutInterval argument tells URLSession the amount of time(in seconds)
         * to wait for a response from the server
         * When Making a GET request, we don't pass anything in the body
         * You can cmd+click on each method and parameter to learn more about them.
        */

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)

        request.httpMethod = method.rawValue
        request.httpBody = body
        try configureParametersAndHeaders(parameters: parameters, headers: headers, request: &request)

        return request
    }

    /// Configure the request parameters and headers before the API Call
    static func configureParametersAndHeaders(parameters: HTTPParameters?,
                                              headers: HTTPHeaders?,
                                              request: inout URLRequest) throws {

        do {

            if let headers = headers, let parameters = parameters {
                try URLEncoder.encodeParameters(for: &request, with: parameters)
                try URLEncoder.setHeaders(for: &request, with: headers)
            }
        } catch {
            throw HTTPNetworkError.encodingFailed
        }
    }
}
