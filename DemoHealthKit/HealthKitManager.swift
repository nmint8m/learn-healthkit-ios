//
//  HealthKitManager.swift
//  DemoHealthKit
//
//  Created by Tam Nguyen M. on 4/1/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import Foundation
import HealthKit
import SwiftDate

typealias HKCompletion = (_ success: Bool, _ error: Error?) -> Void
typealias HKStepsCompletion = (_ atDate: DateInRegion, _ steps: Int, _ error: Error?) -> Void
typealias HKStepResult = [String: Int]
typealias HKStepsArrayCompletion = (_ steps: HKStepResult, _ error: Error?) -> Void

class HealthKitManager {

    static let manager = HealthKitManager()

    fileprivate let store = HKHealthStore()

    func authen(_ completion: @escaping HKCompletion) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else { return }
        store.requestAuthorization(toShare: nil, read: [type], completion: completion)
    }

    var authenStatus: HKAuthorizationStatus {
        guard let type = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else { return HKAuthorizationStatus.sharingDenied }
        return store.authorizationStatus(for: type)
    }

    func steps(inDate date: DateInRegion, completion: @escaping HKStepsCompletion) {
        let fromDate = date.startOf(component: .day)
        let toDate = fromDate.endOf(component: .day)
        steps(fromDate, toDate: toDate, atDate: date, completion: completion)
    }

    func steps(_ fromDate: DateInRegion, toDate: DateInRegion, atDate: DateInRegion, completion: @escaping HKStepsCompletion) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(atDate, 0, nil)
            return
        }
        guard let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else { return }

        let anchorDate = fromDate.startOf(component: .day).absoluteDate
        let interval = DateComponents(year: 0, month: 0, day: 1)
        let endDate = toDate.endOf(component: .day).absoluteDate
        let startDate = fromDate.startOf(component: .day).absoluteDate

        let pre = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: pre, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        query.initialResultsHandler = { query, result, error in
            guard error == nil else {
                completion(atDate, 0, error)
                return
            }
            result?.enumerateStatistics(from: startDate, to: endDate, with: { (statistics, stop) in
                guard let quantity = statistics.sumQuantity() else {
                    completion(atDate, 0, nil)
                    return
                }
                let value = quantity.doubleValue(for: HKUnit.count())
                completion(atDate, Int(round(value)), nil)
            })
        }
        store.execute(query)
    }
}
