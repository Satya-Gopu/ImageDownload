//
//  NetworkingClient.swift
//  SpinCar
//
//  Created by Satya on 7/9/18.
//  Copyright © 2018 Satya. All rights reserved.
//

import Foundation

// MARK: - Network Client

class NetworkingClient: NSObject, URLSessionDelegate {
    
    // MARK: Properties
    
    // singelton networking instance
    static let shared = NetworkingClient()
    
    // session
    lazy var urlSession :URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    
    // MARK: LifeCycle
    
    // overriding init to make it private
    private override init() {

    }
    
    // MARK: Private
    
    // Builds and returns the URLComponents for the image fetch
    private func urlComponents() -> URLComponents {
        let parameters = [Components.FlickrParameterKeys.Method:Components.FlickrParameterValues.Method, Components.FlickrParameterKeys.APIKey:Components.FlickrParameterValues.APIKey, Components.FlickrParameterKeys.Extras:Components.FlickrParameterValues.ImageURL, Components.FlickrParameterKeys.Format:Components.FlickrParameterValues.Format, Components.FlickrParameterKeys.NoJSONCallback:Components.FlickrParameterValues.DisableJSONCallback]
        var components = URLComponents()
        components.scheme = Components.Flickr.APIScheme
        components.host = Components.Flickr.APIHost
        components.path = Components.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components
    }
    
    // MARK: Client calls
    
    // Fetches the images from the Flickr API with the given search criteria
    func fetchImageData(with text: String, pageNum: Int, pageCount: Int=100, completion: @escaping ((NetworkResponse)->())) {
        // build the url out of the constants
        var urlComponents = self.urlComponents()
        let textQueryItem = URLQueryItem(name: Components.FlickrParameterKeys.Text, value: "\(text)")
        let pageNumQueryItem = URLQueryItem(name: Components.FlickrParameterKeys.Page, value: "\(pageNum)")
        let pageCountQuertyItem = URLQueryItem(name: Components.FlickrParameterKeys.Per_Page, value: "\(pageCount)")
        urlComponents.queryItems = urlComponents.queryItems! + [textQueryItem, pageNumQueryItem, pageCountQuertyItem]
        
        // perform the fetch with the session object
        urlSession.dataTask(with: urlComponents.url!) { (data, response, error) in
            DispatchQueue.main.async {
                // check for any error
                guard error == nil else {
                    completion(NetworkResponse(errorMessage: error!.localizedDescription, data: nil))
                    return
                }
                // check if the response is success
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    completion(NetworkResponse(errorMessage: NetworkErrors.InvalidResponseError, data: nil))
                    return
                }
                
                // check if the data is not nil
                guard let data = data else {
                    completion(NetworkResponse(errorMessage: NetworkErrors.NoDataError, data: nil))
                    return
                }
                
                let jsonResult:[String: Any]!
                // check if the data is a valid object
                do {
                    jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                } catch {
                    completion(NetworkResponse(errorMessage: NetworkErrors.InvalidResponseError, data: nil))
                    return
                }
                
                // check if the required keys are present in the response
                guard let photosDict = jsonResult[Components.FlickrResponseKeys.Photos] as? [String : Any], let photoArray = photosDict[Components.FlickrResponseKeys.Photo] as? [[String : Any]] else {
                    completion(NetworkResponse(errorMessage: NetworkErrors.InvalidResponseError, data: nil))
                    return
                }
                
                var imageArray = [ImageData]()
                
                for photoObject in photoArray {
                    guard let imageURLString = photoObject[Components.FlickrResponseKeys.MediumURL] as? String, let imageURL = URL(string: imageURLString) else {
                        continue
                    }
                    let imageData = ImageData(url: imageURL, imageData: nil)
                    imageArray.append(imageData)
                }
                
                completion(NetworkResponse(errorMessage: nil, data: imageArray))
            }
        }.resume()
    }
    
    // Downloads the image from the network
    
    func downloadImage(for url: URL, completion: @escaping (Data)->Void) {
        urlSession.dataTask(with: url) { (imageData, response, error) in
            // check if the response is a success
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                return
            }
            
            // check if the data is not nil and error is nil
            guard let data = imageData, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                ImageCache.shared.setImageData(for: url, data: data)
                completion(data)
            }
        }.resume()
    }
}
