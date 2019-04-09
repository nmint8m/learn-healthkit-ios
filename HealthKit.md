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