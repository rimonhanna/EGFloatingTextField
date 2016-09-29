//
//  EGFloatingTextField.swift
//  EGFloatingTextField
//
//  Created by Enis Gayretli on 26.05.2015.
//
//
import UIKit
import Foundation
import PureLayout


public enum EGFloatingTextFieldValidationType {
    case email
    case number
    case custom
}

open class EGFloatingTextField: UITextField {
    
    
    public typealias EGFloatingTextFieldValidationBlock = ((_ text:String,_ message:inout String)-> Bool)
    
    open var validationType : EGFloatingTextFieldValidationType?
    
    
    fileprivate var emailValidationBlock  : EGFloatingTextFieldValidationBlock?
    fileprivate var numberValidationBlock : EGFloatingTextFieldValidationBlock?
    open var customValidationBlock : EGFloatingTextFieldValidationBlock?
    
    
    let kDefaultInactiveColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.54))
    let kDefaultActiveColor = UIColor.blue
    let kDefaultErrorColor = UIColor.red
    let kDefaultLineHeight = CGFloat(22)
    let kDefaultLabelTextColor = UIColor(white: CGFloat(0), alpha: CGFloat(0.54))
    
    
    open var floatingLabel : Bool?
    var label : UILabel?
    var labelFont : UIFont?
    var labelTextColor : UIColor?
    var activeBorder : UIView?
    var floating : Bool?
    var active : Bool?
    var hasError : Bool?
    var errorMessage : String?
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit() {
        
        self.emailValidationBlock = ({(text:String, message: inout String) -> Bool in
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@" , emailRegex)
            
            let  isValid = emailTest.evaluate(with: text)
            if !isValid {
                message = "Invalid Email Address"
            }
            return isValid;
        })
        self.numberValidationBlock = ({(text:String,message: inout String) -> Bool in
            let numRegex = "[0-9.+-]+";
            let numTest = NSPredicate(format:"SELF MATCHES %@" , numRegex)
            
            let isValid =  numTest.evaluate(with: text)
            if !isValid {
                message = "Invalid Number"
            }
            return isValid;
            
        })

        self.floating = false
        self.hasError = false
       
        self.labelTextColor = kDefaultLabelTextColor
        
        self.label = UILabel(frame: CGRect.zero)
        if let label = self.label {
            label.font = self.labelFont
            label.textColor = self.labelTextColor
            label.textAlignment = NSTextAlignment.left
            label.numberOfLines = 1
            label.layer.masksToBounds = false
            self.addSubview(label)
        }
        
        self.activeBorder = UIView(frame: CGRect.zero)
        if let activeBorder = self.activeBorder {
            activeBorder.backgroundColor = kDefaultActiveColor
            activeBorder.layer.opacity = 0
            self.addSubview(activeBorder)
        }
        
        if let label = self.label {
            label.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: self)
            label.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self)
            label.autoMatch(ALDimension.width, to: ALDimension.width, of: self)
            label.autoMatch(ALDimension.height, to: ALDimension.height, of: self)
        }
        
        if let activeBorder = self.activeBorder {
            activeBorder.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: self)
            activeBorder.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self)
            activeBorder.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self)
            activeBorder.autoSetDimension(ALDimension.height, toSize: 2)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: NSNotification.Name(rawValue: "UITextFieldTextDidChangeNotification"), object: self)
    }
    
    open func setPlaceHolder(_ placeholder:String) {
        self.label?.text = placeholder
    }
    
    override open func becomeFirstResponder() -> Bool {
        
        let flag:Bool = super.becomeFirstResponder()
        
        if flag {
            
            if (self.floatingLabel != nil) {
                
                if !self.floating! || (self.text?.isEmpty)! {
                    self.floatLabelToTop()
                    self.floating = true
                }
            } else {
                self.label?.textColor = kDefaultActiveColor
                self.label?.layer.opacity = 0
            }
            self.showActiveBorder()
        }
        
        self.active = flag
        return flag
    }
    
    override open func resignFirstResponder() -> Bool {
        
        let flag:Bool = super.resignFirstResponder()
        
        if flag {
            
            if (self.floatingLabel != nil) {
                
                if self.floating! && (self.text?.isEmpty)! {
                    self.animateLabelBack()
                    self.floating = false
                }
            } else {
                if (self.text?.isEmpty)! {
                    self.label?.layer.opacity = 1
                }
            }
            self.label?.textColor = kDefaultInactiveColor
            self.showInactiveBorder()
            self.validate()
        }
        
        self.active = flag
        return flag
        
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let borderColor = (self.hasError)! ? kDefaultErrorColor : kDefaultInactiveColor
        
        let textRect = self.textRect(forBounds: rect)
        if let context = UIGraphicsGetCurrentContext() {
            let borderlines : [CGPoint] = [CGPoint(x: 0, y: textRect.height - 1),
                CGPoint(x: textRect.width, y: textRect.height - 1)]
            
            if  self.isEnabled  {
                
                context.beginPath();
                context.addLines(between:borderlines);
                context.setLineWidth(1.0);
                context.setStrokeColor(borderColor.cgColor);
                context.strokePath();
                
            } else {
                
                context.beginPath();
                context.addLines(between:borderlines);
                context.setLineWidth(1.0);
                let  dashPattern : [CGFloat]  = [2, 4]
                context.setLineDash(phase:0, lengths:dashPattern);
                context.setStrokeColor(borderColor.cgColor);
                context.strokePath();
                
            }
        }
    }
    
    func textDidChange(_ notif: Notification) {
        self.validate()
    }
    
    func floatLabelToTop() {
        if let label = self.label {
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                label.textColor = self.kDefaultActiveColor
            }
            
            let anim2 = CABasicAnimation(keyPath: "transform")
            let fromTransform = CATransform3DMakeScale(CGFloat(1.0), CGFloat(1.0), CGFloat(1))
            var toTransform = CATransform3DMakeScale(CGFloat(0.5), CGFloat(0.5), CGFloat(1))
            toTransform = CATransform3DTranslate(toTransform, -label.frame.width/2, -label.frame.height, 0)
            anim2.fromValue = NSValue(caTransform3D: fromTransform)
            anim2.toValue = NSValue(caTransform3D: toTransform)
            anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim2]
            animGroup.duration = 0.3
            animGroup.fillMode = kCAFillModeForwards;
            animGroup.isRemovedOnCompletion = false;
            label.layer.add(animGroup, forKey: "_floatingLabel")
            self.clipsToBounds = false
            CATransaction.commit()
        }
    }
    
    func showActiveBorder() {
        if let activeBorder = self.activeBorder {
            activeBorder.layer.transform = CATransform3DMakeScale(CGFloat(0.01), CGFloat(1.0), 1)
            activeBorder.layer.opacity = 1
            CATransaction.begin()
            activeBorder.layer.transform = CATransform3DMakeScale(CGFloat(0.01), CGFloat(1.0), 1)
            let anim2 = CABasicAnimation(keyPath: "transform")
            let fromTransform = CATransform3DMakeScale(CGFloat(0.01), CGFloat(1.0), 1)
            let toTransform = CATransform3DMakeScale(CGFloat(1.0), CGFloat(1.0), 1)
            anim2.fromValue = NSValue(caTransform3D: fromTransform)
            anim2.toValue = NSValue(caTransform3D: toTransform)
            anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            anim2.fillMode = kCAFillModeForwards
            anim2.isRemovedOnCompletion = false
            activeBorder.layer.add(anim2, forKey: "_activeBorder")
            CATransaction.commit()
        }
    }
    
    func animateLabelBack() {
        if let label = self.label {
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                label.textColor = self.kDefaultInactiveColor
            }
            
            let anim2 = CABasicAnimation(keyPath: "transform")
            var fromTransform = CATransform3DMakeScale(0.5, 0.5, 1)
            fromTransform = CATransform3DTranslate(fromTransform, -label.frame.width/2, -label.frame.height, 0);
            let toTransform = CATransform3DMakeScale(1.0, 1.0, 1)
            anim2.fromValue = NSValue(caTransform3D: fromTransform)
            anim2.toValue = NSValue(caTransform3D: toTransform)
            anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim2]
            animGroup.duration = 0.3
            animGroup.fillMode = kCAFillModeForwards;
            animGroup.isRemovedOnCompletion = false;
            
            label.layer.add(animGroup, forKey: "_animateLabelBack")
            CATransaction.commit()
        }
    }
    
    func showInactiveBorder() {
        if let activeBorder = self.activeBorder {
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                activeBorder.layer.opacity = 0
            }
            let anim2 = CABasicAnimation(keyPath: "transform")
            let fromTransform = CATransform3DMakeScale(1.0, 1.0, 1)
            let toTransform = CATransform3DMakeScale(0.01, 1.0, 1)
            anim2.fromValue = NSValue(caTransform3D: fromTransform)
            anim2.toValue = NSValue(caTransform3D: toTransform)
            anim2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            anim2.fillMode = kCAFillModeForwards
            anim2.isRemovedOnCompletion = false
            activeBorder.layer.add(anim2, forKey: "_activeBorder")
            CATransaction.commit()
        }
    }
    
    open func performValidation(_ isValid:Bool,message:String) {
        if !isValid {
            self.hasError = true
            self.errorMessage = message
            self.labelTextColor = kDefaultErrorColor
            self.activeBorder?.backgroundColor = kDefaultErrorColor
            self.setNeedsDisplay()
        } else {
            self.hasError = false
            self.errorMessage = nil
            self.labelTextColor = kDefaultActiveColor
            self.activeBorder?.backgroundColor = kDefaultActiveColor
            self.setNeedsDisplay()
        }
    }
    
    open func validate() {
        
        if self.validationType != nil {
            var message : String = ""
            
            if self.validationType == .email {
                if let emailValidationBlock = self.emailValidationBlock,
                let text = self.text {
                    let isValid = emailValidationBlock(text, &message)
                    performValidation(isValid,message: message)
                }
                
            } else if self.validationType == .number {
                if let numberValidationBlock = self.numberValidationBlock,
                let text = self.text {
                    let isValid = numberValidationBlock(text, &message)
                    performValidation(isValid,message: message)
                }
            }
            
            if let customValidationBlock = self.customValidationBlock,
                let text = self.text {
                let isValid = customValidationBlock(text, &message)
                performValidation(isValid,message: message)
            }
        }
    }
}

extension EGFloatingTextField {
        
}
