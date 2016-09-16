//
//  ImageProvider.swift
//  WGSA
//
//  Created by Simon Arneson on 2016-09-16.
//  Copyright © 2016 WGSA. All rights reserved.
//

import Foundation
import UIKit
import ImageViewer

class FullScreenImageWrapper: ImageProvider {
    private var image: UIImage
    var imageCount: Int {
        return 1
    }
    init(_ image: UIImage) {
        self.image = image
    }
    func provideImage(_ completion: (UIImage?) -> Void) {
        completion(image)
    }
    func provideImage(atIndex index: Int, completion: (UIImage?) -> Void) {
        completion(image)
    }
}
