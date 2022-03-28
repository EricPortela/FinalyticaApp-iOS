//
//  PressReleaseTableViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-01-21.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class PressReleaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let labelWidth = Int(UIScreen.main.bounds.size.width - 90)
    let cellHeight = 80
    
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        label.numberOfLines = 0
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        return label
    }()
    
    func drawLine(start: CGPoint, end: CGPoint) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00).cgColor
        shape.lineWidth = 2.0
        
        self.layer.addSublayer(shape)
    }
    
    func drawCircle(center: CGPoint) {
        let startAngle = CGFloat(0)
        let endAngle = CGFloat(Double.pi * 2)
        
        let circlePath = UIBezierPath(arcCenter: center, radius: CGFloat(5), startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let shape = CAShapeLayer()
        shape.path = circlePath.cgPath
        
        shape.lineWidth = 2
        shape.fillColor = .none
        shape.strokeColor = UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00).cgColor
        
        self.layer.addSublayer(shape)
    }
    
    func setUpViews() {
        titleLabel.frame = CGRect(x: 35 , y: 22, width: labelWidth, height: 50)
        addSubview(titleLabel)
        
        subTitleLabel.frame = CGRect(x: 35 , y: (22 + Int(titleLabel.frame.size.height) + 2), width: labelWidth, height: 14)
        addSubview(subTitleLabel)
        
        //Vertical, purple line to the left
        let start = CGPoint(x:1, y:0)
        let end = CGPoint(x: 1, y: 100)
        drawLine(start: start, end: end)
        
        //Horizontal
        let hStart = CGPoint(x: 1, y: cellHeight/2)
        let hEnd = CGPoint(x: 20, y: cellHeight/2)
        drawLine(start: hStart, end: hEnd)
        
        //Draw circle
        let center = CGPoint(x: 24, y: cellHeight/2)
        drawCircle(center:center)
    }

}



class KPICellOne: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imgViewHeight : CGFloat = 26
    let imgViewWidth : CGFloat = 26
    
    let lblViewHeight : CGFloat = 20
    let lblViewWidth : CGFloat = 120
    
    let cellHeight : CGFloat = 110
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        label.text = "CustomCellOne"
        return label
    }()
    
    let iconImage: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    let shape: CAShapeLayer = {
        let layerShape = CAShapeLayer()
        return layerShape
    }()
    
    func positionLabel(lblView: UILabel) {
        let spacing = (CGFloat(cellHeight) - imgViewHeight - imgViewWidth) / 3
        let x = (165 - lblViewWidth) / 2
        let y = (spacing*2) + imgViewHeight
        
        //Create the frame size for UILabel
        let lblFrame = CGRect(x: x, y: y, width: lblViewWidth, height: lblViewHeight)

        //Attach frame
        lblView.frame = lblFrame
    }
    
    func positionImage(imgView: UIImageView) {
        let spacing = (CGFloat(cellHeight) - imgViewHeight - imgViewWidth) / 3
        let x = (165 - imgViewWidth) / 2
        let y = spacing
          
        //Create the frame size for UIImageView + UILabel
        let imgFrame = CGRect(x: x, y: y, width: imgViewWidth, height: imgViewHeight)
        
        //Attach frame
        imgView.frame = imgFrame
    }
    
    func drawLine(start: CGPoint, end: CGPoint) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00).cgColor
        shape.lineWidth = 2.0
        
        self.layer.addSublayer(shape)
    }
    
    func setUpViews() {
        layer.cornerRadius = 5
        backgroundColor = UIColor.clear//tertiarySystemBackground
        
        //UILabel
        addSubview(nameLabel)
        positionLabel(lblView: nameLabel)
        
        //UIImageView
        addSubview(iconImage)
        positionImage(imgView: iconImage)
        
        //UIBezierPath
        
        let start = CGPoint(x:1, y:0)
        let end = CGPoint(x: 1, y: 110)
        drawLine(start: start, end: end)
    }
}


class KPICellTwo: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellWidth = UIScreen.main.bounds.width - 30
    let lblViewHeight : CGFloat = 20
    let cellHeight : CGFloat = 100

    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        label.text = "CustomCellTwo"
        return label
    }()
     
    func positionLabel(lbl: UILabel) {
        let lblViewWidth = cellWidth - 40
        let x = (cellWidth  - lblViewWidth) / 2
        let y = (100 - lblViewHeight) / 2

        //Create the frame size for UILabel
        let lblFrame = CGRect(x: x, y: y, width: lblViewWidth, height: lblViewHeight)

        //Attach frame
        lbl.frame = lblFrame
    }

    func setUpViews() {
        backgroundColor = UIColor.tertiarySystemBackground
        layer.cornerRadius = 5
        addSubview(nameLabel)
        positionLabel(lbl: nameLabel)
    }
}
