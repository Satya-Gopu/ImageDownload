//
//  NetworkResponse.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import Foundation

// MARK: - NetworkResponse

// Model object representing a network response. Reflects both error and success conditions
struct NetworkResponse {
    
    // Properties
    var errorMessage: String?
    var data: [ImageData]?
}
