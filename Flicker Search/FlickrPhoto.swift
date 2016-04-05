//
//  FlickrPhoto.swift
//  Flicker Search
//
//  Created by Ayoub Khayatti on 28/03/16.
//  Copyright © 2016 Ayoub Khayati. All rights reserved.
//

import UIKit

class FlickrPhoto: NSObject {
    
    var id    :String = ""
    var owner :String = ""
    var secret:String = ""
    var server:String = ""
    var farm  :Int = 0
    var title :String = ""
    var ispublic :Int = 0
    var isfriend :Int = 0
    var isfamily :Int = 0
    
    var photoUrl: String {
        let url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_n.jpg"
        return url
    }
    
    var photoLargeUrl: String {
        let url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg"
        return url
    }
    
    init(dictionary: NSDictionary) {
        super.init()
        id      = dictionary["id"] as? String ?? id
        owner   = dictionary["owner"] as? String ?? owner
        secret  = dictionary["secret"] as? String ?? secret
        server  = dictionary["server"] as? String ?? server
        farm    = dictionary["farm"] as? Int ?? farm
        title   = dictionary["title"] as? String ?? title
        ispublic    = dictionary["ispublic"] as? Int ?? ispublic
        isfriend    = dictionary["isfriend"] as? Int ?? isfriend
        isfamily    = dictionary["isfamily"] as? Int ?? isfamily
    }
    
    class func parseResponse(response: AnyObject?) -> [FlickrPhoto]{
        var photosArray = [FlickrPhoto]()
        if let dictionary = response as? NSDictionary {
            if let photos = dictionary["photos"]!["photo"] as? [AnyObject]{
                for photoData in photos {
                    let photo = FlickrPhoto(dictionary:(photoData as! NSDictionary))
                    photosArray.append(photo)
                }
            }
        }
        return photosArray
    }
}
