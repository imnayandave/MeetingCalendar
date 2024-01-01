//
//  MainCalendar_VC.swift
//  demo_MeetingCalendar
//
//  Created by Nayan Dave on 30/12/23.
//

import UIKit
import CalendarKit
import EventKit

class MainCalendar_VC: DayViewController {
    
    // Boolean to decide if HeaderView (DateSelectionView) should be visible or not
    public var isAnotherDateSelectable = false
    
    // To be passed from another VC
    public var manuallySelectedDate: Date?
    
    // To prevent accidental reloading while editing event { just for demo usage }
    private var noReloading = false
    
    private var localAllEvents = [Event]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .white
        title = "Demo_Calendar"
        configureDayView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + (isAnotherDateSelectable ? 0 : 0.5)) { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 2) {
                self.dayView.timelinePagerView.scrollTo(hour24: self.localAllEvents[0].dateInterval.start.getHourIn24Format(), animated: true)
            } completion: { _ in
                self.noReloading = true
                self.beginEditing(event: self.localAllEvents[0])
            }
        }
    }
    
    private func configureDayView() {
        // Can modify the start and end time draggable dot UI in EventResizeHandleDotView.configure & EventResizeHandleView.dotView
        if let manuallySelectedDate {
            dayView.dayHeaderView.dateSelectorDidSelectDate(manuallySelectedDate)
        }
        // To Hide HeaderView (Restrict Change Another Date)
        if !isAnotherDateSelectable {
            dayView.isHeaderViewVisible = false
            dayView.headerHeight = 0
            dayView.setNeedsDisplay()
            dayView.layoutIfNeeded()
        }
    }
    
    private var allEvents = { date in
        var temp = [Event]()
        for i in 1...5 {
            var test = Event()
            var currCalendar = Calendar.current
            currCalendar.timeZone = TimeZone(abbreviation: "IST")!
            var workingDate = currCalendar.date(byAdding: .hour, value: Int.random(in: 1...24), to: date)!
            let duration = Int.random(in: 60 ... 160)
            // Either with dateInterval or Start/End Date
//            test.dateInterval.start = workingDate
//            test.dateInterval.end = workingDate.addingTimeInterval(TimeInterval(duration * 60))
            test.dateInterval = DateInterval(start: workingDate, duration: TimeInterval(duration * 60))
            test.color = [UIColor.red, .blue, .green, .gray, .purple, .yellow, .brown].randomElement()!
            test.isAllDay = false
            test.text = "TEST Event \(i)"
            print("Event Name = \(test.text)\nStart Date = \(test.dateInterval.start)\nEnd Date = \(test.dateInterval.end)")
            temp.append(test)
        }
        return temp
    }
    
    // MARK: - Delegate Methods
    /// `Required Method To Show Event`
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        if noReloading {
            return localAllEvents
        }
        localAllEvents = allEvents(date)
        return localAllEvents
    }
    
    /// `Detect Tap On Event`
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let event = eventView.descriptor else { return }
        dump(event)
        endEventEditing()
    }
    
    /// `Detect New Date Selection In Week`
    override func dayView(dayView: DayView, didMoveTo date: Date) {
        debugPrint("New Date Selected")
        if isAnotherDateSelectable {
            UIView.animate(withDuration: 2) {
                self.dayView.timelinePagerView.scrollTo(hour24: self.localAllEvents[0].dateInterval.start.getHourIn24Format(), animated: true)
            }
        }
    }
    
    /// `Detect Long Press On Event (To make it editable)`
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event else { return }
        noReloading = true
        endEventEditing()
        print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
        beginEditing(event: descriptor, animated: true)
    }
    
    /// `Save Edited Event`
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        print("new startDate: \(event.dateInterval.start) new endDate: \(event.dateInterval.end)")
        if let demo = event.editedEvent {
            event.commitEditing()
        }
        reloadData()
    }
    
    /// `Detects Tap To End Editing`
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
        print("Did Tap at date: \(date)")
        noReloading = false
    }
}

extension Date {
    func getHourIn24Format() -> Float {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return Float(formatter.string(from: self))!
    }
}
