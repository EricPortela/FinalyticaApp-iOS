//
//  HorizontalQuickAnalysisCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-07-24.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class HorizontalQuickAnalysisCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    struct historicalGrowthData: Codable {
        var growthValues = [Double]()
        var absoluteValues = [Double]()
        var periods = [String]()
    }
    
    var historicalData = historicalGrowthData()
    var testArray: [dataHorizontalAnalysis] = []
    
    let closedCellHeight = 100
    let cellWidth = UIScreen.main.bounds.size.width - 40
    
    let pieChart: PieChartView = {
        let chart = PieChartView()
        chart.minOffset = 0
        chart.holeRadiusPercent = 0.9
        chart.holeColor = .clear
        chart.legend.enabled = false
        return chart
    }()
    
    let implicationLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.font = UIFont(name: "HelveticaNeue", size: 14)
        lbl.text = "Short text implication of the average value of the analysed data."
        return lbl
    }()
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    let historicalCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    let expandMinimizeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        return btn
    }()
    
    private func addConstraints() -> Void {
        var constraints = [NSLayoutConstraint]()
        
        //Add constraints
        constraints.append(historicalCollectionView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(historicalCollectionView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor))
        constraints.append(historicalCollectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(historicalCollectionView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 100))

        //Activate constraints
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setUpView() -> Void {
        self.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        
        //Pie Chart
        let yPositionChart = CGFloat(closedCellHeight - 60)/2
        createFrameLeft(view: pieChart, width: 60, height: 60, x: 10, y: yPositionChart)
        
        //Button
        let yPositionButton = CGFloat(closedCellHeight - 15)/2
        createFrameRight(view: expandMinimizeButton, width: 15, height: 15, xFromRight: 10, y: yPositionButton)
        
        //Implication label
        let lblWidth = cellWidth - 10 - 60 - 10 - 15 - 20
        let xPositionLbl = CGFloat(10 + 60 + 10)
        let yPositionLbl = CGFloat(closedCellHeight - 80)/2
        createFrameLeft(view: implicationLabel, width: lblWidth, height: 80, x: xPositionLbl, y: yPositionLbl)
        
        
        //CollectionView (Historical Values)
        
        //Delegate and DataSource
        historicalCollectionView.dataSource = self
        historicalCollectionView.delegate = self
        
        //Register
        historicalCollectionView.register(HistoryGrowthCollectionViewCell.self, forCellWithReuseIdentifier: "historyCell")
        
        //Layout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: cellWidth, height: 25)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        historicalCollectionView.collectionViewLayout = layout
        
        //Constraints
        self.addSubview(historicalCollectionView)
        addConstraints()
    }
    
    private func createFrameLeft(view: UIView, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) -> Void {
        view.frame = CGRect(x: x, y: y, width: width, height: height)
        self.addSubview(view)
    }
    
    private func createFrameRight(view: UIView, width: CGFloat, height: CGFloat, xFromRight: CGFloat, y: CGFloat) -> Void {
        let x = CGFloat(cellWidth - xFromRight - width)
        view.frame = CGRect(x: x, y: y, width: width, height: height)
        self.addSubview(view)
    }
    
    private func negativePositiveColor(value: Double) -> Array<UIColor> {
        var color: [UIColor] = [] //If value == 0
        
        if value > 0 {
            let colorOne = UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00) //Green
            let colorTwo = UIColor.gray
            color.append(colorOne)
            color.append(colorTwo)
        }
            
        else if value >= 1 {
            let colorOne = UIColor(red: 0.01, green: 0.81, blue: 0.64, alpha: 1.00) //Green
            color.append(colorOne)
        }
        
        else if value < 0 {
            let colorOne = UIColor(red: 0.89, green: 0.00, blue: 0.40, alpha: 1.00) //Red
            color.append(colorOne)
        }
        return color
    }
    
    public func preparePieChart(avgValue: Double) -> Void {
        let dataColor = negativePositiveColor(value: avgValue)
        var entries = [ChartDataEntry]()
        
        if avgValue > 0 && avgValue < 1 {
            entries.append(ChartDataEntry(x: 0, y: avgValue))
            entries.append(ChartDataEntry(x: 1, y: 1-avgValue))
        }
        else {
            entries.append(ChartDataEntry(x: 0, y: 1))
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.drawValuesEnabled = false
        dataSet.colors = dataColor //Color for dataset
        dataSet.selectionShift = 0 //Removes the offsets and makes chart "big"/use all space to the edges
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.notifyDataSetChanged()
    }
    
    /*
    public func configureNestedCollectionView(growthValues: Array<Double>, absoluteValues: Array<Double>, periods: Array<String>) -> Void {
        historicalData = historicalGrowthData(growthValues: growthValues, absoluteValues: absoluteValues, periods: periods)
        historicalCollectionView.reloadData()
    }
    */
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//REMOVE EXTENSION
extension HorizontalQuickAnalysisCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historicalData.periods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = historicalCollectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for: indexPath) as? HistoryGrowthCollectionViewCell
        
        cell?.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        cell?.changeLbl.text = String(format: "%.2f", historicalData.growthValues[indexPath.row])
        cell?.periodLbl.text = historicalData.periods[indexPath.row]
        
        return cell!
    }
}
