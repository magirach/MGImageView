//
//  MGIimageView.swift
//  Unsplash
//
//  Created by Moinuddin Girach on 26/11/19.
//  Copyright © 2019 Moinuddin Girach. All rights reserved.
//

import Foundation
import UIKit

class MGImageView: UIImageView {
    
    static var imageQueue = OperationQueue()
      
    private var oparation: MGImageDownloadOparation?
    
    override var image: UIImage? {
        didSet {
            if image == nil {
                oparation?.cancel()
            }
        }
    }
    
    func loadImage(url:String?) {
        if let url = url {
            if let img = MGImageCacheManager.shared.getImage(for: url) {
                self.image = img
            } else {
                oparation = createNewOparatoin(url: url)
                oparation!.completionBlock = { [weak self] in
                    guard let strongSelf = self else {return}
                    if strongSelf.oparation!.isCancelled {
                        print("canceled")
                    }
                    if strongSelf.oparation!.isFor(url: url) {
                        let img = MGImageCacheManager.shared.getImage(for: url)
                        DispatchQueue.main.async {
                            strongSelf.image = img
                        }
                    }
                }
            }
        } else {
            self.image = nil
        }
    }
    
    func getOparation(for url: String) -> MGImageDownloadOparation? {
        for opr in MGImageView.imageQueue.operations {
            if (opr as! MGImageDownloadOparation).isFor(url: url) {
                return (opr as! MGImageDownloadOparation)
            }
        }
        return nil
    }
    
    func createNewOparatoin(url: String) -> MGImageDownloadOparation {
        if let current = getOparation(for: url) {
            if current.isCancelled && !current.isFinished {
                current.start()
                print("started again")
            }
            return current
        } else {
            let opr = MGImageDownloadOparation(url: url)
            MGImageView.imageQueue.addOperation(opr)
            return opr
        }
    }
    
    deinit {
        oparation?.cancel()
    }
}
