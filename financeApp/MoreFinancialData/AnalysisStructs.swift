//
//  AnalysisStructs.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-03.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation

struct dataHorizontalAnalysis: Codable {
    ///Boolean variable to enable expansion/minimization of cell section
    var isExpanded: Bool
    
    ///Name of the item, eg. Revenue, EPS, Net Income, etc.
    var itemName: String
    
    ///Absolute value for the item (multiple periods, hence array). Values as presented in the financial statement.
    var valuesRegularStatement: [Double]
    
    ///Values for the horizontal item growth (multiple periods, hence array). Values display changes/growth as decimal.
    var valuesGrowthStatement: [Double]
    
    ///Values for the horizontal item growth (multiple periods, hence array). Values display changes/growth as decimal. Values are compared to a base year.
    var valuesHorizontalAnalysis: [Double]
    
    ///Annual Average Growth Rate for the specific financial item during a selected period
    var aagr: Double
    
    ///Selected periods, eg. 2020, 2019, 2018, or Q4-20, Q3-20,  Q2-20, etc.
    var periods: [String]
    
    func standardDeviation() -> Double {
        let dataPoints = Double(valuesRegularStatement.count)
        
        let sumOne = valuesRegularStatement.reduce(0, +)
        let mean = sumOne / dataPoints
        
        var numerator: [Double] = []
        
        for x in valuesRegularStatement {
            let absoluteVal = abs(x-mean)
            let squaredVal = pow(absoluteVal, 2)
            numerator.append(squaredVal)
        }
        
        let sumTwo = numerator.reduce(0, +)
        var stdDev = sumTwo/dataPoints
        stdDev = sqrt(stdDev)
                
        return stdDev
    }
    
    func trendAnalysis() {
        
    }
}

struct horizontalAnalysisItem {
    var isExpanded: Bool
    var name: String
    var increasePositive: Bool
    var average: Double
    //var growthValues: [Double]
    var growthValues: [Double]
    var periods: [String]
    
    func onlyPositive(array: Array<Double>) -> Bool {
        if array.allSatisfy({ $0 > 0 }) == true {
            return true
        }
        return false
    }
    
    func onlyNegative(array: Array<Double>) -> Bool{
        if array.allSatisfy({ $0 < 0 }) == true {
            return true
        }
        return false
    }
    
    func atLeastNeutral(array: Array<Double>) -> Bool{
        if array.allSatisfy({ $0 >= 0 }) == true {
            return true
        }
        return false
    }
    
    func halfNeutral(array: Array<Double>) -> (Bool) {
        let halfOfHalf = Int(growthValues.count/2)/2
        var count = 0
        
        for i in array {
            if i >= 0 {
                count += 1
            }
        }
        
        if count >= halfOfHalf {
            return true
        }
        return false
    }
    
    func findNegativeYears(values: Array<Double>, periods: Array<String>) -> String{
        var count = 0
        var negativeYears: String = ""
                    
        for i in values {
            if i < 0 {
                let negativeYear = periods[count]
                if negativeYear.count != 0 {
                    negativeYears += (" ," + negativeYear)
                } else {
                    negativeYears += negativeYear
                }
            }
            count += 1
        }
        return negativeYears
    }
    
    //ABOUT PARAMETERS (consistency)
    //begginingHalf --> Oldest data of half of the period
    //half --> 50% of the datapoints (Int)
    //AAGR --> Annual Average Growth Rate ==> Shortly said, the average value of all growth rates for the item during the specified period (e.g. 10 years)
    
    //USAGE (consistency)
    //--> Function is applied after checking if the first 50% of the periods's values are positive. (Use the method "positive", for this purpose)
    
    func consistency(beginningHalf: Array<Double>, half: Int, AAGR: String) -> String {
        if halfNeutral(array: beginningHalf) == true { //Check if 50% of the earliest half of the periods's values are neutral or positive
            let negative = beginningHalf.filter{$0 < 0}
            if negative.count == 0 { //Scenario 1. No negative growth values in second half
                let solidConsistency = ("Solid consistency in increasing \(name), with an average YoY-growth (AAGR) of \(AAGR)% and no identified decreases in growth.")
                return solidConsistency
            } else if negative.count < Int(round(Double(half)/2)){ //Scenario 2. <50% of the values in second half are negative
                let negativeYears = findNegativeYears(values: beginningHalf, periods: periods)
                let overallConsistency = ("Overall good consistency in increasing \(name), with an average YoY-growth (AAGR) of \(AAGR)%. Negative growth found in \(negativeYears)")
                return overallConsistency
            }
        } else {
            let changingConsistencyTrend = "At least the last \(Int(half)) years seem to be revealing a rather consistent and stable YoY-growth. Traits of consistency can be identified for the last \(Int(half)) periods, in terms of growth."
            return changingConsistencyTrend
        }
        return ""
    }
    
    func stability(beginningHalf: Array<Double>, half: Int, AAGR: String) -> String {
        if halfNeutral(array: beginningHalf) == true {//Check if 50% of the earliest half of the periods's values are neutral or positive
            let negative = beginningHalf.filter{$0 < 0}
            if negative.count == 0 { //Scenario 1. No negative growth values in second half
                let solidConsistency = ("Solid, stable and neutral \(name) growth, with no traits of volatility (instability) in growth. Shows an average YoY-growth (AAGR) of \(AAGR)%.")
                return solidConsistency
            } else if negative.count < Int(round(Double(half)/2)){ //Scenario 2. <50% of the values in second half are negative
                let negativeYears = findNegativeYears(values: beginningHalf, periods: periods)
                let overallConsistency = ("Overall good consistency in increasing \(name), with an average YoY-growth (AAGR) of \(AAGR)%. Negative growth found in \(negativeYears)")
                return overallConsistency
            }
        } else { //>50% of the earliest half of the periods's values are negative
            
        }

        return ""
    }

    
    func dataImplication() -> String {
        let half = Int(round(Double(growthValues.count)/2))
        let latestHalf = Array(growthValues.suffix(half))
        let restHalf = Array(growthValues.filter {!latestHalf.contains($0)})
        
        let AAGR = average*100 //Average Annual Growth Rate
        let AAGRStr = String(format: "%.2f", AAGR)
        
        print("Financial statement item: \(name)")
        print(latestHalf)
        print(restHalf)
        
        //Data implication part is primarily dividing the data array in two part - data from the latest periods and the data from the earliest periods
        //It further analyzes the two parts
        //Latest periods --> Check trend + AAGR (pos, neg, or neutral)
        //Earliest periods -->
        
        //1. CONSISTENCY in increasing item xx
        if onlyPositive(array: latestHalf) == true && AAGR > 0 {//50% of the periods (latestHalf) values are positive + AAGR > 0
            let consistencyDesc = consistency(beginningHalf: restHalf, half: half, AAGR: AAGRStr)
            return consistencyDesc
        }
            
        //2. STABILITY in item change with little/no growth
        else if atLeastNeutral(array: latestHalf) == true && AAGR >= 0 {//50% of the periods (latestHalf) values are positive or neutral + AAGR > 0
            let stabilityDesc = stability(beginningHalf: restHalf, half: half, AAGR: AAGRStr)
            return stabilityDesc
        }
            
        //3. INSTABILITY in item change with negative growth
        else if onlyNegative(array: latestHalf) == true && AAGR <= 0{
            
        }
        
        return "n/A"
    }
}
