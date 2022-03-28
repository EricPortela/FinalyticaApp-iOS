//
//  APIKey.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-26.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation


public var apiKey: String {
  get {
    // 1
    guard let filePath = Bundle.main.path(forResource: "FMP-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'FMP-Info.plist'.")
    }
    // 2
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'FMP-Info.plist'.")
    }
    // 3
    if (value.starts(with: "_")) {
      fatalError("Register for a FMP developer account and get an API key at https://site.financialmodelingprep.com.")
    }
    return value
  }
}
