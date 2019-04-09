## Core Motion

> **My note:** Because of Privacy Policy, we cannot read HealthKit when devices are locked. So we should use the CoreMotion instead.

```
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

    private init() {}

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
}
```