# TYTextInputLimitTool_Swift
A tool to limit the type and length of text, support Objective-C and Swift.

You can find a Objective-C version here [TYTextInputLimitTool](https://github.com/HXHXT/TYTextLimitTool)

## Introduce

**If you don't want to write regular，textfield delegate，decimal count， insert space logic，try it！**

1. Support UITextField UITextView UILabel
2. Limit Text type include Chinese English Number
3. Limit Length 
4. Limit Decimal 
5. Limit Number with Space 

If you use TYTextLimitTool，the textfield delegate shouldn't be set again.

## Install

Add  TYTextLimitTool folders to your project.

## Usage

**Limit Chinese, English, Number, Length**

```
textField.textLimitTool.model = [TYTextLimitModel.Chinese]
textField.textLimitTool.length = 10

textField1.textLimitTool.model = [TYTextLimitModel.Number, TYTextLimitModel.Decimal]
textField1.textLimitTool.length = 8
```

**Limit Decimal, support setting the length of decimal points before and after**

```
textField2.textLimitTool.model = [TYTextLimitModel.DecimalFraction]
textField2.textLimitTool.beforeDecimalLenth = 4
textField2.textLimitTool.afterDecimalLenth = 3
```

**Limit Number with Space，support number or number array，support reverse，support check space after set text by code**

``` 
textField3.textLimitTool.model = [TYTextLimitModel.NumberWithSpace]
textField3.textLimitTool.space = 4
textField3.textLimitTool.reversed = false // default is false
// check space after set text by code
textField3.text = "123456789"
textField3.textLimitTool.checkSpace()
```

```
textField4.textLimitTool.model = [TYTextLimitModel.NumberWithSpace]
textField4.textLimitTool.spaceList = [2, 3, 4]
// check space after set text by code
textField4.text = "123456789"
textField4.textLimitTool.checkSpace()
```

**UITextView usage is similar to UITextField**

**UILabel mainly supports blank mode**

```
label.textLimitTool.model = [TYTextLimitModel.NumberWithSpace]
label.textLimitTool.spaceList = [2, 3, 4]
label.text = "123456789"
label.textLimitTool.checkSpace()
```

**You can find more examples in demo**