//
//  UILabel+TextLimit.swift
//  SwiftDemo
//
//  Created by TY on 2019/3/5.
//  Copyright © 2019 TY. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var textLimitTool: TYTextLimitTool {
        set {
            objc_setAssociatedObject(self, RuntimeKey.textLimitTool!, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            var tool: TYTextLimitTool? = objc_getAssociatedObject(self, RuntimeKey.textLimitTool!) as? TYTextLimitTool
            if tool == nil {
                tool = TYTextLimitTool.init()
                tool!.object = self
                self.textLimitTool = tool!
            }
            return tool!
        }
    }
}
