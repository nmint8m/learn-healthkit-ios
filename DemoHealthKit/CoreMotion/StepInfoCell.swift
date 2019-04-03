//
//  StepInfoCell.swift
//  DemoHealthKit
//
//  Created by Tam Nguyen M. on 4/3/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import UIKit

final class StepInfoCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var appStateLabel: UILabel!
    @IBOutlet private weak var stepInfoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configCell(_ motion: MotionInfo) {
        dateLabel.text = "\(motion.date)"

        switch motion.appState {
        case .active:
            appStateLabel.text = "Active"
            appStateLabel.textColor = .green
        case .inactive:
            appStateLabel.text = "Inactive"
            appStateLabel.textColor = .yellow
        case .background:
            appStateLabel.text = "Background"
            appStateLabel.textColor = .red
        }

        stepInfoLabel.text = motion.stepInfo
    }
}
