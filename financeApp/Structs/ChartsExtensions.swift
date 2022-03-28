//
//  ChartsExtensions.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-31.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation
import Charts
import UIKit

class YAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let abbreviatedValue = value.abbreviateLargeNumbers(format: "%.0f")
        return abbreviatedValue
    }
}

class ChartXAxisFormatter: NSObject {
    var dateFormatter: DateFormatter?
}

extension ChartXAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if let dateFormatter = dateFormatter {
            let date = Date(timeIntervalSince1970: value)
            return dateFormatter.string(from: date)
        }
        return ""
    }
}

extension Double {
    func abbreviateLargeNumbers(format: String) -> String{
                
        let absVal = String(format: "%.0f", abs(self.rounded()))
        let amountOfCharacters = absVal.count
        
        var letterAbbreviation = String()
            
        if amountOfCharacters >= 3 && amountOfCharacters <= 6 {
            let truncatedNbr = (self / pow(10, 3))
            let truncatedNbrStr = String(format: format, truncatedNbr)
            //let shortenedValue = (roundedString.dropLast(3))
            letterAbbreviation = truncatedNbrStr + "K"
        }
        
        else if amountOfCharacters > 6 && amountOfCharacters <= 9{
            let truncatedNbr = (self / pow(10, 6))
            let truncatedNbrStr = String(format: format, truncatedNbr)
            //let shortenedValue = (roundedString.dropLast(6))
            letterAbbreviation = truncatedNbrStr + "M"
        }
        
        else if amountOfCharacters > 9 {
            let truncatedNbr = (self / pow(10, 9))
            let truncatedNbrStr = String(format: format, truncatedNbr)
            //lletterAbbreviation = shortenedValue + "B"
            letterAbbreviation = truncatedNbrStr + "B"
        }
        
        else if amountOfCharacters < 3 {
            letterAbbreviation = String(format: format, self)
        }
        
        return letterAbbreviation
    }
}

extension String {
    func firstLetterCapitalized() -> String {
        var word = String()
        let lowerCase = CharacterSet.lowercaseLetters
        
        if self == lowercased() {
            word = self.uppercased()
        } else {
            for character in self.unicodeScalars {
                if lowerCase.contains(character) {
                    word += String(character)
                } else {
                    word += " " + String(character)
                }
            }
            word = word.prefix(1).uppercased() + word.dropFirst()
        }
        return word
    }
}

extension UIView {
  func addTopBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
    self.layer.addSublayer(border)
  }

  func addRightBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
    self.layer.addSublayer(border)
  }

  func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
    self.layer.addSublayer(border)
  }

  func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
    self.layer.addSublayer(border)
  }
}
