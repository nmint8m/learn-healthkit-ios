# Reading Data from HealthKit & The App Life Cycle

## The App Life Cycle

Reference: [The App Life Cycle](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/TheAppLifeCycle/TheAppLifeCycle.html)

### Execution States for Apps

At any given moment, your app is in one of the states listed in this table:

<img src="./Images/app-states.png" width="600">


The system moves your app from state to state in response to actions happening throughout the system.

<img src="./Images/app-states-img.png" width="300">

> **My note:**
> 
> - Inactive: 
> 	- In the **foreground**, but **not receiving events**. (It may be executing other code though.) 
> 	- An app usually stays in this state only **briefly** as it transitions to a different state.
> - Background: 
> 	- In the **background** and **executing code**. 
> 	- Most apps enter this state **briefly** on their way to being suspended. 
> 	- However, an app that **requests extra execution tim**e may remain in this state for a period of time. (~ 3 mins)
> 	- In addition, an app being launched directly into the background enters this state instead of the inactive state.
> - Suspended:
> 	- In the **background** but is **not executing code**. 
> 	- The system moves apps to this state **automatically** and **does not notify** them before doing so. 
> 	- While suspended, an **app remains in memory but does not execute any code**.
>	- When a low-memory condition occurs, the system may purge suspended apps without notice to make more space for the foreground app.

Delegating method:

- `application:willFinishLaunchingWithOptions:`
- `application:didFinishLaunchingWithOptions:`
- `applicationDidBecomeActive:`
- `applicationWillResignActive:`
- `applicationDidEnterBackground:`
- `applicationWillEnterForeground:`
- `applicationWillTerminate:` **This method is not called if your app is suspended.**

### App Termination

Apps must be prepared for termination to happen at any time and **should not wait** to save user data or perform other critical tasks.

Termination:

- **System-initiated termination** is a normal part of an app’s life cycle.
- **User-initiated termination**

**Suspended apps** receive no notification when they are terminated by system / user.

## Background Execution

Refence: [Background Execution](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html)

When the user is not actively using your app, the system moves it to the background state. For many apps, the background state is just a brief stop on the way to the app being suspended. but there are also **legitimate reasons** for apps to continue running in the background.

When you find it necessary to keep your app running in the background, iOS helps you do so efficiently and without draining system resources or the user’s battery. The techniques offered by iOS fall into three categories:

- Apps that start a short **task in the foreground can ask for time to finish** that task when the app moves to the background.
- Apps that initiate **downloads** in the foreground can hand off management of those downloads to the system, thereby allowing the app to be suspended or terminated while the download continues.
- Apps that need to run in the background to support specific types of tasks can declare their **support for one or more background execution modes**.

**Always try to avoid doing any background work** unless doing so improves the overall user experience.

### Executing Finite-Length Tasks

If your app is in the middle of a task and needs a little extra time to complete that task, to request some additional execution time, it can call:

- `beginBackgroundTaskWithName:expirationHandler:` 
- `beginBackgroundTaskWithExpirationHandler:` 

These methods delays the suspension of your app temporarily. Upon completion of that work, your app must call the `endBackgroundTask:` to let the system know that it is finished and can be suspended.

Failure to call the `endBackgroundTask:` will result in the termination of your app. If you provided an expiration handler when starting the task, the system calls that handler and gives you one last chance to end the task and avoid termination.

```swift
    var finiteBackgroundTaskID = UIBackgroundTaskIdentifier(rawValue: 0)
    
    private func createFiniteBackGroundWork(application: UIApplication, task: @escaping () -> Void) {
        finiteBackgroundTaskID = application.beginBackgroundTask(withName: "FiniteBackgroundTask") { [weak self] in
            guard let this = self else { return }
            application.endBackgroundTask(this.finiteBackgroundTaskID)
            this.finiteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }

        DispatchQueue.main.async { [weak self] in
            task()
            guard let this = self else { return }
            application.endBackgroundTask(this.finiteBackgroundTaskID)
            this.finiteBackgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
```

### Implementing Long-Running Tasks

In iOS, **only specific app types** are allowed to run in the background. Apps that:

- **Play audible content**, such as a music player app
- **Record audio content**
- **Keep users informed of their location at all times**
- Support **Voice over Internet Protocol** (VoIP)
- **Download and process** new content regularly
- Receive regular updates from **external accessories**

### Declaring Your App’s Supported Background Tasks

Enabling the Background Modes option adds the UIBackgroundModes key to your app’s Info.plist file. Selecting one or more checkboxes adds the corresponding background mode values to that key.

Background modes for apps:

| Xcode background mode | UIBackgroundModes value | Description |
|---|---|---|
| Background fetch | fetch | The app regularly downloads and processes small amounts of content from the network |

...

Each of the preceding modes lets the system know that your app should be woken up or launched at appropriate times to respond to relevant events. 

#### Fetching Small Amounts of Content Opportunistically

Apps that need to check for new content periodically can ask the system to wake them up so that they can initiate a fetch operation for that content. To support this mode, enable the Background fetch option from the Background modes section of the Capabilities tab in your Xcode project. 

Enabling this mode is **not a guarantee that the system will give your app any time to perform background fetches**. The system must balance your app’s need to fetch content with the needs of other apps and the system itself. After assessing that information, the system gives time to apps when there are good opportunities to do so.

When a good opportunity arises, the system wakes or launches your app into the background and calls the app delegate’s application:performFetchWithCompletionHandler: method. Use that method to check for new content and initiate a download operation if content is available. As soon as you finish downloading the new content, you must execute the provided completion handler block, passing a result that indicates whether content was available. Executing this block tells the system that it can move your app back to the suspended state and evaluate its power usage. Apps that download small amounts of content quickly, and accurately reflect when they had content available to download, are more likely to receive execution time in the future than apps that take a long time to download their content or that claim content was available but then do not download anything.

When downloading any content, it is recommended that you use the NSURLSession class to initiate and manage your downloads. For information about how to use this class to manage upload and download tasks, see URL Loading System Programming Guide.

> My Note: 

### Pushing Updates to Your App Silently

Reference:

- [Setting Up a Remote Notification Server](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server)
- [Pushing Updates to Your App Silently](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_updates_to_your_app_silently)

Deliver silent notifications and wake up your app in the background on the user's device.

Use silent notifications to notify your app when new content is available.

The system treats silent notifications as low-priority. You can use them to refresh your app’s content, but **the system doesn't guarantee their delivery**. In addition, the delivery of silent notifications may be throttled if the total number becomes excessive. The actual **number of silent notifications** allowed by the system **depends on current conditions**, but don't try to send more than two or three silent notifications per hour.

### Getting the User’s Attention While in the Background

Notifications are a way for an app that is suspended, is in the background, or is not running to get the user’s attention. Apps can use local notifications to display alerts, play sounds, badge the app’s icon, or a combination of the three.

[UserNotifications](https://developer.apple.com/documentation/usernotifications)

[Asking Permission to Use Notifications](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications)

[Remote Notification Programming Guide](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/index.html#//apple_ref/doc/uid/TP40008194-CH3-SW1)

```
private func scheduleNotificationForDate(_ hour: Int, _ minute: Int, _ second: Int) {
        let noti = UNMutableNotificationContent()
        noti.title = "Notification title"
        noti.body = "Notification body"
        noti.categoryIdentifier = "ID_NOTI"
        noti.sound = UNNotificationSound.default

        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        date.second = second

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)

        let request = UNNotificationRequest(identifier: "ID_NOTI", content: noti, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            print(error ?? "NO ERROR")
        })
    }
```

## HealthKit

Reference: [HealthKit](https://developer.apple.com/healthkit/)

### Protecting User Privacy

Reference: [Protecting User Privacy](https://developer.apple.com/documentation/healthkit/protecting_user_privacy)

The HealthKit data is only kept locally on the user’s device. For security, the HealthKit store is encrypted when the device is locked, and the HealthKit store can only be accessed by an authorized app. As a result, you may not be able to read data from the store when your app is launched in the background; however, apps can still write data to the store, even when the phone is locked. HealthKit temporarily caches the data and saves it to the encrypted store as soon as the phone is unlocked.

> My note:
> 
> It means that we can use HealthKit data in background just in case, when:
> 
> - Users set password for device, but not lockscreen
> - Users doesn't set password for device
> 
> Use these method:
> 
> - `applicationProtectedDataWillBecomeAvailable(_:)`
> - `applicationProtectedDataDidBecomeAvailable(_:)`
> 
> Tells the delegate that protected files will be/are available now.
> 
> Step I will do for suspended app in case users doesn't lock device with password:
> 
> - Push silent notification -> wake suspended app runs in background
> - Use `applicationProtectedDataWillBecomeAvailable`
> 
> If users don't use network, I recommend using local push notification.

### Reading Data from HealthKit

Reference: [Reading Data from HealthKit](https://developer.apple.com/documentation/healthkit/reading_data_from_healthkit)

There are three main ways to access data from the HealthKit Store:

- Direct method calls. The HealthKit store provides methods to directly access characteristic data. These methods can be used only to access characteristic data. For more information, see HKHealthStore.
- Queries. Queries return the current snapshot of the requested data from the HealthKit store.
- **Long-running queries**. These queries continue to run in the **background** and **update your app whenever changes are made** to the HealthKit store.

### Long-Running Queries

Long-running queries continue to run an anonymous background queue, and update your app whenever changes are made to the HealthKit store. In addition, observer queries can register for background delivery. This lets HealthKit wake your app in the background whenever an update occurs.

Healthkit provides the following long-running queries:

- Observer query. 
- Anchored object query. 
- Statistics collection query.
- Activity summary query.

## Strategies for Handling App State Transitions

Reference: [Strategies for Handling App State Transitions](https://developer.apple.com/library/archive/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/StrategiesforHandlingAppStateTransitions/StrategiesforHandlingAppStateTransitions.html)

### Be Prepared to Process Queued Notifications

An app in the suspended state must be ready to handle any queued notifications when it returns to a foreground or background execution state. A suspended app does not execute any code and therefore cannot process notifications related to orientation changes, time changes, preferences changes, and many others that would affect the app’s appearance or state.

To make sure these changes are not lost, the system queues many relevant notifications and delivers them to the app as soon as it starts executing code again (either in the foreground or background). To prevent your app from becoming overloaded with notifications when it resumes, **the system coalesces events and delivers a single notification** (of each relevant type) **that reflects the net change since your app was suspended**.

Table 4-1 lists the notifications that can be coalesced and delivered to your app. Most of these notifications are delivered directly to the registered observers. Some, like those related to device orientation changes, are typically intercepted by a system framework and delivered to your app in another way.

| Event | Notifications |
|---|---|
| The status of protected files changes. (like HealthKit data) |UIApplicationProtectedDataWillBecomeUnavailable, UIApplicationProtectedDataDidBecomeAvailable |

## Conclusion

| App state | Is able to read HealthKit data | Is able to send data | Solution (if exist) |
|---|---|---|---|
| Not running | No | No | Local notification |
| Inactive | Yes | Yes | Should not (*) |
| Active | Yes | Yes | |
| Background | Yes | Yes  | Background fetch, Long-Running Queries (**) |
| Suspended | No | No | Change app state to background (***) |

(*) But this app usually stat in the inactive state only briefly as it transition to a different state -> We should not read/send data while in this state.

(**) Just only users don't lock device with password. The question is how often client wants to update data?

(***) Mentioned above:

- Push silent notification to change app state to background
- Run query in `applicationProtectedDataWillBecomeAvailable`/ `applicationProtectedDataDidBecomeAvailable` to check data is encrypted or not.
- Do like (**)


