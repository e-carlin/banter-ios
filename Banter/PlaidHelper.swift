//
//  PlaidHelper.swift
//  Banter
//
//  Created by e-carlin on 1/16/18.
//  Copyright © 2018 Banter. All rights reserved.
//

import Foundation

public struct PlaidHelper {
    internal static let plaidBaseURLAsString = "http://127.0.0.1:5000"
    
    public static func exchangePublicKey(publicToken: String, metadata: [String : Any]?) {
        let exchangePublicTokenEndpoint = "exchange_plaid_public_token"
        //Make call to my API
        guard let exchangePublicTokenURL = URL(string: "\(plaidBaseURLAsString)/\(exchangePublicTokenEndpoint)") else {
            NSLog("Error creating exchangePublicTokenURL")
            return
        }
        var request = URLRequest(url: exchangePublicTokenURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        var bodyAsDict : [String : Any]
        if let metadataValue = metadata {
            bodyAsDict = ["public_token" : publicToken, "metadata" : metadataValue]
        }
        else {
            bodyAsDict = ["public_token" : publicToken]
        }
        
        do {
            
            let bodyAsJSON = try JSONSerialization.data(withJSONObject: bodyAsDict, options: [])
            request.httpBody = bodyAsJSON
            let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                if let error = error {
                    NSLog("There was an error calling the exchange public token API: \(error)")
                    return
                }
                if let res = response {
                    NSLog("Success exchanging public token: \(res)")
                }
            })
            task.resume()
        }
        catch {
            NSLog("Error: There was an error building the exchange public token api call body JSON")
        }
    }
}
