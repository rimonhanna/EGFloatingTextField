# EGFloatingTextField

An implemantation of "Float Label Pattern" of Material Design in Swift programming language. 

![alt tag](https://raw.github.com/enisgayretli/EGFloatingTextField/master/EGFloatingTextField.gif)

## Usage

EGFloatingTextField is available through [CocoaPods](http://cocoapods.org). To install it, 
simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod 'EGFloatingTextField', :git => 'https://github.com/rimonhanna/EGFloatingTextField.git'
```

## Setup
**Import dependency**
```
import PureLayout
```
**Initialize the textfield and add it as a subview**
```
let emailLabel = EGFloatingTextField(frame: CGRectMake(8, 64, CGRectGetWidth(self.view.bounds) - 16, 48))
```
```
// set as floatinglabel
emailLabel.floatingLabel = true
```
```
// set the placeholder
emailLabel.setPlaceHolder("Email")
```
```
// set the validation type there are two options at the moment, Email and Number.
emailLabel.validationType = .Email
```
```
// add as subview
self.view.addSubview(emailLabel)
```
**Create custom validator for textfield**

Add new case for EGFloatingTextFieldValidationType enum
```
enum EGFloatingTextFieldValidationType {

    case Email
    case Number
    case Custom
    case ..
}
```

Implement the validation block
```
self.customValidationBlock = ({(text:String, inout message: String) -> Bool in
    ....
})
.....
```

## Author

Rimon Hanna, https://twitter.com/rimon_hanna
Enis Gayretli, enisgayretli@gmail.com

## License

EGFloatingTextField is available under the MIT license. See the LICENSE file for more info.
