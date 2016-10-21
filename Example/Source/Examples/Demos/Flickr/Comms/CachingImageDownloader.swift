//
//  CachingImageDownloader.swift
//  COCameras
//
//  Created by Justin Anderson on 10/8/16.
//  Copyright © 2016 Blue Mesa Software LLC. All rights reserved.
//

import Foundation
import BrickKit

class ChachedImage {
    var imageData: NSData?
    var url: NSURL
    var expirationDate: NSDate
    var hasImage: Bool = true
    
    init(imageData: NSData?, url: NSURL, expirationDate: NSDate) {
        self.url = url
        self.expirationDate = expirationDate
        self.imageData = imageData
    }
}

class CachingImageDownloader: ImageDownloader {
    
    private let cache = NSCache() //<NSURL, ChachedImage>()
    var metaDataHandler: ((UIImage) -> Bool)? = nil
    
    func downloadImage(with imageURL: NSURL, onCompletion completionHandler: ((image: UIImage) -> Void)) {
        if let cachedImage = cache.objectForKey(imageURL) as? ChachedImage, let imageData = cachedImage.imageData, let image = UIImage(data: imageData) {
            completionHandler(image: image)
            return
        }
        
        
        NSURLSession.sharedSession().dataTaskWithURL(imageURL, completionHandler: { (data, response, error) in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            
            
            let cached = ChachedImage(imageData: data, url: imageURL, expirationDate: NSDate())
            cached.hasImage = self.metaDataHandler?(image) ?? true
            self.cache.setObject(cached, forKey: imageURL as NSURL)
            if !cached.hasImage {
                return
            }
            
            completionHandler(image: image)
        }).resume()
    }
}
