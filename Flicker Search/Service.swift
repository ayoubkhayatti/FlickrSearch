//
//  Service.swift
//  Flicker Search
//
//  Created by Ayoub Khayatti on 28/03/16.
//  Copyright © 2016 Ayoub Khayati. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

public enum ServiceResponse<Value, Error> {
    case success(Value?)
    case error(Error?)
    
    public var success: Value? {
        switch self {
        case .success(let value):
            return value
        case .error:
            return nil
        }
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .error(let error):
            return error
        }
    }
}

class Service: NSObject {
    
    static let sharedInstance = Service()
    
    // MARK: - Services constants
    
    struct url {
        static let https    = "https://"
        static let base     = "api.flickr.com/services/"
        static let service  = "rest/"
        static let searchURL = "\(url.https)\(url.base)\(url.service)"
    }
    
    struct parameters {
        static let apiKey   = "5f7e7548a1e6ac3de8b1e0e105d3389c"
        static let secret   = "6a0b59e55549d870"
        static let format   = "json"
        static let nojsoncallback   = "1"
        
        struct method {
            static let search   = "flickr.photos.search"
        }
    }
    
    // MARK: - Services

    class func search(text:String, page:Int, completion:(value:[FlickrPhoto]?, error:String?)->Void){
        if !text.isEmpty {
            debugPrint("search text: \(text)")
            let params: [String:AnyObject] = [
                "method":parameters.method.search,
                "api_key":parameters.apiKey,
                "text":text,
                "page":page,
                "format":parameters.format,
                "nojsoncallback":parameters.nojsoncallback]
            
            let instance = Service.sharedInstance
            instance.getRequest(url.searchURL, urlParams: params){response in
                switch response{
                    case .success:
                        if let value = response.success{
                            let result = instance.handleSearchResponse(value)
                            if result.success == true {
                                let photos = FlickrPhoto.parseResponse(value)
                                completion(value: photos, error: nil)
                            }else{
                                completion(value: nil, error: result.message!)
                            }
                        }
                    case .error:
                        if let error = response.error{
                            debugPrint("\(error)")
                            completion(value: nil, error: instance.errorMessageForCode(error?.code))
                        }
                }
            }
        }
    }
    
    //MARK: - Integrity
    
    func handleSearchResponse(response: AnyObject?) -> (success: Bool?, message: String?){
        if let dictionary = response as? NSDictionary {
            if  dictionary["photos"] != nil {
                return(true, "\(dictionary["pages"])")
            }else{
                return (false, "\(dictionary["message"])")
            }
        }
        return (false, "unkown response")
    }
    
    func errorMessageForCode(code:Int?) -> String {
        //TODO: more advanced error handling must be implemented
        return "unknown error"
    }
    
    // MARK: - REST

    func getRequest(url:String, urlParams: [String : AnyObject]?, completion:(response:ServiceResponse<AnyObject?, NSError?>)->Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(.GET, url, headers: nil, parameters: urlParams)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if (response.result.error == nil) {
                    debugPrint("Service - Get Success: HTTP Response Header: \(response.request?.allHTTPHeaderFields)")
                    completion(response:ServiceResponse.success(response.result.value))
                }
                else {
                    debugPrint("Service - Get Error: HTTP Request failed: \(response.result.error)")
                    completion(response:ServiceResponse.error(response.result.error))
                }
        }
    }
    
    //MARK: - Media
    
    class func getImage(url: String, completion:(response:UIImage?)->Void){
        Alamofire.request(.GET, url)
            .responseImage { response in
                debugPrint(response)
                debugPrint(response.request)
                debugPrint(response.response)
                debugPrint(response.result)
                if let image = response.result.value {
                    completion(response: image)
                }
        }
    }

}
