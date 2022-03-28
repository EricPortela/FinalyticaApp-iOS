//
//  historicalKPIViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-11-28.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class historicalKPIViewController: UIViewController {
    
    @IBOutlet weak var titleHistoricalKPI: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var customTableView: UITableView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var kpiType = String()
    
    var years : [String] = []
    
    weak var axisFormatDelegate : IAxisValueFormatter?
    
    var quarterlyRatiosDates : [Date] = []
    var quarterlyRatiosDict = [String() : [String : Any]()]
    let dateFormatter1 = DateFormatter()
    let dateFormatter2 = DateFormatter()
    
    var ratiosArray = [String]()
    var datesArray = [String]()
    
    var timePeriod = String()
    
    var ticker = String()
    
    func getRatioLink(period : String) -> String{
        var ratioLink = ""
        if period == "Q" {
            ratioLink = "https://financialmodelingprep.com/api/v3/ratios/\(self.ticker)?period=quarter&limit=40&apikey=\(apiKey)"
        }else if period == "Y" {
            ratioLink = "https://financialmodelingprep.com/api/v3/ratios/\(self.ticker)?limit=40&apikey=\(apiKey)"
        }
        return ratioLink
    }
    
    func getQuarterlyRatios(urlLink : String ) {
        self.dateFormatter1.dateFormat = "yyyy-MM-dd"
        
        self.quarterlyRatiosDates.removeAll()

        //Retrieve quarterly ratio data
        guard let url = URL(string: urlLink) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, err) in
              guard let data = data else { return }
                do {
                  if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                      DispatchQueue.main.async{ //https://medium.com/@broebling/dispatchqueue-main-the-main-queue-is-a-serial-queue-4607417fe535 or check "search documentation in swift" under "Updating UI from a Completion Handler"
                          
                          for quarterlyRatios in json { //Iterate through the data array
                              if let dataset = quarterlyRatios as? Dictionary<String, Any> { //Handle optional values, in case the retrived data is nil
                                  if let strDate = dataset["date"] as? String { //Handle optional values, in case the date is nil
                                      self.quarterlyRatiosDict[strDate] = dataset //Populate the dictionary with date as key and the retrieved data for that date, as value
                                      if let date = self.dateFormatter1.date(from: strDate) {
                                          self.quarterlyRatiosDates.append(date) //Append all quarterly dates to the array
                                          self.quarterlyRatiosDates.sorted()
                                      }
                                  }
                              }
                          }
                       
                       //When upper iteration is finished and all data has been added to our dict and array, keep working from this point
                       
                       let lastEightYears = self.quarterlyRatiosDates.prefix(15)
                       var kpiDict = [String : NSNumber]()
                       
                        for date in lastEightYears /*self.quarterlyRatiosDates*/ {
                           self.dateFormatter1.dateFormat = "yyyy-MM-dd"
                           let strDate = self.dateFormatter1.string(from: date)
                            self.years.append(strDate)
                            
                           let quarterlyData = self.quarterlyRatiosDict[strDate]
                            if let kpiVal = (quarterlyData![self.kpiType]) {
                               kpiDict[strDate] = (kpiVal) as? NSNumber
                           }
                       }
                        let orderedYears = self.years.sorted(by: {$0.compare($1) == .orderedAscending})
                        self.barChart(dict: kpiDict, yearsArray: orderedYears) //Call function and insert the kpiDict made above as parameter
                      }
                  }
              } catch let jsonErr {
                  print("Error serializing json:", jsonErr)
                }
            }.resume()
        }

    
    func barChart(dict : Dictionary<String, NSNumber>, yearsArray: Array<String>) {
        var entry = [BarChartDataEntry]()
        var c = 0
        
        for year in yearsArray {
            if let value = dict[year] {
                
                //1. For Bar-chart
                let strValue = (String(format: "%.3f", Float(value)))
                var roundedValue = Double(value)
                let dataEntry = BarChartDataEntry(x: Double(c), y: Double(roundedValue), data: yearsArray as AnyObject?)
                entry.append(dataEntry)
                
                //2. For UITableView (customTableView)
                self.ratiosArray.append(strValue)
                self.datesArray.append(year)
            }
            c += 1
        }
        
        ratiosArray.reverse()
        datesArray.reverse()
        
        customTableView.reloadData()
        let extraSpaces = CGFloat(79 + 20 + 292)
        let totalHeight = customTableView.contentSize.height
        viewHeight.constant = CGFloat(totalHeight + extraSpaces)
        tableViewHeight.constant = CGFloat(customTableView.contentSize.height)
        
        let set = BarChartDataSet(entries: entry, label: "")
        set.colors = [UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)]
        set.valueColors = [UIColor.white] //Colors for y-axis values inside chart/above each bar

        let data = BarChartData(dataSet: set)
        barChart.xAxis.valueFormatter = axisFormatDelegate
        barChart.data = data

        //Editing the chart generally
        barChart.animate(yAxisDuration: 1.0, easingOption: .easeInOutQuart)
        //barChart.setVisibleXRangeMaximum(10) //a bug appeared when user scrolls too fast, which made the barchartview smaller/resized
        barChart.legend.enabled = false //remove the legend/color box
        barChart.extraBottomOffset = 60
        barChart.doubleTapToZoomEnabled = false //remove double tap zoom
        barChart.pinchZoomEnabled = false //remove pinch zoom
        barChart.setScaleEnabled(false) //removes all zoom/scaling
        
        //y-Axis editing (leftAxis and rightAxis)
        barChart.leftAxis.enabled = false //disables everything on leftaxis (labels, gridlines, etc)

        barChart.rightAxis.enabled = false
        barChart.rightAxis.gridLineDashLengths = [4,4]
        barChart.rightAxis.labelTextColor = .white

        //x-Axis editing
        barChart.xAxis.labelTextColor = .white
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.labelRotationAngle = -90
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        }
    
    func convertCamelCase(camelCase: String) -> String {
        var word = String()
        
        var count = 0
        for i in camelCase{
            if i.isUppercase == true{
                word += " \(i)"
            } else if count == 0{
                word += String(i.uppercased())
            } else{
                word += String(i)
            }
            count += 1
        }
        return word
    }
    
    func prepareTitle() {
        var period = String()
        if timePeriod == "Q" {
            period = "quarterly"
        } else {
            period = "yearly"
        }
        
        let kpiName = convertCamelCase(camelCase: kpiType)
        
        titleHistoricalKPI.text = "Historical \(period) values for \(kpiName)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = self

        //Get quarterly financial data
        let ratioLink = getRatioLink(period: timePeriod)
        getQuarterlyRatios(urlLink: ratioLink)
        
        prepareTitle()
        
        customTableView.register(customHistoricalKPICell.self, forCellReuseIdentifier: "customCell")
    }
}


extension historicalKPIViewController : IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let sortedYears = years.sorted(by: {$0.compare($1) == .orderedAscending})
        return sortedYears[Int(value)]
    }
}

class customHistoricalKPICell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        
        setUpViews()
        
        labelArray = [ratioLabelOne, ratioLabelTwo, ratioLabelThree]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelArray = [UILabel]()
    
    let imgViewHeight : CGFloat = 26
    let imgViewWidth : CGFloat = 26
    
    let lblViewHeight : CGFloat = 20
    let lblViewWidth : CGFloat = 120
    
    let cellHeight : CGFloat = 110
        
    var ratioLabelOne: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
    
    var ratioLabelTwo: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
    
    var ratioLabelThree: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 11)
        label.text = "CustomCell"
        label.numberOfLines = 0
        return label
    }()
        
    func setUpViews() {
        backgroundColor = UIColor.clear
                
        //UILabel
        let width = Int(UIScreen.main.bounds.width)
        
        let spacing = 20
        var lblWidth = Int()
        
        lblWidth = (width-((4)*spacing))/3
        
        let allLabels = [ratioLabelOne, ratioLabelTwo, ratioLabelThree]
        
        for i in allLabels {
            i.removeFromSuperview()
        }
        
        for i in 0..<3 {
            let ratioLabel = allLabels[i]
            
            let lblHeight = 10
            let accumulatedSpacing = spacing*(i+1)
            let accumulatedlblWidth = lblWidth*i
            let xStart = accumulatedlblWidth + accumulatedSpacing
            let yStart = 10
            let frame = CGRect(x: xStart, y: yStart, width: lblWidth, height: lblHeight)
            ratioLabel.frame = frame
            ratioLabel.text = "n/A"
            addSubview(ratioLabel)
        }
    }
}


extension historicalKPIViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratiosArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = customTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? customHistoricalKPICell
                
        if ratiosArray.count != 0 && datesArray.count != 0 {
            let rowDataOne = datesArray[indexPath.row]
            let rowDataTwo = ratiosArray[indexPath.row]
            
            cell?.ratioLabelOne.text = rowDataOne
            cell?.ratioLabelTwo.text = "\(rowDataTwo)"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = Int(customTableView.contentSize.width)
        
        let headerHeight = 90
        
        let headerView = UIView(frame: (CGRect(x: 0, y: 0, width: width, height: headerHeight)))
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)
        topLine.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        topLine.frame = CGRect(x: 20, y: 0, width: width-40, height: 6)
        headerView.backgroundColor = .clear
        headerView.addSubview(topLine)

        let headerLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 250, height: 15))
        headerLabel.text = "HISTORICAL VALUES"
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        headerView.addSubview(headerLabel)

        let bottomLine = UIView()
        bottomLine.backgroundColor = .lightGray
        bottomLine.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        bottomLine.frame = CGRect(x: 20, y: 89, width: width-40, height: 1)
        headerView.addSubview(bottomLine)
        
        let spacing = 20
        var lblWidth = Int()
        
        lblWidth = (width-((4)*spacing))/3

        let labelArray = ["Date", "Value", "Change (%)"]
        
        for i in 0..<3 {
            let label = UILabel()
            
            let lblHeight = 15
            let accumulatedSpacing = spacing*(i+1)
            let accumulatedlblWidth = lblWidth*i
            let xStart = accumulatedlblWidth + accumulatedSpacing
            let yStart = 60
            let frame = CGRect(x: xStart, y: yStart, width: lblWidth, height: lblHeight)
            
            label.frame = frame
            label.font = UIFont(name: "HelveticaNeue", size: 11)
            label.textAlignment = .center
            label.numberOfLines = 0
                        
            let nameLbl = labelArray[i]
            label.text = nameLbl
            headerView.addSubview(label)
        }
        
        return headerView
    }
}





/*
if pctChangeRounded > 0 { //if percentage change is positive use blue color
    cell?.percentageChangeFromLastPeriod.textColor = UIColor(red: 0.09, green: 0.56, blue: 0.80, alpha: 1.00)
} else if pctChange < 0{ //if percentage change is positive use red color
    cell?.percentageChangeFromLastPeriod.textColor = UIColor(red: 0.81, green: 0.12, blue: 0.66, alpha: 1.00)
} else { //if percentage change is 0 use white color
    cell?.percentageChangeFromLastPeriod.textColor = UIColor.white
}
*/
