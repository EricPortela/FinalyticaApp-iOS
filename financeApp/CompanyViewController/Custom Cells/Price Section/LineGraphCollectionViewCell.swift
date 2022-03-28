//
//  LineGraphCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-27.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation
import UIKit
import Charts

class CircleMarker: MarkerImage {
    @objc var color: UIColor
    @objc var radius: CGFloat = 4
    
    @objc public init(color: UIColor) { //Initialize attributes
        self.color = color
        super.init()
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        let diameter = radius*2
        let circleRect = CGRect(x: point.x-radius, y: point.y-radius, width: diameter, height: diameter)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: circleRect)
        
        context.restoreGState()
    }
}


class LineGraphCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    let cellWidth = UIScreen.main.bounds.size.width
    let cellHeight = 300
    
    let lineChart: LineChartView = {
        let circleMarker = CircleMarker(color: .white)
        let balloonMarker = BalloonMarker(color: .white, font: UIFont(name: "HelveticaNeue", size: 10)!, textColor: .black, insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        balloonMarker.minimumSize = CGSize(width: 100, height: 50)
        let chart = LineChartView()
        
        chart.marker = balloonMarker
        chart.leftAxis.enabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.rightAxis.labelPosition = .insideChart
        chart.xAxis.enabled = false
        chart.pinchZoomEnabled = false
        
        chart.noDataText = "No data"
        
        chart.rightAxis.labelTextColor = .label
        chart.minOffset = 0
        chart.legend.enabled = false
        chart.animate(xAxisDuration: 1, easingOption: .easeInOutQuad)

        //chart.xAxis.labelRotationAngle = -90
        //chart.xAxis.labelFont = UIFont(name: "HelveticaNeue", size: 7)!
        return chart
    }()
    
    let segmentedControl: UISegmentedControl = {
        let items = ["1D", "7D", "1M", "3M", "6M", "1Y", "YTD"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 2
        segmentedControl.selectedSegmentTintColor = UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)
        segmentedControl.tintColor = UIColor(red: 0.44, green: 0.35, blue: 0.79, alpha: 1.00)
        return segmentedControl
    }()
    
    func setUpViews() {
        layer.cornerRadius = 5
        backgroundColor = UIColor.clear
        
        //Main Card
        let cardHeight = self.bounds.size.height - 10
        let yPositionCard = CGFloat(10)
        //mainCard.frame = CGRect(x: xPositionCard, y: yPositionCard, width: cardWidth, height: cardHeight)
        //self.addSubview(mainCard)
        
        //SegmentedControl
        let segmentedControlWidth = Int(cellWidth - 40)
        let segmentedControlHeight = 32
        let yPositionSegControl =  Int(yPositionCard + 15)
        segmentedControl.frame = CGRect(x: 20, y: yPositionSegControl, width: segmentedControlWidth, height: segmentedControlHeight)
        self.addSubview(segmentedControl)

        //Line Chart
        let chartWidth = CGFloat(cellWidth)
        let chartHeight = CGFloat(Int(cardHeight) - (segmentedControlHeight + 15 + 5 + 15))
        let yPositionChart = (yPositionSegControl + segmentedControlHeight + 15)
        lineChart.frame = CGRect(x: 0, y: CGFloat(yPositionChart), width: chartWidth, height: chartHeight)
        self.addSubview(lineChart)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class BalloonMarker: MarkerImage
{
    @objc open var color: UIColor
    @objc open var arrowSize = CGSize(width: 15, height: 11)
    @objc open var font: UIFont
    @objc open var textColor: UIColor
    @objc open var insets: UIEdgeInsets
    @objc open var minimumSize = CGSize()
    
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : Any]()
        
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size

        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }

        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }

        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }

        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()

        context.setFillColor(color.cgColor)

        if offset.y > 0
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.fillPath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.fillPath()
        }
        
        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }

        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel("Price: \(String(entry.y)) \n Date: \(String(entry.x))")
    }
    
    @objc open func setLabel(_ newLabel: String)
    {
        label = newLabel
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
    }
}
