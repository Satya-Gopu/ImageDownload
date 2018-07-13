//
//  ImageData.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import Foundation

// MARK: - ImageData

// MARK: Model object representing imagedata
struct ImageData {
    
    // MARK: Private
    var imageURL: URL?
    var imageData: Data?
    
    init(url: URL?, imageData: Data?) {
        imageURL = url
        self.imageData = imageData
    }
}
