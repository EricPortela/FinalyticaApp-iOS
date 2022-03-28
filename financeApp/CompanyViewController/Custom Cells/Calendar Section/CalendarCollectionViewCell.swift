//
//  CalendarCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-27.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar


class CalendarCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    
    let calendarView: FSCalendar = {
        let calendar = FSCalendar()
        return calendar
    }()
    
    func positionCalendar(calendarView: FSCalendar) {
        calendarView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-40, height: 300)
    }
    
    func setUpViews() {
        addSubview(calendarView)
        positionCalendar(calendarView: calendarView)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
