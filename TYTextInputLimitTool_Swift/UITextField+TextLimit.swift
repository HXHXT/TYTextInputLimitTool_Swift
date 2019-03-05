//
//  UITextField+TextLimit.swift
//  
//
//  Created by ty on 2017/7/20.
//  Copyright © 2017年 TY. All rights reserved.
//

import Foundation
import UIKit

struct RuntimeKey {
    static let textLimitTool = UnsafeRawPointer.init(bitPattern: "JKKey".hashValue)
}

extension UITextField {
    var textLimitTool: TYTextLimitTool {
        set {
            objc_setAssociatedObject(self, RuntimeKey.textLimitTool!, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            var tool: TYTextLimitTool? = objc_getAssociatedObject(self, RuntimeKey.textLimitTool!) as? TYTextLimitTool
            if tool == nil {
                tool = TYTextLimitTool.init()
                self.delegate = tool
                tool!.object = self
                tool!.registerTarget(textField: self)
                self.textLimitTool = tool!
            }
            return tool!
        }
    }
}
