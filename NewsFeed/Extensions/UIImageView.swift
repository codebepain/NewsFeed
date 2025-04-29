//
//  UIImageView.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 29.04.2025.
//

import UIKit

extension UIImageView {

    var img: ImageViewProxy {
        if let proxy = objc_getAssociatedObject(self, AssociatedKey.key()) as? ImageViewProxy {
            return proxy
        }
        let proxy = ImageViewProxy(self)
        objc_setAssociatedObject(
            self,
            AssociatedKey.key(),
            proxy,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return proxy
    }
}
