![Logo][image-1]

[![CocoaPods Version][image-2]][1]
![GitHub Tag][image-3]
![GitHub Release][image-4]

[![Semantic Versioning][image-5]][2]
![License][image-6]
![Platform][image-7]

## IIViewDeckController

ViewDeck is a framework to manage side menus of all kinds. It supports left and right menus and manages the presentation of the side menus both programmatically and through user gestures.

The heart of ViewDeck is `IIViewDeckController`, which is a container view controller. You can then assign your center view controller to it as well as side view controllers. `IIViewDeckController` makes sure your content view controllers are added to the view controller hierarchy their views are added to the view hierarchy when needed.

ViewDeck does not provide any kind of configurable menus. It is up to you to assign your center and side view controllers to ViewDeck so that ViewDeck can then take over and present them as necessary.

`IIViewDeckController` supports both a left and a right side view controller and of course you can also only use one side. You can open and close the side views programmatically, e.g. through a tap of a button. By default `IIViewDeckController` also listens to swipe gestures by the user and interactively opens the side views accordingly.

Of course ViewDeck plays nice with existing container view controllers such as `UINavigationController` or `UITabBarController`.

## Requirements

- Base SDK: iOS 10
- Deployment Target: iOS 8.0 or greater
- Xcode 8.x

## Try it out

The easiest way to try out ViewDeck is using cocoapods. By running `pod try ViewDeck` an Xcode project will be created that runs the demo app. Of course you can also simply check out the repository and run the example app there. Just open the `ViewDeckExample.xcworkspace` file in the `Example` folder and run it.

## Demo video & Screenshots

You're probably curious how it looks. Here's some shots from the example app:

![ViewDeck on iPhone][image-9]

![ViewDeck on iPad][image-8]

See the controller in action:

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/zgh3ZDAWyK4/0.jpg)](https://www.youtube.com/watch?v=zgh3ZDAWyK4)

## Installation

### CocoaPods

Integrating ViewDeck via CocoaPods is the easiest and fastest way to get started. Simply add the following line into your `Podfile`:

`pod 'ViewDeck'`

This will get you the latest ViewDeck version every time you type `pod update` in your terminal.

If you prefer a more conservative integration, you can also go with the following line:

`pod 'ViewDeck', '~> 3.0'`

This will update all 3.x version if you execute `pod update` but it will not update to version 4.x once this is released. ViewDeck follows semantic versioning, meaning that within a given major version (currently 3.x) there will be no breaking changes. You may see deprecations appear on methods that are likely to go away in the next major release but until then they will continue to work.

After integrating ViewDeck via CocoaPods, all you need to do is `#import <ViewDeck/ViewDeck.h>` in a class where you want to use ViewDeck.

### Manually

- Download the latest ViewDeck release from the [release section][3]
- Move the `ViewDeck.framework` into your Xcode project

## Getting started
ViewDeck supports a left and a right side view controller. Each of these can be nil (if it is, no panning or opening to that side will work and gesture recognizers for this side are deactivated). The base class for everything is `IIViewDeckController`. A typical view deck configuration looks like this:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	MyCenterViewController *centerViewController = [MyCenterViewController new];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
	
	MySideViewController *sideViewController = [MySideViewController new];
	UINavigationController *sideNavigationController = [[UINavigationController alloc] initWithRootViewController:sideViewController];
	
	IIViewDeckController *viewDeckController = [[IIViewDeckController alloc] initWithCenterViewController:navigationController rightViewController:sideNavigationController];
	
	self.window.rootViewController = viewDeckController;
	[self.window makeKeyAndVisible];
	return YES;
}
```

### Switching controllers

You can also switch view controllers in mid flight. Just assign a view controller to the appropriate property and the view deck controller will do the rest:

```objc
// prepare view controllers
UIViewController* newController = [[UIViewController alloc] init];
self.viewDeckController.rightController = newController;
```

You can also use this to remove a side controller by just setting it to `nil`.

### Accessing the view deck controller

Like `UINavigationViewController` the `IIViewDeckController` assigns itself to its childviews. You can use the `viewDeckController` property to get access to the enclosing view deck controller:

```objc
#import <ViewDeck/ViewDeck.h>
...
[self.viewDeckController openSide:IIViewDeckSideRight animated:YES];
```

If the controller is not enclosed by `IIViewDeckController`, this property returns `nil`.

### Controlling the side’s size

ViewDeck tries to embed into UIKit as nice as possible and therefore leverages a lot of already existing hooks. In order to control a side view controller’s size on the screen, you simply set its `preferredContentSize`. ViewDeck will respect the width of this size while making sure the height is always the height of the view deck controller itself.

### Customizing the side’s appearance and animations

You can customize a lot about how ViewDeck presents side view controllers. Check out the documentation on `-[IIViewDeckController animatorForTransitionWithContext:]` and `IIViewDeckTransitionAnimator`.

## Special Thanks

Special thanks to [Tom Adriaenssen][4] who started this project and created a very great framework that helps so many developers. Sadly he can no longer maintain this framework. Check out his blog if you want to find out why, it’s actually pretty good news, so congratulations, Tom! :)

Very special thanks to the awesome [Samo Korosec][5] for designing the beautiful logo for ViewDeck! He is a very great designer and a very funny colleague. If you need cool app design work done, check him out!

## Credits

I would appreciate it to mention the use of this code somewhere if you use it in an app. On a website, in an about page, in the app itself, whatever. Or let me know by email or through github. It's nice to know where one's code is used. Also, if you have a cool app that uses view deck, and you want it to be listed here, let me know!

## License

**IIViewDeckController** published under the MIT license:

*Copyright (C) 2011-2015, ViewDeck*

*Permission is hereby granted, free of charge, to any person obtaining a copy of*
*this software and associated documentation files (the "Software"), to deal in*
*the Software without restriction, including without limitation the rights to*
*use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies*
*of the Software, and to permit persons to whom the Software is furnished to do*
*so, subject to the following conditions:*

*The above copyright notice and this permission notice shall be included in all*
*copies or substantial portions of the Software.*

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*
*IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,*
*FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE*
*AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*
*LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,*
*OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE*
*SOFTWARE.*

[1]:	https://cocoapods.org/pods/ViewDeck
[2]:	http://semver.org
[3]:	https://github.com/ViewDeck/ViewDeck/releases
[4]:	http://inferis.org/
[5]:	https://twitter.com/smoofles

[image-1]:	logo-header.png
[image-2]:	https://img.shields.io/cocoapods/v/ViewDeck.svg?style=flat-square
[image-3]:	https://img.shields.io/github/tag/ViewDeck/ViewDeck.svg?style=flat-square
[image-4]:	https://img.shields.io/github/release/ViewDeck/ViewDeck.svg?style=flat-square
[image-5]:	https://img.shields.io/badge/semantic-versioning-orange.svg?style=flat-square
[image-6]:	https://img.shields.io/cocoapods/l/AFNetworking.svg?style=flat-square
[image-7]:	https://img.shields.io/cocoapods/p/ViewDeck.svg?style=flat-square
[image-8]:	https://cldup.com/PR00jqJzsS.png
[image-9]:	https://cldup.com/8bIJ_PgdIP.png
