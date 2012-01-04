# IIViewDeckController

When I saw the new UI in the Path 2.0 app, extending the sliding views UI found in the Facebook app, I wanted to recreate this effect and controller for myself. Mostly as an exercise, but it might come in handy later.
A quick prototype was built in one evening, but the finetuning took a few more evenings. 

The ViewDeckController supports both a left and a right sideview (in any combination: you can leave one of them `nil` for example). You can pan the center view to the left or to the right. There's also a bunch of messages defined to open or close each side appropriately. 

The class is built so that it augments current navigation technologies found in IOS. For example: if you want a 

# Requirements

The library currently requires ARC. This means you can use it only for iOS5 projects. Reworking the code so that &lt;iOS5 is supported too. 

# Demo

<iframe src="http://player.vimeo.com/video/34538429?title=0&amp;byline=0&amp;portrait=0&amp;color=ff9933" width="500" height="525" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>

# Installation

Easy as pie: you just add `IIViewDeckController.h` and `IIViewDeckController.m` to your project.
Just add DDMenuController.m/h into your project.

# How to use it?

## Factories
The class currently supports a left and a right side controller. Each of these can be nil (if it is, no panning or opening to that side will work).

    #import "IIViewDeckController.h"

    // prepare view controllers
    UIViewController* leftController = [[UIViewController alloc] init]; 
    UIViewController* rightController = [[UIViewController alloc] init]; 

    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.centerController leftViewController:leftController
                                                      rightViewController:rightController];

There's also two convenience factory methods for just a left or right view controller.

## Switching controllers

You can also switch view controllers in mid flight. Just assign a viewcontroller to the appropriate property and the view deck controller will do the rest:

    // prepare view controllers
    UIViewController* newController = [[UIViewController alloc] init]; 
    self.viewDeckController.leftViewController = newController;

You can also use this to remove a side controller: just set it to `nil`.

## viewDeckController property

Like `UINavigationViewController` the `IIViewDeckController` assigns itself to its childviews. You can use the `viewDeckController` property to get access to the enclosing view deck controller:

    [self.viewDeckController toggleLeftViewAnimated:YES]

If the controller is not enclosed by a IIViewDeckController, this property returns `nil`.

## ledges

You cannot close the centerview completely, since it would block the user from panning it back. A minimum *ledge* of 10 pixels is observed. You can set the ledge sizes yourself by assigning a value to the `leftLedge` property for the left side and the `rightLedge` property for the right side.

## bouncing close

The controller also allows you to close the side views with a bouncing animation like Path does. To achieve this, use the `closeLeftViewBouncing:` and `closeRightViewBouncing:` methods. These take a block as their only parameter: this block is executed while the animation is running, on the exact moment where the center view is completely hidden from the view (the animation first fully opens the side view, and then closes it). This block allows you to change the centerview controller, for example (since it's obscured). You can pass `nil` if you don't need to execute something in the middle of the animation. 

	[self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
		controller.centerViewController = [UIViewController alloc] init];
		// ...
    }];

## shadow

The center controller view receives a shadow to give it an *on-top* appearance. There's currently no wait to customize this directly without editing the code.

## rotation

The controller should support view rotation. If the center controller is set, it will control the possible interface rotation. If no center controller is set, all interface rotations are allowed. 

The current implementation is a bit flakey, in respect to the right view controller and the ledge setting. 

## panning

It is possible to control the panning behavior a bit. Set the `panningMode` on the controller to achieve 3 different modes:

	typedef enum {
	    IIViewDeckNoPanning,              // no panning allowed
	    IIViewDeckFullViewPanning,        // the default: touch anywhere in the center view to drag the center view around
	    IIViewDeckNavigationBarPanning,   // panning only occurs when you start touching in the navigation bar (when 
		                                  // the center controller is a UINavigationController with a visible
		                                  // navigation bar). Otherwise it will behave as IIViewDeckNoPanning. 
	} IIViewDeckPanningMode;

# UINavigationController

It is possible to "inject" the viewdeck controller into an existing navigation controller hierarchy. The example (see below) has the simple scenario: the center view is a navigation controller. Any action in that navigation controller stays in the centerview.

But if you push a `IIViewDeckController` onto a navigation controller, the sideviews will nestly themselves _below_ the navigation view. This means that the animations regarding the navigation controller will be applied only to the center view controller and not to the side view controllers. 
There's currently no way to disable this behavior, but it will be added later.

# ViewDeckExample

todo

# License

**IIViewDeckController** published under the MIT license:

*Copyright (C) 2011, Tom Adriaenssen*

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

