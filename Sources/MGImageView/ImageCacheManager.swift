//
//  ImageCacheManager.swift
//  ContactApp
//
//  Created by Moinuddin Girach on 17/11/19.
//  Copyright © 2019 Moinuddin Girach. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class MGImageCacheManager: NSObject {
    
    public static let shared:  MGImageCacheManager = {
        return MGImageCacheManager()
    }()
    
    private override init() {
        super.init()
    }
    
    private let cache = NSCache<AnyObject, AnyObject>()
    
    public func cacheImage(imageData: Data, key: String) {
        cache.setObject(imageData as AnyObject, forKey: key as AnyObject)
    }
    
    public func getImageData(for key: String) -> Data? {
        return cache.object(forKey: key as AnyObject) as? Data
    }
    
    #if canImport(UIKit)
    public func getImage(for key: String) -> UIImage? {
        if let imgData = getImageData(for: key) {
            return UIImage(data: imgData)
        } else {
            return nil
        }
    }
    #endif
}
