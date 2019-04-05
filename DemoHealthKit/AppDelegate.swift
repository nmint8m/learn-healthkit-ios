//
//  AppDelegate.swift
//  DemoHealthKit
//
//  Created by Tam Nguyen M. on 4/1/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        logApplicationState(function: "willFinishLaunchingWithOptions",
                            message: "First chance to execute code at launch time.")

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logApplicationState(function: "didFinishLaunchingWithOptions",
                            message: "Perform any final initialization before your app is displayed to the user")

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        window?.rootViewController = StepCountingVC()

        configBackgroundAppRefressh()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        logApplicationState(function: "applicationWillResignActive",
                            message: "Your app is transitioning away from being the foreground app")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        logApplicationState(function: "applicationDidEnterBackground",
                            message: "Your app is now running in the background and may be suspended at any time.")
        createFiniteBackGroundWork(application: application, task: {
        })
        createInfiniteBackGroundWork(application: application, task: {
        })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        logApplicationState(function: "applicationWillEnterForeground",
                            message: "Your app is moving out of the background and back into the foreground, but that it is not yet active.")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        logApplicationState(function: "applicationDidBecomeActive",
                            message: "Your app is about to become the foreground app. Use this method for any last minute preparation.")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        logApplicationState(function: "applicationWillTerminate",
                            message: "Your app is being terminated. This method is not called if your app is suspended.")
    }

    private func logApplicationState(function: String, message: String) {
        let state: String
        switch UIApplication.shared.applicationState {
        case .active:
            state = "ACTIVE"
        case .inactive:
            state = "INACTIVE"
        case .background:
            state = "BACKGROUND"
        }
        print("### \(Date()) FUNCTION: \(function), APP STATE: \(state), MESSAGE: \(message) \n------------------------")
    }

    var finiteBackgroundTaskID = UIBackgroundTaskIdentifier(rawValue: 0)
    var infiniteBackgroundTaskID = UIBackgroundTaskIdentifier(rawValue: 1)

    private func createFiniteBackGroundWork(application: UIApplication, task: @escaping () -> Void) {
        finiteBackgroundTaskID = application.beginBackgroundTask(withName: "FiniteBackgroundTask") { [weak self] in
            print("### \(Date()) FINITE BACKGROUND TASK IS ENDED \n------------------------")
            guard let this = self else { return }
            application.endBackgroundTask(this.finiteBackgroundTaskID)
            this.finiteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }

        DispatchQueue.main.async { [weak self] in
            print("### \(Date()) FINITE BACKGROUND TASK STARTED")
            task()
            guard let this = self else { return }
            application.endBackgroundTask(this.finiteBackgroundTaskID)
            this.finiteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
            print("### \(Date()) FINITE BACKGROUND TASK ENDED \n------------------------")
        }
    }

    private func createInfiniteBackGroundWork(application: UIApplication, task: @escaping () -> Void) {
        infiniteBackgroundTaskID = application.beginBackgroundTask(withName: "InfiniteBackgroundTask") { [weak self] in
            print("### \(Date()) INFINITE BACKGROUND TASK IS ENDED \n------------------------")
            guard let this = self else { return }
            application.endBackgroundTask(this.infiniteBackgroundTaskID)
            this.infiniteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }

        DispatchQueue.main.async {
            print("### \(Date()) INFINITE BACKGROUND TASK STARTED")
            task()
            print("### \(Date()) INFINITE BACKGROUND TASK ENDED \n------------------------")
        }
    }

    private func configBackgroundAppRefressh() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("### PerformFetchWithCompletionHandler ###")

        let motionInfo = MotionManager.shared.currentMotionInfo

        let state: String
        switch motionInfo.appState {
        case .active: state = "Active"
        case .inactive: state = "Inactive"
        case .background: state = "Background"
        }
        print("### StepCountingVC: MotionInfo: Date \(motionInfo.date), AppState: \(state) Step \(motionInfo.stepInfo)")

        guard let url = URL(string: "https://prosite-api.stg-kawaru.jp/api/v4/video-chats/update") else {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        var request = URLRequest(url: url)
        request.setValue("4.2.2", forHTTPHeaderField: "app-version")
        request.setValue("Bearer 098f48758f7a330f0c2b1d626415cf8243c76ec339617ca6ad3c4b95d677883d", forHTTPHeaderField: "Authorization")
        request.setValue("394cfec867102a92a17b2acd40234fcd4f692119392a8c29296f70873ff60f4a", forHTTPHeaderField: "ClientId")
        request.setValue("2", forHTTPHeaderField: "device-type")
        request.setValue("ja;q=1.0", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip;q=1.0, compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("iPhone10,4", forHTTPHeaderField: "device-name")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16B91", forHTTPHeaderField: "User-Agent")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("iOS 12.1", forHTTPHeaderField: "os-version")

        let section = URLSession(configuration: URLSessionConfiguration.ephemeral)

        let task = section.dataTask(with: request) {(data, response, error) in
            completionHandler(UIBackgroundFetchResult.newData)
        }
        task.resume()
        completionHandler(UIBackgroundFetchResult.noData)
    }
}

//extension AppDelegate: MotionManagerDelegate {
//    func motionManager(_ motionManager: MotionManager, needsPerform action: MotionManager.Action) {
//        switch action {
//        case .updateMotion(let info):
//            print("BACKGROUND FETCH!!!")
//            print("\(info.date) \(info.appState) \(info.stepInfo)")
//            print("SEND TO SERVER")
//        }
//        MotionManager.shared.startTracking(false)
//    }
//}

enum HealthkitSetupError: Error {
    case notAvailableOnDevice

    var localizedDescription: String {
        switch self {
        case .notAvailableOnDevice: return "notAvailableOnDevice"
        }
    }
}
