//
//  FinancialStatementsCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-16.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class FinancialStatementsCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()        
    }
    
    var financialStatement = [Any]()
    var itemNames = [String]()
    var itemValues = [Double]()
    var incomeStatementArray = [incomeStatement]()
    var balanceSheetArray = [balanceSheetStatement]()
    var cashFlowArray = [cashFlowStatement]()
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    let dropDownMenu: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "Dropdown_1.png")
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    let periodDropDownLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Select period..."
        lbl.font = UIFont(name: "HelveticaNeue", size: 14)
        return lbl
    }()
    
    let statementTypeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        lbl.textColor = .white
        lbl.text = "Income Statement"
        lbl.textAlignment = .left
        return lbl
    }()
    
    let unitsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        lbl.textColor = .gray
        lbl.text = "In Millions USD"
        lbl.textAlignment = .right
        return lbl
    }()
    
    let periodLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        lbl.textColor = .gray
        lbl.text = "FY 20'"
        lbl.textAlignment = .left
        return lbl
    }()
    
    let exceptionsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Light", size: 8)
        lbl.textColor = .white
        lbl.text = "*Except ratios, EPS and EPS diluted."
        lbl.textAlignment = .right
        return lbl
    }()
    
     let collectionView: UICollectionView = {
         let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
         collectionView.showsVerticalScrollIndicator = false
         collectionView.showsHorizontalScrollIndicator = false
         collectionView.backgroundColor = .clear
         return collectionView
     }()
    
    var constraintsArray: [NSLayoutConstraint] = {
        let constraints = [NSLayoutConstraint]()
        return constraints
    }()
    
    func setUpCollectionView() {
        //collectionView.delegate = self
        //collectionView.dataSource = self
        //collectionView.isScrollEnabled = false
        
        let cellWidth = Int(UIScreen.main.bounds.size.width - 40 - 40)
        let cellHeight = Int(30)
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        collectionView.register(FinancialItemCollectionViewCell.self, forCellWithReuseIdentifier: "financialItem")        
    }
    
    func setUpView(){
        
        //Drop Down menu Button
        let menuWidth = UIScreen.main.bounds.size.width - 40 - 40
        let menuHeight = CGFloat(34)
        let xPosMenu = CGFloat(20)
        let yPosMenu = CGFloat(20)
        dropDownMenu.frame = CGRect(x: xPosMenu, y: yPosMenu, width: menuWidth, height: menuHeight)
        self.addSubview(dropDownMenu)
        //addConstraints(view: dropDownMenu)
        
        //Label in Drop Down Menu Button
        let lblWidth1 = UIScreen.main.bounds.size.width - 40 - 60
        let lblHeight1 = CGFloat(26)
        let xPosLbl1 = CGFloat(10)
        let yPosLbl1 = CGFloat(menuHeight - lblHeight1)/2
        periodDropDownLabel.frame = CGRect(x: xPosLbl1, y: yPosLbl1, width: lblWidth1, height: lblHeight1)
        dropDownMenu.addSubview(periodDropDownLabel)
        //addConstraints(view: periodDropDownLabel)
        
        //Statement Type Label
        let lblWidth2 = menuWidth/2
        let lblHeight2 = CGFloat(20)
        let xPosLbl2 = xPosMenu
        let yPosLbl2 = yPosMenu + menuHeight + 14
        statementTypeLabel.frame = CGRect(x: xPosLbl2, y: yPosLbl2, width: lblWidth2, height: lblHeight2)
        self.addSubview(statementTypeLabel)
        //addConstraints(view: statementTypeLabel)
        
        //Units Label
        let lblWidth3 = lblWidth2
        let lblHeight3 = lblHeight2
        let xPosLbl3 = menuWidth/2 + 20
        let yPosLbl3 = yPosLbl2
        unitsLabel.frame = CGRect(x: xPosLbl3, y: yPosLbl3, width: lblWidth3, height: lblHeight3)
        self.addSubview(unitsLabel)
        //addConstraints(view: unitsLabel)
        
        //Period Label
        let lblWidth4 = lblWidth3
        let lblHeight4 = lblHeight3
        let xPosLbl4 = xPosLbl2
        let yPosLbl4 = yPosLbl3 + lblHeight3 + 5
        periodLabel.frame = CGRect(x: xPosLbl4, y: yPosLbl4, width: lblWidth4, height: lblHeight4)
        self.addSubview(periodLabel)
        //addConstraints(view: periodLabel)
        
        //Excptions label
        let lblWidth5 = lblWidth4
        let lblHeight5 = lblHeight4
        let xPosLbl5 = xPosLbl3
        let yPosLbl5 = yPosLbl3 + lblHeight3
        exceptionsLabel.frame = CGRect(x: xPosLbl5, y: yPosLbl5, width: lblWidth5, height: lblHeight5)
        self.addSubview(exceptionsLabel)
        //addConstraints(view: exceptionsLabel)
        
        //CollectionView
        //setUpCollectionView()
        //let xPosCollection = CGFloat(0)
        //let yPosCollection = CGFloat(20) //CGFloat(yPosLbl5 + lblHeight5 + 10)
        //let collectionWidth = UIScreen.main.bounds.size.width - 40
        //let collectionHeight = CGFloat(300)
        //collectionView.frame = CGRect(x: xPosCollection, y: yPosCollection, width: collectionWidth, height: collectionHeight)
        //self.addSubview(collectionView)
        //addConstraints(view: collectionView)
    }
    
    private func addConstraints(view: UIView) {
        //var constraints = [NSLayoutConstraint]()
        
        //Append/add
        let leading = view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
        let trailing = view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        let bottom = view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        let top = view.topAnchor.constraint(equalTo: self.topAnchor, constant: 130)
        let height = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 300)
        
        height.priority = UILayoutPriority(999)
                        
        let width = UIScreen.main.bounds.size.width - 40
        let widthAnchor = view.widthAnchor.constraint(equalToConstant: width)
        /*
        let heightConstraint = NSLayoutConstraint(item: collectionView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        heightConstraint.constant = height
        collectionView.layoutIfNeeded()
        */
        
        //let widthAnchor = view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        //let heightAnchor = view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        
        constraintsArray = [leading, trailing, bottom, top, widthAnchor, height]
        
        //Activate constraints
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate(constraintsArray)
    }
    
    func financialStatement(urlString: String){
        self.incomeStatementArray.removeAll()
        self.balanceSheetArray.removeAll()
        self.cashFlowArray.removeAll()

        let url = URL(string: urlString)
        
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared


        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                               
                do {
                    if urlString.contains("income-statement") {
                        let incomeStatementFeed = try decoder.decode([incomeStatement].self, from: data!)
                        if let latestPeriod = incomeStatementFeed.first {
                            self.incomeStatementArray.append(latestPeriod)
                        }
                        //self.incomeStatementArray = incomeStatementFeed
                    }
                    else if urlString.contains("balance-sheet-statement") {
                        let balanceSheetFeed = try decoder.decode([balanceSheetStatement].self, from: data!)
                        self.balanceSheetArray = balanceSheetFeed
                    }
                    else if urlString.contains("cash-flow-statement") {
                        let cashFlowFeed = try decoder.decode([cashFlowStatement].self, from: data!)
                        self.cashFlowArray = cashFlowFeed
                    }

                    DispatchQueue.main.async {
                        let incomeStatementContent = self.getIncomeStatement(rawIncomeStatement: self.incomeStatementArray)
                        self.itemNames = incomeStatementContent.0
                        self.itemValues = incomeStatementContent.1
                        self.collectionView.reloadData()
                        
                        //let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
                        //self.dynamicHeightAdjustment(view: self.collectionView, height: height)
                        //self.collectionView.reloadData()
                    }
                }
                catch {
                    print("Error in JSON parsing")
                }
            }
        }
        dataTask.resume()
    }
    
    func dynamicHeightAdjustment(view: UIView, height: CGFloat) {
        NSLayoutConstraint.deactivate(constraintsArray)
        
        //let height = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
        let width = UIScreen.main.bounds.size.width - 40
        
        let widthAnchor = view.widthAnchor.constraint(equalToConstant: width)
        let heightAnchor = view.heightAnchor.constraint(equalToConstant: height)
        
        let xPosition = view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let topAnchor = view.topAnchor.constraint(equalTo: self.topAnchor, constant: 130)
        let bottomAnchor = view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
       
        let newConstraints: [NSLayoutConstraint] = [widthAnchor, heightAnchor, xPosition, topAnchor, bottomAnchor]
        
        //Activate constraints
        NSLayoutConstraint.activate(newConstraints)
        //view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func getIncomeStatement(rawIncomeStatement: Array<incomeStatement>) -> (Array<String>, Array<Double>) {
        var itemValues = [Double]()
        let itemNames = ["revenue", "costOfRevenue", "grossProfit", "grossProfitRatio", "researchAndDevelopmentExpenses", "generalAndAdministrativeExpenses", "sellingAndMarketingExpenses", "sellingGeneralAndAdministrativeExpenses", "otherExpenses", "operatingExpenses", "costAndExpenses", "interestExpense", "depreciationAndAmortization", "ebitda", "ebitdaratio", "operatingIncome", "operatingIncomeRatio", "totalOtherIncomeExpensesNet", "incomeBeforeTax", "incomeBeforeTaxRatio", "incomeTaxExpense", "netIncome", "netIncomeRatio", "eps", "epsDiluted", "weightedAverageShsOut", "weightedAverageShsOutDil"]
        let latestData = rawIncomeStatement[0]
        let mirror = Mirror(reflecting: latestData)
        
        for item in itemNames {
            for child in mirror.children {
                 if item == child.label {
                     if let itemValue = child.value as? Double {
                        itemValues.append(itemValue)
                     }
                 }
            }
        }
        return (itemNames, itemValues)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/*
extension FinancialStatementsCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "financialItem", for: indexPath) as? FinancialItemCollectionViewCell
        cell?.itemName.text = itemNames[indexPath.row].uppercased()
        cell?.itemValue.text = String(format: "%.2f", itemValues[indexPath.row])
        return cell!
    }
}
 */
