//
//  TYTextLimitTool.swift
//  
//
//  Created by ty on 2017/7/20.
//  Copyright © 2017年 TY. All rights reserved.
//

import UIKit

typealias UITextChangeBlock = (String) -> ()

enum TYTextLimitModel: Int16 {
    case Number = 0x0001             // 数字
    case English = 0x0002            // 英文
    case Chinese = 0x0004            // 汉字
    case Decimal = 0x0008            // 小数点
    // 以下均为独立模式
    case DecimalFraction = 0x0010    // 小数 - 支持设置小数点前长度和小数点后长度
    case NumberWithSpace = 0x0080    // 数字插空格 - 需要设置 间隔数 或者 间隔数组
}

class TYTextLimitTool: NSObject, UITextFieldDelegate, UITextViewDelegate {
    
    // 字符判断
    public var model: Array<TYTextLimitModel>? {
        didSet {
            self.setUpRegex(model: model!)
        }
    }
    
    // 长度判断(不包含空格)
    public var length: Int?{
        didSet {
            if self.space != nil {
                self.spaceLenth += (self.length! - 1) / self.space!
            }
        }
    }
    
    // 小数判断 - 小数点前长度和小数点后长度
    public var beforeDecimalLenth: Int?
    public var afterDecimalLenth: Int?
    
    // 插空格位置,比如希望把123456789分成1234 5678 9，这里就传4
    public var space: Int? {
        didSet {
            if self.length != nil {
                self.spaceLenth += (self.length! - 1) / self.space!
            }
        }
    }
    // 正向还是反向，比如希望把123456789分成1 2345 6789，这里就传true
    public var reversed = false
    // 根据数组加空格,数组中为分段标准，比如希望把123456789分成123 4567 89，数组就传[3,4,2]
    public var spaceList: Array<Int>? {
        didSet {
            var count = 0
            for i in spaceList! {
                count += i
            }
            self.length = count
            self.spaceLenth = self.spaceList!.count - 1
        }
    }
    
    // 文字改变回调
    public var textChangeBlock: UITextChangeBlock?
    // 文字输入完毕回调
    public var textReturnBlock: UITextChangeBlock?
    
    // 手动验证-在给textfield/textview/label设置了text后，如果想要插空格可以调用这个方法，此处不再验证其他内容。
    // MARK: --------------手动验证--------------
    public func checkSpace() {
        if model != nil && object != nil {
            let text = object!.value(forKey: "text") as! String
            // 插空格判断
            _ = checkNumberWithSpace(oldText: "", newText: text, object: object!)
        }
    }
    
    // MARK: --------------provite--------------
    /** 输入时验证 */
    private var textRegex: String?
    /** 输入完验证 */
    private var textConfirmRegex: String?
    // space个数
    private lazy var spaceLenth = 0
    
    weak var object: NSObject?
    func registerTarget(textField: UITextField) {
        textField.addTarget(self, action: #selector(textFieldTextDidChange), for: .editingChanged)
    }
    
    // MARK: - 输入时验证
    /** textField */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return checkTextWithOldText(oldText: textField.text!, newText: string, object: textField)
    }
    
    /** textView */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return checkTextWithOldText(oldText: textView.text!, newText: text, object: textView)
    }
    
    func checkTextWithOldText(oldText: String, newText: String, object: NSObject) -> Bool {
        // 删除
        if newText == "" {
            if model != nil && model!.contains(TYTextLimitModel.NumberWithSpace) {
                if oldText.hasSuffix(" ") && oldText.count > 1 {
                    object.setValue(String(oldText[..<oldText.index(oldText.endIndex, offsetBy: -2)]), forKey: "text")
                    return false
                }
            }
            return true
        }
        if model != nil {
            // 正则判断
            if !checkPred(regex: textRegex!, text: newText) { return false }
            // 小数位数判断
            if !checkDecimalFraction(oldText: oldText, newText: newText) { return false }
            // 插空格判断
            if !checkNumberWithSpace(oldText: oldText, newText: newText, object: object) {
                _ = checkLength(object: object)
                return false
            }
        }
        return true
    }
    
    func text() -> Bool {
        return false
    }
    
    // MARK: - 输入后验证
    // textField
    @objc private func textFieldTextDidChange(textField: UITextField) {
        checkTextWith(object: textField)
    }
    
    // textView
    func textViewDidChange(_ textView: UITextView) {
        checkTextWith(object: textView)
    }
    
    func checkTextWith(object: NSObject) {
        let range = object.value(forKey: "markedTextRange")
        if (range == nil) {
            // 长度判断-因为有待输入的情况所以长度判断放在输入完毕后
            _ = checkLength(object: object)
            
            // 中文判断
            let text = object.value(forKey: "text") as! String
            if (model != nil && model!.contains(TYTextLimitModel.Chinese) && text.count != 0) { // 对于中文的二次验证
                let pred = NSPredicate(format: "SELF MATCHES " + textConfirmRegex!)
                if !pred.evaluate(with: object.value(forKey: "text")!) {
                    let str = text.replacingOccurrences(of: "[a-zA-Z]", with: "", options: String.CompareOptions.regularExpression)
                    object.setValue(str, forKey: "text")
                }
            }
            textChangeBlock?(object.value(forKey: "text") as! String)
        }
    }
    
    // MARK: --------------check方法--------------
    // 正则判断
    func checkPred(regex: String, text: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES " + regex)
        if !pred.evaluate(with: text) {
            return false
        }
        return true
    }
    
    // 小数位数判断
    func checkDecimalFraction(oldText: String, newText: String) -> Bool {
        if model!.contains(TYTextLimitModel.DecimalFraction) && (afterDecimalLenth != nil) && (beforeDecimalLenth != nil) {
            if oldText.contains(".") {
                if (oldText == ".") {
                    return false
                }
                let array = oldText.components(separatedBy: ".")
                let afterString = array[1]
                if (afterString.count >= afterDecimalLenth!) {
                    return false
                }
            } else {
                if ((oldText.count == 0) && (newText == "." || newText == "0")) {
                    return false
                } else if ((oldText.count >= beforeDecimalLenth!) && !(newText == ".")) {
                    return false
                }
            }
        }
        return true
    }
    
    // 插空格判断
    func checkNumberWithSpace(oldText: String, newText: String, object: NSObject) -> Bool {
        // 插空格判断
        if model!.contains(TYTextLimitModel.NumberWithSpace) {
            var string = oldText + newText
            string = string.replacingOccurrences(of: " ", with: "")
            var index = 0
            if (space != nil) && reversed {
                index = string.count % space!
                if (index > 0) && (string.count / space!) > 0 {
                    string.insert(" ", at: string.index(string.startIndex, offsetBy: index))
                    index += 1
                }
            }
            
            var spaceListIndex = 0
            while (true) {
                if spaceList != nil {
                    if spaceList!.count > spaceListIndex {
                        index += spaceList![spaceListIndex]
                        spaceListIndex += 1
                    } else {
                        break
                    }
                } else if (space! > 0) {
                    index += space!
                }
                if (string.count <= index) {
                    break
                }
                string.insert(" ", at: string.index(string.startIndex, offsetBy: index))
                index += 1
            }
            object.setValue(string, forKey: "text")
            return false
        }
        return true
    }
    
    // 长度判断
    func checkLength(object: NSObject) -> Bool {
        if (length != nil) {
            let str = object.value(forKey: "text") as! String
            if (str.count > length! + self.spaceLenth) {
                let index = str.index(str.startIndex, offsetBy:self.length! + self.spaceLenth)
                object.setValue(String(str[..<index]), forKey: "text")
                return false
            }
        }
         return true
    }
    
    // MARK: --------------文字输入完毕回调--------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textReturnBlock?(textField.text!)
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textReturnBlock?(textView.text!)
    }
    
    // MARK: --------------初始化正则--------------
    func setUpRegex(model: Array<TYTextLimitModel>)  {
        var textRegex = ""
        var textConfirmRegex = ""
        
        if model.contains(TYTextLimitModel.DecimalFraction) { // 小数模式
            textConfirmRegex += "0-9."
        } else if model.contains(TYTextLimitModel.NumberWithSpace) { // 数字插空格模式
            textConfirmRegex += "0-9"
        } else {
            if model.contains(TYTextLimitModel.Chinese) {
                textConfirmRegex += "\u{4e00}-\u{9fa5}"
            }
            if model.contains(TYTextLimitModel.English) {
                textConfirmRegex += "a-zA-Z"
            }
            if model.contains(TYTextLimitModel.Number) {
                textConfirmRegex += "0-9"
            }
            if model.contains(TYTextLimitModel.Decimal) {
                textConfirmRegex += "."
            }
        }
            
        textRegex += textConfirmRegex
        if model.contains(TYTextLimitModel.Chinese) {
            textRegex += "a-zA-Z➋➌➍➎➏➐➑➒"
        }
        self.textRegex = "'[\(textRegex)]+'"
        self.textConfirmRegex = "'[\(textConfirmRegex)]+'"
    }
}
