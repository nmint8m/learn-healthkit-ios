//
//  StepCountingVC.swift
//  DemoHealthKit
//
//  Created by Tam Nguyen M. on 4/3/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import UIKit
import CoreMotion

struct MotionInfo {
    let date: Date
    let appState: UIApplication.State
    let stepInfo: String

}

final class StepCountingVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var startStopButton: UIButton!

    private let stepInfoCell = "StepInfoCell"

    private var isTracking = false

    private var motionInfo: [MotionInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configMotionManager()
    }

    private func configTableView() {
        let nib = UINib(nibName: stepInfoCell, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: stepInfoCell)
        tableView.dataSource = self
    }

    private func configMotionManager() {
        MotionManager.shared.delegate = self
    }

    @IBAction func startStopButtonTouchUpInside(_ sender: Any) {
        isTracking = !isTracking
        startStopButton.backgroundColor = isTracking ? .green : .red
        MotionManager.shared.startTracking(isTracking)
    }
}

extension StepCountingVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return motionInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        guard row < motionInfo.count,
            let cell = tableView.dequeueReusableCell(withIdentifier: stepInfoCell, for: indexPath) as? StepInfoCell else { return UITableViewCell() }
        cell.configCell(motionInfo[row])
        return cell
    }
}

extension StepCountingVC: MotionManagerDelegate {
    func motionManager(_ motionManager: MotionManager, needsPerform action: MotionManager.Action) {
        switch action {
        case .updateMotion(let newInfo):
            let state: String
            switch newInfo.appState {
            case .active: state = "Active"
            case .inactive: state = "Inactive"
            case .background: state = "Background"
            }
            print("### StepCountingVC: MotionInfo: Date \(newInfo.date), AppState: \(state) Step \(newInfo.stepInfo)")

            motionInfo.append(newInfo)

            DispatchQueue.main.async { [weak self] in
                guard UIApplication.shared.applicationState != .background else { return }
                self?.tableView.reloadData()
            }
        }
    }
}

protocol MotionManagerDelegate: class {
    func motionManager(_ motionManager: MotionManager, needsPerform action: MotionManager.Action)
}

final class MotionManager {
    enum Action {
        case updateMotion(MotionInfo)
    }

    static let shared = MotionManager()
    weak var delegate: MotionManagerDelegate?
    var currentMotionInfo = MotionInfo(date: Date(), appState: .active, stepInfo: "0") {
        didSet {
            
        }
    }

    private var pedometer = CMPedometer()

    // timers
    private var timer = Timer()
    private let timerInterval = 1.0
    private var timeElapsed:TimeInterval = 0.0

    private init() {}

    //MARK: - Display and time format functions

    func startTracking(_ isOn: Bool) {
        if isOn {
            pedometer = CMPedometer()
            pedometer.startUpdates(from: Date()) { [weak self] (d, e) in
                DispatchQueue.main.async { [weak self] in
                    guard let this = self else { return }
                    let date = Date()
                    if let data = d {
                        let motion = MotionInfo(date: date,
                                                appState: UIApplication.shared.applicationState,
                                                stepInfo: "\(data.numberOfSteps)")
                        this.currentMotionInfo = motion
                        this.delegate?.motionManager(this, needsPerform: .updateMotion(motion))
                    } else {
                        let motion = MotionInfo(date: date,
                                                appState: UIApplication.shared.applicationState,
                                                stepInfo: "No step info now")
                        this.currentMotionInfo = motion
                        this.delegate?.motionManager(this, needsPerform: .updateMotion(motion))
                    }

                    if let error = e {
                        let motion = MotionInfo(date: date,
                                                appState: UIApplication.shared.applicationState,
                                                stepInfo: "\(error)")
                        this.currentMotionInfo = motion
                        this.delegate?.motionManager(this, needsPerform: .updateMotion(motion))
                    }
                }
            }
        } else {
            pedometer.stopUpdates()
        }
    }

    // convert seconds to hh:mm:ss as a string
    func timeIntervalFormat(interval:TimeInterval)-> String{
        var seconds = Int(interval + 0.5) //round up seconds
        let hours = seconds / 3600
        let minutes = (seconds / 60) % 60
        seconds = seconds % 60
        return String(format:"%02i:%02i:%02i",hours,minutes,seconds)
    }
    // convert a pace in meters per second to a string with
    // the metric m/s and the Imperial minutes per mile
//    func paceString(title:String,pace:Double) -> String{
//        var minPerMile = 0.0
//        let factor = 26.8224 //conversion factor
//        if pace != 0 {
//            minPerMile = factor / pace
//        }
//        let minutes = Int(minPerMile)
//        let seconds = Int(minPerMile * 60) % 60
//        return String(format: "%@: %02.2f m/s \n\t\t %02i:%02i min/mi",title,pace,minutes,seconds)
//    }
//
//    func computedAvgPace()-> Double {
//        if let distance = self.distance{
//            pace = distance / timeElapsed
//            return pace
//        } else {
//            return 0.0
//        }
//    }
//
//    func miles(meters:Double)-> Double{
//        let mile = 0.000621371192
//        return meters * mile
//    }
}
