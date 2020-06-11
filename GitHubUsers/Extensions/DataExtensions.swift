//
//  DataExtensions.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

extension Data {
    func printJSONResponse() {
        //Just for test print purposes
        do {
            let resultObject = try JSONSerialization.jsonObject(with: self, options: [])
            print("✅ Results from request:\n\(resultObject)")
        } catch let err {
           print("🛑 Unable to parse JSON response: \(err.localizedDescription)")
        }
    }
}
