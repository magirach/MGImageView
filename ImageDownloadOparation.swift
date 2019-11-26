//
//  ImageDownloadOparation.swift
//  Unsplash
//
//  Created by Moinuddin Girach on 26/11/19.
//  Copyright © 2019 Moinuddin Girach. All rights reserved.
//

import Foundation

class MGImageDownloadOparation: Operation {
    
    static let queue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5 // reduces the load
        queue.isSuspended = false // ensure the queue is active
        return queue
    }()

    static let session: URLSession = {
        var config = URLSessionConfiguration.default
        var s = URLSession(configuration: config)
        return s
    }()
    
    fileprivate var _finished: Bool = false
    override var isFinished: Bool {
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
    override var isExecuting: Bool{
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
    
    init(url: String) {
        self.url = url
        super.init()
    }
    
    override func start() {
        // Setup
        guard isCancelled == false else { return } // skip if already cancelled
        isExecuting = true
        isFinished = false
        
        let task = API.getImage(path: url) { [weak self] (data, error) in
            guard let strongSelf = self else {return}
            if error != nil {
        
            } else {
                MGImageCacheManager.shared.cacheImage(imageData: data!, key: strongSelf.url)
            }
            strongSelf.isFinished = true
            strongSelf.isExecuting = false
        }

        task!.resume()
    }
    
    func isFor(url: String) -> Bool {
        return url == self.url
    }
}
