//
//  Constants.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import UIKit

// MARK: - Components

// Components object representing the constants to build a URL

struct Components {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Text = "text"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let Per_Page = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let Method = "flickr.photos.search"
        static let APIKey = "82174b20665805c27aef79b4a78324e3"
        static let Format = "json"
        static let DisableJSONCallback = "1"
        static let ImageURL = "url_s"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_s"
    }
}
