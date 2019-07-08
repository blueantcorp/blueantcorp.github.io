---
layout: post
title: Swift 5 — Access Control
date: 2019-06-30 21:00:00 +0000
description: Access control* restricts access to parts of your code from code in other
  source files and modules. This feature enables you to hide the implementation details
  of your code, and to specify a preferred interface through which that code can be
  accessed and used.

---
Access control* restricts access to parts of your code from code in other source files and modules. This feature enables you to hide the implementation details of your code, and to specify a preferred interface through which that code can be accessed and used.

You can assign specific access levels to individual types (classes, structures, and enumerations), as well as to properties, methods, initializers, and subscripts belonging to those types. Protocols can be restricted to a certain context, as can global constants, variables, and functions.

In Swift 3 and swift 4, we have **open**, **public**, **internal**, **fileprivate**, and **private** for access control.Open access is the highest (least restrictive) access level and private access is the lowest (most restrictive) access level.

> Almost all entities in your code have a default access level of **internal** if you do not specify an explicit access level yourself. As a result, in many cases you do not need to specify an explicit access level in your code.

\[As of **Swift 4**, there are 5 **levels of access**\]([https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AccessControl.html](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AccessControl.html "https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AccessControl.html")), described below from the highest (least restrictive) to the lowest (most restrictive).

\### 1. \`open\` and \`public — \`(least restrictive)

Enable an entity to be used outside the defining module (target). You typically use \`open\` or \`public\` access when specifying the public interface to a framework.

Let’s consider an example. Everybody (iOS developers) knows about UIKit. We often use many UI elements from UIKit daily. When you try to use the UIComponents such as UIButton, UICollectionView, UITableView, UIViewController etc.., you have to import the **UIKit** on the top. So UIKit is actually a module that we can import to our class and subclass its features.

We can subclass UITableView from your viewController as it is having an access level of **open**. Just cmf + click on UITableView class and you can see this.

\`\`\`

@available(iOS 2.0, *)

open class UITableView : UIScrollView, NSCoding { }

\`\`\`

Since it is open, we can subclass it from our ViewController and use it.

\`\`\`

tableView: UITableView() {} // some another module

\`\`\`

\### 2. Public

Like open access level, public access level enable an entity to be used outside the defining module (target). But open access level allows us to subclass it from another module where in public access level, we can only subclass or overridde it from within the module it is defined. Look at the following example.

\`\`\`

//module 1

public func A(){}

open func B(){}

//module 2

override func A(){} // error

override func B(){} // success

\`\`\`

Method A declared in module 1 as a public method cannot be accessed from module 2.It gives error . But Method B declared in module 1 as an open method can be accessed from module 2.

So by keeping it simple, \`**open**\` **access applies only to classes and class members**, and it differs from \`public\`access as follows:

\- \`public\` classes and class members can only be subclassed and overridden within the defining module (target).

\- \`open\` classes and class members can be subclassed and overridden both within and outside the defining module (target).

Open access applies only to classes and class members, and it differs from public access as follows:

\- Classes with public access, or any more restrictive access level, can be subclassed only within the module where they’re defined.

\- Class members with public access, or any more restrictive access level, can be overridden by subclasses only within the module where they’re defined.

\- Open classes can be subclassed within the module where they’re defined, and within any module that imports the module where they’re defined.

\- Open class members can be overridden by subclasses within the module where they’re defined, and within any module that imports the module where they’re defined.

> Marking a class as open explicitly indicates that you’ve considered the impact of code from other modules using that class as a superclass, and that you’ve designed your class’s code accordingly.

\### 3. internal (default access level)

\**internal** is the default access level. Internal classes and members can be accessed anywhere within the same module(target) they are defined. You typically use \`internal\`access when defining an app’s or a framework’s internal structure.

Lets consider another example from UIKit to explain this. Suppose there is an internal method declared inside the UIKit module. Let’s say a method called \`internalMethod()\` .

\`\`\`

internal func internalMethod() {

 print("I am inside UIKit")

}

\`\`\`

Even if we import \`UIKit\`, we cannot use the \`internalMethod()\` inside our ViewController. It can only be accessed anywhere within the same module of UIKit.

\### 4. \`fileprivate\`

Restricts the use of an entity to its defining source file. You typically use \`fileprivate\` access to hide the implementation details of a specific piece of functionality when those details are used within an entire file. ie; the functionality defined with a \`fileprivate\` access level can only be accessed from within the swift file where it is defined.

\`\`\`

// A.swift

fileprivate func someFunction() {

 print("I will only be called from inside A.swift file")

}

// viewcontroller.swift

override func viewDidLoad() {

 super.viewDidLoad()

let obj = A()

 A.someFunction() // error

}

\`\`\`

\### 5. \`private — \`(most restrictive)

\**Private access restricts the use of an entity to the enclosing declaration, and to extensions of that declaration that are in the same file**. You typically use \`private\` access to hide the implementation details of a specific piece of functionality when those details are used only within a single declaration.

\`\`\`

// A.swift

class A {

 private var name = "First Letter"

}

extension A {

func printName(){

print(name) // you may access it here from swift 4. Swift 3 will throw error.

}

}

A() 

A().name // Error even if accessed from outside the class A{} of A.swift file.

\`\`\`

> Important: Before swift 4, private access level didn’t allow the use of a class member inside the extension of same class.

\#### Important with private access level for swift 3:

If you are familiar with extensions, you might have already fallen in love with it. Extension is the way by which we can add functionality to a class, enum or struct. Suppose if we have a class called A and we have to add a new functionality to it, use an extension as shown below.

\`\`\`

extension A {

   // new functionality can be added here

}

\`\`\`

Let’s look at a situation: Suppose I have a view controller that has a property which I do not want to be accessed outside of the source file.

\`\`\`

class RootViewController: UIViewController {

  private var someFlag = false

}

\`\`\`

Unfortunately, using Swift 3, if I now try to access this property from a class extension, in the same source file, I hit a problem:

\`\`\`

extension RootViewController: someDelegate {

  func doSomething {

    if someFlag { //error :Use of unresolved identifier 'someFlag'

      // do the thing

    }

  }

}

\`\`\`

The problem is that the \`private\` access level restricts access to the property to the enclosing class declaration. The extension is not allowed access even though it is in the same source file. The solution is to switch the access level to \`fileprivate\`:

\`\`\`

class RootViewController: UIViewController {

  fileprivate var someFlag = false

}

\`\`\`

\**Note: The above section is meant for swift 3 only. The access control of private access level is changed in swift 4 as mentioned in the previous section.**

\#### Interview questions:

\- **What is the difference between public and open?**

Entities that are declared public or open are accessible from the module in which they are defined and from any module that imports the module they are defined in. The open access level was introduced to impose limitations on class inheritance in Swift.Open access level can only be applied to classes and class members, such as properties and methods.

\- An \`open\` class is *accessible* and *subclassable* outside of the defining module. An \`open\` class member is *accessible* and *overridable* outside of the defining module.

\- A \`public\` class is *accessible* but *not subclassable* outside of the defining module. A \`public\`class member is *accessible* but *not overridable* outside of the defining module.

Keeping it short, Both public and open comes to play only between modules. Internal access mode will give public access throughout the same module.

\**Ex:** *If you are creating a framework for facebook login in swift*. The developer will import the framework you created and try to call the \`login()\` function. if you want the developer to call this method, it should be declared as \`public\`inside the framework. If you want the developer to call the function and override the \`login()\` function, it should be declared as \`open\`. Simple!!

\- **What is the default access level in swift?**

It is \`Internal\` . If we don’t mention an access level before any variable, constant or function, it is \`Internal\` by default. It’s explained in the above section.

Thats it! enjoy …Happy coding..!