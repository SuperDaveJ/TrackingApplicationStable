//
//  SpeedView.swift
//  locationServicesTest2
//
//  Created by Dave Johnson on 12/6/17.
//  Copyright © 2017 Paycom. All rights reserved.
//

import UIKit

@IBDesignable

class SpeedView: UIView {
    
    let percentLabel = UILabel()
    var range: CGFloat = 10
    
    var curValue: CGFloat = 0 {
        didSet {
            animate()
        }
    }
    let margin: CGFloat = 10
    
    let bgLayer = CAShapeLayer()
    @IBInspectable var bgColor: UIColor = UIColor.gray {
        didSet {
            configure()
        }
    }
    
    let fgLayer = CAShapeLayer()
    @IBInspectable var fgColor: UIColor = UIColor.init(red: 3.0/255.0, green: 168.0/255.0, blue: 222.0/255.0, alpha: 1.0) {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
        configure()
    }
    
    
    func setup() {
        
        // Set background layer
        bgLayer.lineWidth = 20.0
        bgLayer.fillColor = nil
        bgLayer.strokeEnd = 1
        layer.addSublayer(bgLayer)
        
        // Set foreground layer
        fgLayer.lineWidth = 20.0
        fgLayer.fillColor = nil
        fgLayer.strokeEnd = 0
        layer.addSublayer(fgLayer)
        
        // Setup MPH label
        percentLabel.font = UIFont.systemFont(ofSize: 26)
        percentLabel.textColor = UIColor.green
        percentLabel.text = ""
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(percentLabel)
        
        // Setup constraints
        let percentLabelCenterX = percentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let percentLabelCenterY = percentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -margin)
        NSLayoutConstraint.activate([percentLabelCenterX, percentLabelCenterY])
        
    }
    
    func configure() {
        
        bgLayer.strokeColor = bgColor.cgColor
        fgLayer.strokeColor = fgColor.cgColor
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        setupShapeLayer(shapeLayer: bgLayer)
        setupShapeLayer(shapeLayer: fgLayer)
    }
    
    private func setupShapeLayer(shapeLayer: CAShapeLayer) {
        
        shapeLayer.frame = self.bounds
        let startAngle = degreesToRadians(135.0)
        let endAngle = degreesToRadians(45.0)
        let center = percentLabel.center
        let radius = shapeLayer.frame.width * 0.35
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer.path = path.cgPath
    }
    
    private func animate() {
        
        var fromValue = fgLayer.strokeEnd
        let toValue = curValue / range
 
        if let presentationLayer = fgLayer.presentation() {
            
            fromValue = presentationLayer.strokeEnd
        }
        
        let percentChange = abs(fromValue - toValue)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue = fromValue
        animation.toValue = toValue
        //animation.duration = CFTimeInterval(2)
        animation.duration = CFTimeInterval(percentChange * 9)
        fgLayer.removeAnimation(forKey: "stroke")
        fgLayer.add(animation, forKey: "stroke")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fgLayer.strokeEnd = toValue
        CATransaction.commit()
    }
}

let π = CGFloat(Double.pi)

func degreesToRadians (_ value:CGFloat) -> CGFloat {
    return value * π / 180.0
}

func radiansToDegrees (_ value:CGFloat) -> CGFloat {
    return value * 180.0 / π
}


