//
//  ImageCache.swift
//  SpinCar
//
//  Created by Satya on 7/10/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import UIKit

class ImageCache: NSObject {
    
    // ImageDataSource
    private var dataSource = [URL: Data]()
    
    // singleton instance
    
    static let shared = ImageCache()
    
    // MARK: Life Cycle
    
    // override init
    
    private override init() {
        super.init()
        listenToMemoryWarnings()
    }
    
    // deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Clears the cache memory upon receiving the memory warning
    private func listenToMemoryWarnings() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { [weak self] (notification) in
            self?.dataSource.removeAll()
        }
    }
    
    // Instance methods
    
    // fetch imageData for a URL from the cache
    
    func imageData(for url: URL) -> Data? {
        
        guard let data = dataSource[url] else {
            return nil
        }
        return data
    }
    
    // set imageData for a URL to the cache
    
    func setImageData(for url: URL, data: Data) {
        dataSource[url] = data
    }
    
}
