//
//  HTTPNetworkError.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 09/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

// The enumeration defines possible errors to encounter during Network Request
public enum HTTPNetworkError: String, Error {

    case parametersNil
    case headersNil
    case encodingFailed
    case decodingFailed
    case missingURL
    case couldNotParse
    case noData
    case fragmentResponse
    case unwrappingError
    case dataTaskFailed
    case success
    case authenticationError
    case badRequest
    case resourceNotFound
    case failed
    case serverSideError
    case forbiddenError
}
//Sets the localized description (ensure you localize these strings before shipping)
extension HTTPNetworkError: LocalizedError {
    public var errorDescription: String? {
        let errorString = "🛑 Error Found:"
        switch self {
        case .parametersNil:
            return "\(errorString) Parameters are nil."
        case .headersNil:
            return "\(errorString) Headers are Nil"
        case .encodingFailed:
            return "\(errorString) Parameter Encoding failed."
        case .decodingFailed:
            return "\(errorString) Unable to Decode the data."
        case .missingURL:
            return "\(errorString) The URL is nil."
        case .couldNotParse:
            return "\(errorString) Unable to parse the JSON response."
        case .noData:
            return "\(errorString) The data from API is Nil."
        case .fragmentResponse:
            return "\(errorString) The API's response's body has fragments."
        case .unwrappingError:
            return "\(errorString) Unable to unwrap the data."
        case .dataTaskFailed:
            return "\(errorString) The Data Task object failed."
        case .success:
            return "✅ Successful Network Request"
        case .authenticationError:
            return "\(errorString) You must be Authenticated"
        case .badRequest:
            return "\(errorString) Bad Request"
        case .resourceNotFound:
            return "\(errorString) Resource requested not found."
        case .failed:
            return "\(errorString) Network Request failed"
        case .serverSideError:
            return "\(errorString) Server error"
        case .forbiddenError:
            return "\(errorString) You don't have permission to access this server."
        }
    }
}
