//
//  UIImageView+MSRSetter.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/9.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

extension UIImageView {
    var msr_imageRenderingMode: UIImageRenderingMode? {
        set {
            image = image?.imageWithRenderingMode(newValue ?? .Automatic)
        }
        get {
            return image?.renderingMode
        }
    }
}
