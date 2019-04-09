# Reading step data from HealthKit, CoreMotion and the app life cycle

_Written by: **Nguyen Minh Tam**_

## Use case



## Conclusion

For general:

| App state | Is able to read HealthKit data | Is able to send data | Solution (if exist) |
|---|---|---|---|
| Not running | No | No | Push `Local notification` / `Remote notification `|
| Inactive | Yes | Yes | Should not (*) |
| Active | Yes | Yes | |
| Background | Yes | Yes  | `Background fetch` with `HeathKit Long-Running Queries` / `CoreMotion` (**) |
| Suspended | No | No | Change app state to background (***) |

(*) App usually stats in the inactive state only briefly as it transition to a different state -> We should not read/send data while in this state.

(**) We can use `HeathKit Long-Running Queries` just only users don't lock device with password. So we will use `CoreMotion` to track steps instead.

(***) Change app state to background:

- Push notification silently to change app state from suspended to background
- With HeathKit, run query in `applicationProtectedDataWillBecomeAvailable`/ `applicationProtectedDataDidBecomeAvailable` to check data is encrypted or not.
- With CoreMotion, just perform fetch inside `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`.

In conclusion, we will solve problems by:

| App state | Is able to read HealthKit data | Is able to send data | Track steps data |
|---|---|---|---|
| Not running | No | No | Push `Local notification` / `Remote notification `|
| Inactive | Yes | Yes | Do not track |
| Active | Yes | Yes | Track normally |
| Background | Yes | Yes  | `Background fetch` with `CoreMotion` |
| Suspended | No | No | Push `Remote notification` silently |

