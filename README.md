# IIViewDeckController

When I saw the new UI in the Path 2.0 app, extending the sliding views UI found in the Facebook app, I wanted to recreate this effect and controller for myself. Mostly as an exercise, but it might come in handy later.
A quick prototype was built in one evening, but the finetuning took a few more evenings.

The ViewDeckController supports both a left and a right sideview (in any combination: you can leave one of them `nil` for example). You can pan the center view to the left or to the right. There's also a bunch of messages defined to open or close each side appropriately.

The class is built so that it augments current navigation technologies found in IOS.

# Requirements

The library supports both ARC and non-ARC projects (the ARC mode is detected automagically, and the code is modified where necessary according to the ARC mode in use).

# Demo video & Screenshots

You're probably curious how it looks. Here's some shots from the example app:

![Left opened](http://cl.ly/063X412a1i2U2e3f3D02/Image%202012.01.26%2023:26:55.png) ![Right opened](http://cl.ly/381S0i1c2c1Z2l2U3303/Image%202012.01.26%2023:29:31.png)

See the controller in action: http://vimeo.com/34538429 (general demo) and http://vimeo.com/35716738 (elasticity).
These are demos of the included `ViewDeckExample` app.

# Installation

- Add `IIViewDeckController.h` and `IIViewDeckController.m` to your project.
- Link the `QuartzCore.framework`
- `#import "IIViewDeckController.h"` to use it in a class

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
    self.viewDeckController.leftController = newController;

You can also use this to remove a side controller: just set it to `nil`.

## viewDeckController property

Like `UINavigationViewController` the `IIViewDeckController` assigns itself to its childviews. You can use the `viewDeckController` property to get access to the enclosing view deck controller:

    [self.viewDeckController toggleLeftViewAnimated:YES]

If the controller is not enclosed by a IIViewDeckController, this property returns `nil`.

## ledge sizes

You cannot close the centerview completely, since it would block the user from panning it back. You can set the ledge sizes yourself by assigning a value to the `leftSize` property for the left side and the `rightSize` property for the right side. It is possible to set a ledge size of 0.

### maximum ledge size, or gap-mode

It is possible to have the viewController always show a side controller. You do this by setting the `maxSize` value to any (positive) nonzero value. This will force the centerview to be always opened, exposing a side controller permanently. **This only works when you have ONE sidecontroller specified** (this means either a left side controller or a right side controller), because this scenario does not make sense if you would be able to slide the center view in both directions. When you have 2 side controllers, this property is ignored.

## bouncing close

The controller also allows you to close the side views with a bouncing animation like Path does. To achieve this, use the `closeLeftViewBouncing:` and `closeRightViewBouncing:` methods. These take a block as their only parameter: this block is executed while the animation is running, on the exact moment where the center view is completely hidden from the view (the animation first fully opens the side view, and then closes it). This block allows you to change the centerview controller, for example (since it's obscured). You can pass `nil` if you don't need to execute something in the middle of the animation.

	[self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
		controller.centerController = [UIViewController alloc] init];
		// ...
    }];

## open/close animation duration

The view deck controller allows you to set the speed at which the opening and closing animations play. To do so, use the following properties.

    self.viewDeckController.openSlideAnimationDuration = 0.15f; // In seconds
    self.viewDeckController.closeSlideAnimationDuration = 0.25f;

The default speed of both, if not set, is 0.3f.

## bounce animation duration

You can set the duration of the bounce animation as a factor (multiple) of the close/openSlideAnimationDurations. To control both the open and close of the bounce, you can simply use:
    self.viewDeckController.bounceDurationFactor = 0.5; // Animate at twice the speed (half the duration)

The default factor is 1.0 if bounceDurationFactor is not set.

For even more control, you can also set the animation duration for the bounce open (the first part of the bounce):
    self.viewDeckController.bounceOpenSideDurationFactor = 0.3f;

If bounceOpenSideDurationFactor is not set, it will fallback to the bounceDurationFactor behavior. If bounceOpenSideDurationFactor is set, bounceDurationFactor affects only the "close" (2nd half) of the bounce animation.

## shadow

The center controller view receives a shadow to give it an *on-top* appearance. The shadow is defined by the view deck controller.
You can override the shadow (or leave it out alltogether) by assigning a delegate that implements the `viewDeckController:applyShadow:withBounds:` selector. You'll be passed the layer of the view on which the shadow should be set.  If you override said selector, setting the shadow is up to you, and the view deck controller will not apply any shadow itself.

For example:

    // applies a small, red shadow
    - (void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
        shadowLayer.masksToBounds = NO;
        shadowLayer.shadowRadius = 5;
        shadowLayer.shadowOpacity = 0.9;
        shadowLayer.shadowColor = [[UIColor redColor] CGColor];
        shadowLayer.shadowOffset = CGSizeZero;
        shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:rect] CGPath];
    }

The bounds passed in through `rect` can be used for setting the shadow path to the layer, for performance reasons. It will be set to the bounds of the center view.

## elasticity

The controller supports "elasticity": when you pan the center view "over" one of the ledges, you'll see that it gets pulled a bit further, but you can't pull it all the way to the edge. When you let go, it jumps back to the set ledge size. This gives the controller behavior are a more lifelike feel.

Of course, you can turn this behavior off. Just set `elasticity = NO` when loading the controller and you're set.

When rotating, the controller will move the open center views to the correct location: the ledge will be the same before and after rotation (this means a different part of the underlying side view will be exposed). You can control this behavior through the `sizeMode` property. You can use one of the following values:
    typdef enum {
        IIViewDeckLedgeSizeMode, // when rotating, the ledge sizes are kept (side views are more/less visible)
        IIViewDeckViewSizeMode  // when rotating, the size view sizes are kept (ledges change)
    } IIViewDeckSizeMode;
The default is `IIViewDeckLedgeSizeMode`, which keeps the sizes of the defined ledges the same when rotating.
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

*Copyright (C) 2011-2013, Tom Adriaenssen*

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

