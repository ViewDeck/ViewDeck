# IIViewDeckController

When I saw the new UI in the Path 2.0 app, extending the sliding views UI found in the Facebook app, I wanted to recreate this effect and controller for myself. Mostly as an exercise, but it might come in handy later.
A quick prototype was built in one evening, but the finetuning took a few more evenings. 

The ViewDeckController supports both a left and a right sideview (in any combination: you can leave one of them `nil` for example). You can pan the center view to the left or to the right. There's also a bunch of messages defined to open or close each side appropriately. 

The class is built so that it augments current navigation technologies found in IOS.

The controller supports rotation, too.

# Requirements

The library supports both ARC and non-ARC projects (the ARC mode is detected automagically, and the code is modified where necessary according to the ARC mode in use).  

# Demo

See: http://vimeo.com/34538429

# Installation

Easy as pie: you just add `IIViewDeckController.h` and `IIViewDeckController.m` to your project.
Just add IIViewDeckController.m/h into your project.

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

The controller fully supports view rotation. If the center controller is set, it will control the possible interface rotation. If no center controller is set, all interface rotations are allowed. 
When rotating, the controller will move the open center views to the correct location: the ledge will be the same before and after rotation (this means a different part of the underlying side view will be exposed). You can control this behavior through the `rotationBehavior` property. You can use one of the following values:

    typedef enum {
        IIViewDeckRotationKeepsLedgeSizes, // when rotating, the ledge sizes are kept (side views are more/less visible)
        IIViewDeckRotationKeepsViewSizes  // when rotating, the size view sizes are kept (ledges change)
    } IIViewDeckRotationBehavior;

The default is `IIViewDeckRotationKeepsLedgeSizes`, which keeps the sizes of the defined ledges the same when rotating.

## panning

It is possible to control the panning behavior a bit. Set the `panningMode` on the controller to achieve 3 different modes:

    typedef enum {
        IIViewDeckNoPanning,              // no panning allowed
        IIViewDeckFullViewPanning,        // the default: touch anywhere in the center view to drag the center view around
        IIViewDeckNavigationBarPanning,   // panning only occurs when you start touching in the navigation bar (when the center controller is a UINavigationController with a visible navigation bar). Otherwise it will behave as IIViewDeckNoPanning. 
        IIViewDeckPanningViewPanning      // panning only occurs when you start touching in a UIView set in panningView property
    } IIViewDeckPanningMode;

When you specify `IIViewDeckPanningViewPanning`, you have to set the `panningView` property on the controller. This view will react to pan motions that will pan the view deck.

## disabling the center view

The center view can be disabled if it is slided out of the way. You do this by setting the `centerhiddenInteractivity` property on the controller.

    typedef enum {
        IIViewDeckCenterHiddenUserInteractive,         // the center view stays interactive
        IIViewDeckCenterHiddenNotUserInteractive,      // the center view will become nonresponsive to useractions
        IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, // the center view will become nonresponsive to useractions, but will allow the user to tap it so that it closes
        IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing, // same as IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, but closes the center view bouncing
    } IIViewDeckCenterHiddenInteractivity;

When you need to change the centercontroller (or something else) when the center view is bounced away, use the following message to react:
    
     - (void)viewDeckController:(IIViewDeckController *)viewDeckController didBounceWithClosingController:(UIViewController*)openController;

# UINavigationController

The view deck controller has two integration modes to deal with `UINavigationController`. The first mode `IIViewDeckNavigationControllerContained` will have the navigation controller act as a normal "contained" view controller. All pushes and pops will remain in the centerview.

The other mode `IIViewDeckNavigationControllerIntegrated` has different behavoir: it allows you to "inject" the viewdeck controller into an existing navigation controller hierarchy. The feature example (see below) has the simple scenario: the center view is a navigation controller. Any action in that navigation controller stays in the centerview.

But if you push a `IIViewDeckController` onto a navigation controller, the sideviews will nestly themselves _below_ the navigation view. This means that the animations regarding the navigation controller will be applied only to the center view controller and not to the side view controllers. 
There's currently no way to disable this behavior, but it will be added later.

# ViewDeckExample

This is a simple example mimicing the Path 2.0 UI to a certain extent.

# FeatureExample

This is a more extensive example. You can specify the different choices for the settable behavioral property and test them out live.

# SizingEample

This is a test program to test out sizing behavior. It presents a view with a viewdeck controller in, and a zoom button. The zoom button enlarges/shrinks the view. The view deck controller should resize along.

# Credits

I'd appreciate it to mention the use of this code somewhere if you use it in an app. On a website, in an about page, in the app itself, whatever. Or let me know by email or through github. It's nice to know where one's code is used. 

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

