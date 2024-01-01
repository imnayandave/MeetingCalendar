//
//  ViewController.swift
//  demo_MeetingCalendar
//
//  Created by Nayan Dave on 30/12/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var pickerView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did Loaded...")
        let cal = Calendar.current
        
    }

    @IBAction func btn_GoToCalendar(_ sender: UIButton) {
        let calendarVC = MainCalendar_VC()
        calendarVC.isAnotherDateSelectable = true
        navigationController?.pushViewController(calendarVC, animated: true)
    }
    
    @IBAction func btnSelectDate(_ sender: UIButton) {
        if pickerContainerView.alpha == 0 {
            pickerContainerView.transform = CGAffineTransform(translationX: 0, y: -100)
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 50, initialSpringVelocity: 25) { [weak self] in
                guard let self = self else { return }
                self.pickerContainerView.alpha = 1
                self.pickerContainerView.transform = .identity
            }
        }
    }
    @IBAction func btnDonePickerSelection(_ sender: UIButton) {
        let calendarVC = MainCalendar_VC()
        calendarVC.manuallySelectedDate = pickerView.date
        debugPrint("Selected Date = \(pickerView.date)")
        calendarVC.isAnotherDateSelectable = false
        navigationController?.pushViewController(calendarVC, animated: true)
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        debugPrint("Selected Row From PIcker = \(row)")
    }
}

