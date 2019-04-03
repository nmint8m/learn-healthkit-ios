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
        print("\(Date()) FUNCTION: \(function)")
        switch UIApplication.shared.applicationState {
        case .active:
            print("\(Date()) APP STATE: ACTIVE")
        case .inactive:
            print("\(Date()) APP STATE: INACTIVE")
        case .background:
            print("\(Date()) APP STATE: BACKGROUND")
        }
        print("\(Date()) MESSAGE: \(message)")
        print("------------------------")
    }

    var finiteBackgroundTaskID = UIBackgroundTaskIdentifier(rawValue: 0)
    var infiniteBackgroundTaskID = UIBackgroundTaskIdentifier(rawValue: 1)

    private func createFiniteBackGroundWork(application: UIApplication, task: @escaping () -> Void) {
        finiteBackgroundTaskID = application.beginBackgroundTask(withName: "FiniteBackgroundTask") { [weak self] in
            print("\(Date()) MY FINITE TASK IS ENDED ")
            print("------------------------")
            guard let this = self else { return }
            application.endBackgroundTask(this.finiteBackgroundTaskID)
            this.finiteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }

        DispatchQueue.main.async { [weak self] in
            print("\(Date()) FINITE BACKGROUND TASK STARTED")
            task()
            guard let this = self else { return }
            application.endBackgroundTask(this.finiteBackgroundTaskID)
            this.finiteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
            print("\(Date()) BACKGROUND TASK ENDED")
            print("------------------------")
        }
    }

    private func createInfiniteBackGroundWork(application: UIApplication, task: @escaping () -> Void) {
        infiniteBackgroundTaskID = application.beginBackgroundTask(withName: "InfiniteBackgroundTask") { [weak self] in
            print("MY INFINITE TASK IS ENDED. \(Date())")
            print("------------------------")
            guard let this = self else { return }
            application.endBackgroundTask(this.infiniteBackgroundTaskID)
            this.infiniteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }

        DispatchQueue.main.async {
            print("INFINITE BACKGROUND TASK STARTED: \(Date())")
            task()
            print("BACKGROUND TASK ENDED: \(Date())")
            print("------------------------")
        }
    }
}

enum HealthkitSetupError: Error {
    case notAvailableOnDevice

    var localizedDescription: String {
        switch self {
        case .notAvailableOnDevice: return "notAvailableOnDevice"

        }
    }
}
