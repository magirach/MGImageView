//
//  ImageDownloadOparation.swift
//  Unsplash
//
//  Created by Moinuddin Girach on 26/11/19.
//  Copyright © 2019 Moinuddin Girach. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class MGImageDownloadOparation: Operation {
    
    public static let queue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5 // reduces the load
        queue.isSuspended = false // ensure the queue is active
        return queue
    }()

    public static var session: URLSession = {
        var config = URLSessionConfiguration.default
        var s = URLSession(configuration: config)
        return s
    }()
    
    fileprivate var _finished: Bool = false
    public override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    fileprivate var _executing: Bool = false
    public override var isExecuting: Bool{
        get {
            return _executing
        }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var url: String
    
    public init(url: String) {
        self.url = url
        super.init()
    }
    
    public override func start() {
        // Setup
        guard isCancelled == false else { return } // skip if already cancelled
        isExecuting = true
        isFinished = false
        
        guard let requestURL = URL(string: url) else {
            isFinished = true
            isExecuting = false
            return
        }
        
        let task = MGImageDownloadOparation.session.dataTask(with: requestURL) { [weak self] (data, response, error) in
            guard let strongSelf = self else {return}
            if error != nil {
        
            } else if let data = data {
                MGImageCacheManager.shared.cacheImage(imageData: data, key: strongSelf.url)
            }
            strongSelf.isFinished = true
            strongSelf.isExecuting = false
        }

        task.resume()
    }
    
    public func isFor(url: String) -> Bool {
        return url == self.url
    }
}
