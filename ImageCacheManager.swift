//
//  ImageCacheManager.swift
//  ContactApp
//
//  Created by Moinuddin Girach on 17/11/19.
//  Copyright © 2019 Moinuddin Girach. All rights reserved.
//

import Foundation
import UIKit

class MGImageCacheManager: NSObject {
    
    static let shared:  MGImageCacheManager = {
        return MGImageCacheManager()
    }()
    
    private override init() {
        super.init()
    }
    
    private let cache = NSCache<AnyObject, AnyObject>()
    
    func cacheImage(imageData: Data, key: String) {
        cache.setObject(imageData as AnyObject, forKey: key as AnyObject)
    }
    
    func getImage(for key: String) -> UIImage? {
        if let imgData = cache.object(forKey: key as AnyObject) as? Data {
            return UIImage(data: imgData)
        } else {
            return nil
        }
    }
}
