//
//  ViewController.swift
//  SwiftDemo
//
//  Created by TY on 2019/2/21.
//  Copyright © 2019 TY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Chinese，English，Number，Decimal等类型可以自由组合
        textField.textLimitTool.model = [TYTextLimitModel.Chinese]
        textField.textLimitTool.length = 10
        textField.textLimitTool.textChangeBlock = { text in // 提供文字变化的block
            print(text)
        }
        textField.textLimitTool.textReturnBlock = { text in // 提供输入完成的block
            print(text)
        }
        
        textField1.textLimitTool.model = [TYTextLimitModel.Number, TYTextLimitModel.Decimal]
        textField1.textLimitTool.length = 8
        
        // 小数模式，不能与其他模式组合，支持设置小数点前后长度
        textField2.textLimitTool.model = [TYTextLimitModel.DecimalFraction]
        textField2.textLimitTool.beforeDecimalLenth = 4 // 小数点前4位
        textField2.textLimitTool.afterDecimalLenth = 3 // 小数点后3位
        
        // 数字插空格模式，主要用于银行卡输入等情况，不能与其他模式组合，需要设置 间隔数 或 间隔数组 (同时设置的话只有间隔数组生效)
        // 间隔数
        textField3.textLimitTool.model = [TYTextLimitModel.NumberWithSpace]
        textField3.textLimitTool.space = 4 // 间隔数为4,比如输入123456789，则显示1234 5678 9
        textField3.textLimitTool.reversed = false // 是否反向，默认为false，如果设置成true，则输入123456789会显示1 2345 6789
        textField3.textLimitTool.length = 9
        // 插空格模式可以手动checkSpace，便于给服务器返回的数据加空格
        textField3.text = "123456789"
        textField3.textLimitTool.checkSpace()
        
        // 间隔数组
        textField4.textLimitTool.model = [TYTextLimitModel.NumberWithSpace]
        textField4.textLimitTool.spaceList = [2, 3, 4] // 间隔数组，输入123456789，则显示12 345 6789，会自动加上长度限制为9（2+3+4）个字符
        // 插空格模式可以手动checkSpace，便于给服务器返回的数据加空格
        textField4.text = "123456789"
        textField4.textLimitTool.checkSpace()
    
        // textview用法类似，这里只举一个简单例子
        textView.textLimitTool.model = [TYTextLimitModel.Chinese, TYTextLimitModel.English]
        textView.textLimitTool.length = 20
        
        // label主要是支持NumberWithSpace的功能
        label.textLimitTool.model = [TYTextLimitModel.NumberWithSpace]
        label.textLimitTool.spaceList = [2, 3, 4]
        label.text = "123456789"
        label.textLimitTool.checkSpace()
        
        // 添加触摸停止输入
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewHasTouched)))
    }
    
    @objc func viewHasTouched() {
        view.endEditing(true)
    }
}

