---
title: Building forms with SwiftUI
description: 
published: true
layout: post
---

Apple finally released [Xcode Beta 2](http://developer.apple.com/download/) with an updated version of *SwiftUI*. The current version has a *Form* component which appeared on *WWDC* sessions. Today we are going to build form styled layout with *SwiftUI*. I want to show you a real-life example of the settings screen built with *SwiftUI*'s new Form component.

I work on a sleep tracking app, which needs settings screen. Settings screen should contain multiple toggles for enabling and disabling some features, buttons for in-app purchases, and a picker for tuning sleep tracking sensitivity level. 

#### BindableObject for Settings logic
Let's start by creating *BindableObject* representing our Settings logic. I've talked about *BindableObject* in my previous [post](/2019/06/12/understanding-property-wrappers-in-swiftui/), and you can check it to learn how to use it.

```swift
import SwiftUI
import Combine

class SettingsStore: BindableObject {
    let willChange = PassthroughSubject<Void, Never>()

    private enum Keys {
        static let pro = "pro"
        static let sleepGoal = "sleep_goal"
        static let notificationEnabled = "notifications_enabled"
        static let sleepTrackingEnabled = "sleep_tracking_enabled"
        static let sleepTrackingMode = "sleep_tracking_mode"
    }

    private let cancellable: Cancellable
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Keys.sleepGoal: 8,
            Keys.sleepTrackingEnabled: true,
            Keys.sleepTrackingMode: SleepTrackingMode.moderate.rawValue
            ])

        cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(willChange)
    }

    var isNotificationEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.notificationEnabled) }
        get { defaults.bool(forKey: Keys.notificationEnabled) }
    }

    var isPro: Bool {
        set { defaults.set(newValue, forKey: Keys.pro) }
        get { defaults.bool(forKey: Keys.pro) }
    }

    var isSleepTrackingEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.sleepTrackingEnabled) }
        get { defaults.bool(forKey: Keys.sleepTrackingEnabled) }
    }

    var sleepGoal: Int {
        set { defaults.set(newValue, forKey: Keys.sleepGoal) }
        get { defaults.integer(forKey: Keys.sleepGoal) }
    }

    enum SleepTrackingMode: String, CaseIterable {
        case low
        case moderate
        case aggressive
    }

    var sleepTrackingMode: SleepTrackingMode {
        get {
            return defaults.string(forKey: Keys.sleepTrackingMode)
                .flatMap { SleepTrackingMode(rawValue: $0) } ?? .moderate
        }

        set {
            defaults.set(newValue.rawValue, forKey: Keys.sleepTrackingMode)
        }
    }
}

extension SettingsStore {
    func unlockPro() {
        // You can do your in-app transactions here
        isPro = true
    }

    func restorePurchase() {
        // You can do you in-app purchase restore here
        isPro = true
    }
}
```

Here we have a simple *SettingsStore* class which conforms to *BindableObject* protocol. The single requirement is *willChange* property. *SwiftUI* uses this property to understand when something is changed, and as soon as changes appear, it rebuilds the depending views.

Another interesting point here is the usage of *Combine* framework. We use notification center publisher to subscribe on *UserDefaults* changes. As soon as *UserDefault* values change we get a notification and then we send it to *willChange* property. I will try to cover an introduction to *Combine* framework in future posts. But for now, you have to know that every change in *UserDefaults* sends *Void* value to *willChange* property, which triggers *View* rebuild process.

We can replace usage of *NotificationCenter* publisher by calling send method of *willChange* property in the every property setter inside the *SettingsStore*, but it looks like boilerplate. So let's keep it like this.

#### SettingsView
Let's start to build our settings screen UI. We will use *Text*, *Toggle*, *Stepper*, *Picker*, and *Button* components. Here is the source code of our *SettingsView*.

```swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications settings")) {
                    Toggle(isOn: $settings.isNotificationEnabled) {
                        Text("Notification:")
                    }
                }

                Section(header: Text("Sleep tracking settings")) {
                    Toggle(isOn: $settings.isSleepTrackingEnabled) {
                        Text("Sleep tracking:")
                    }

                    Picker(
                        selection: $settings.sleepTrackingMode,
                        label: Text("Sleep tracking mode")
                    ) {
                        ForEach(SettingsStore.SleepTrackingMode.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }

                    Stepper(value: $settings.sleepGoal, in: 6...12) {
                        Text("Sleep goal is \(settings.sleepGoal) hours")
                    }
                }

                if !settings.isPro {
                    Section {
                        Button(action: {
                            self.settings.unlockPro()
                        }) {
                            Text("Unlock PRO")
                        }

                        Button(action: {
                            self.settings.restorePurchase()
                        }) {
                            Text("Restore purchase")
                        }
                    }
                }
                }
                .navigationBarTitle(Text("Settings"))
        }
    }
}
```

As you can see we are wrapping our layout code inside the *Form* component. *Form* component uses grouped *List* to present every child inside the cell. By wrapping layout inside the *Form*, *SwiftUI* changes the visual appearance for every element. You can simply replace the *Form* with *VStack* to check the difference between them. Even *Picker* looks different. It uses a separated screen with *List* to show the items. We don't need to do something, and we have this behavior out of the box. This is where the real power of declarative programming is coming. Every component has different adaptive appearances, which we can easily change by wrapping it into another container. Here is the screenshot of the final result.

![Settings screen](/public/settings.jpg)

#### Conclusion

I enjoy how easy we can build apps with *SwiftUI*. You can use *Form* component for making complex Form layouts with a lot of sections and choices for data entry. I hope you love *SwiftUI* as much as me because I'm going to cover more *SwiftUI* topics soon.