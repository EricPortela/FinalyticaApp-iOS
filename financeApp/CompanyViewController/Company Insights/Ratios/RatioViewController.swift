//
//  KPIViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-10-03.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit

class RatioViewController: UIViewController {
        
    @IBOutlet weak var ratioCategoryCollectionView: UICollectionView!
    
    let kpiTypes = ["Valuation", "Leverage (Capital Strenght)", "Liquidity", "Profitability", "Compare"]
    let kpiDesc = ["Valuation metrics are values that can give an investor the idea of how much a company may be worth."]
    let ratioImages = ["valuation", "capitalStrength", "liquidity", "profitability", ""]
    let headers = ["Ratio Categories", "Custom Ratio Analysis", "Ratio Definitions"]
    
    var ticker = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratioCategoryCollectionView.delegate = self
        ratioCategoryCollectionView.dataSource = self
                
        ratioCategoryCollectionView.register(CustomCellOne.self, forCellWithReuseIdentifier: "customOne") //Register CustomCellOne
        ratioCategoryCollectionView.register(CustomCellTwo.self, forCellWithReuseIdentifier: "customTwo") //Register CustomCellTwo
        
        ratioCategoryCollectionView.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        
        //let layout = ratioCategoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        //layout?.sectionHeadersPinToVisibleBounds = true //makes the header in UICollectionView sticky
    }
}

class CustomCellOne: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    let imgViewHeight : CGFloat = 26
    let imgViewWidth : CGFloat = 26
    
    let lblViewHeight : CGFloat = 20
    let lblViewWidth : CGFloat = 120
    
    let cellHeight : CGFloat = 110
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
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
        let x = CGFloat(10)
        let y = CGFloat(10)
        
        //Create the frame size for UILabel
        let lblFrame = CGRect(x: x, y: y, width: lblViewWidth, height: lblViewHeight)

        //Attach frame
        lblView.frame = lblFrame
    }
    
    func positionImage(imgView: UIImageView) {
        let spacing = (cellHeight - imgViewHeight - imgViewWidth) / 3
        let x = (165 - imgViewWidth) / 2
        let y = spacing
          
        //Create the frame size for UIImageView + UILabel
        let imgFrame = CGRect(x: x, y: y, width: imgViewWidth, height: imgViewHeight)
        
        //Attach frame
        imgView.frame = imgFrame
    }
    
    func drawLine(start: CGPoint, end: CGPoint, shape: CAShapeLayer) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        //design path in layer
        shape.path = path.cgPath
        shape.strokeColor = UIColor(red: 0.59, green: 0.31, blue: 0.76, alpha: 1.00).cgColor
        shape.lineWidth = 2.0
    }
    
    func setUpViews() {
        layer.cornerRadius = 10
        backgroundColor = UIColor.tertiarySystemBackground
        
        //UILabel
        addSubview(nameLabel)
        positionLabel(lblView: nameLabel)
        
        //UIImageView
        addSubview(iconImage)
        positionImage(imgView: iconImage)
        
        //UIBezierPath
        layer.addSublayer(shape)
        
        //let start = CGPoint(x:1, y:10)
        //let end = CGPoint(x: 1, y: 100)
        //drawLine(start: start, end: end, shape: shape)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomCellTwo: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
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
        backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00) //UIColor.tertiarySystemBackground

        layer.cornerRadius = 5
        addSubview(nameLabel)
        positionLabel(lbl: nameLabel)
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RatioViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = ratioCategoryCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! KPICollectionReusableView
            sectionHeader.classTitle.text = "\(headers[indexPath.section])"
                return sectionHeader
        } else {
            return KPICollectionReusableView()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ratioCategoryCollectionView.dequeueReusableCell(withReuseIdentifier: "customTwo", for: indexPath) as? CustomCellTwo
        
        if indexPath.section == 0 {
            let cell = ratioCategoryCollectionView.dequeueReusableCell(withReuseIdentifier: "customOne", for: indexPath) as? CustomCellOne//as? CategoryRatioCollectionViewCell)
            let img = UIImage(named: "\(ratioImages[indexPath.row])" + ".png")
            cell!.nameLabel.text = "\(kpiTypes[indexPath.row])"
            cell!.iconImage.image = img
            return cell!
        }
        
        else if indexPath.section == 1 {
            cell!.nameLabel.text = "Customize"
            return cell!
        }
        
        cell!.nameLabel.text = "Definitions"
        
        return cell!
    }
     
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if indexPath.section == 0 {
            let popOverVC = storyboard.instantiateViewController(withIdentifier: "historicalKPI") as! KPIViewController
            let category = kpiTypes[indexPath.row]
            popOverVC.kpiCategory = (category) //add the current company name to the variable "company" in FundPopUpViewController
            popOverVC.modalPresentationStyle = .pageSheet
            popOverVC.ticker = ticker
            tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
        }
        else {
            let popOverVC = storyboard.instantiateViewController(withIdentifier: "customAnalysis") as! CustomRatioAnalysisViewController
            popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            popOverVC.ticker = ticker
            tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width : CGFloat
        var height : CGFloat
        
        if indexPath.section == 0 {
            width = 165
            height = 110
        } else {
            let widthDevice = UIScreen.main.bounds.width
            width = widthDevice - 30
            height = 100
        }
        return CGSize(width: width, height: height)
    }

}


/*
extension UIView{
    func addGradientBackground(firstColor: UIColor, secondColor: UIColor){
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 20
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
 */
