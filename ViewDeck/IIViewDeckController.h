//
//  IIViewDeckController.h
//  IIViewDeck
//
//  Copyright (C) 2011-2016, ViewDeck
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>

#import "IIEnvironment.h"


// thanks to http://stackoverflow.com/a/8594878/742176

NS_ASSUME_NONNULL_BEGIN

#define II_DEPRECATED_DROP __deprecated_msg("This method is deprecated and will go away in 3.0.0 without a replacement. If you think it is still needed, please file an issue at https://github.com/ViewDeck/ViewDeck/issues/new")

typedef NS_ENUM(NSInteger, IIViewDeckPanningMode) {
    IIViewDeckNoPanning,              /// no panning allowed
    IIViewDeckFullViewPanning,        /// the default: touch anywhere in the center view to drag the center view around
    IIViewDeckNavigationBarPanning,   /// panning only occurs when you start touching in the navigation bar (when the center controller is a UINavigationController with a visible navigation bar). Otherwise it will behave as IIViewDeckNoPanning.
    IIViewDeckPanningViewPanning,      /// panning only occurs when you start touching in a UIView set in panningView property
    IIViewDeckDelegatePanning,         /// allows panning with a delegate
    IIViewDeckNavigationBarOrOpenCenterPanning,      /// panning occurs when you start touching the navigation bar if the center controller is visible.  If the left or right controller is open, pannning occurs anywhere on the center controller, not just the navbar.
    IIViewDeckAllViewsPanning,        /// you can pan anywhere in the viewdeck (including sideviews)
};


typedef NS_ENUM(NSInteger, IIViewDeckCenterHiddenInteractivity) {
    IIViewDeckCenterHiddenUserInteractive,         /// the center view stays interactive
    IIViewDeckCenterHiddenNotUserInteractive,      /// the center view will become nonresponsive to useractions
    IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, /// the center view will become nonresponsive to useractions, but will allow the user to tap it so that it closes
    IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing, /// same as IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, but closes the center view bouncing
};


typedef NS_ENUM(NSInteger, IIViewDeckSizeMode) {
    IIViewDeckLedgeSizeMode, /// when rotating, the ledge sizes are kept (side views are more/less visible)
    IIViewDeckViewSizeMode  /// when rotating, the size view sizes are kept (ledges change)
};


typedef NS_ENUM(NSInteger, IIViewDeckDelegateMode) {
    IIViewDeckDelegateOnly, /// call the delegate only
    IIViewDeckDelegateAndSubControllers  /// call the delegate and the subcontrollers
};



#define IIViewDeckCenterHiddenCanTapToClose(interactivity) ((interactivity) == IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose || (interactivity) == IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing)
#define IIViewDeckCenterHiddenIsInteractive(interactivity) ((interactivity) == IIViewDeckCenterHiddenUserInteractive)


FOUNDATION_EXPORT NSString* NSStringFromIIViewDeckSide(IIViewDeckSide side);


@class IIViewDeckController;

/**
 The delegate of a `IIViewDeckController` is used to inform the delegate of changes
 the view deck controller is undergoing, like opening or closing sides.
 */
@protocol IIViewDeckControllerDelegate <NSObject>
@optional

/// @name Open and Close Sides

/**
 Tells the delegate that the specified side will open.

 @param viewDeckController The view deck controller informing the delegate.
 @param side               The side that will open. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.

 @return `YES` if the View Deck Controller should open the side in question, `NO` otherwise.
 */
- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController willOpenSide:(IIViewDeckSide)side;

/**
 Tells the delegate that the specified side did open.

 @param viewDeckController The view deck controller informing the delegate.
 @param side               The side that did open. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
 */
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenSide:(IIViewDeckSide)side;

/**
 Tells the delegate that the specified side will close.

 @param viewDeckController The view deck controller informing the delegate.
 @param side               The side that will close. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
 
 @return `YES` if the View Deck Controller should close the side in question, `NO` otherwise.
 */
- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController willCloseSide:(IIViewDeckSide)side;

/**
 Tells the delegate that the specified side did close.

 @param viewDeckController The view deck controller informing the delegate.
 @param side               The side that did close. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
 */
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseSide:(IIViewDeckSide)side;

@end


@protocol IIViewDeckTransitionAnimator, IIViewDeckTransitionContext;

/**
 The `IIViewDeckController` is the hart of ViewDeck. It is the main view controller
 controlls the content and whether or not a side bar is presented.
 
 The `IIViewDeckController` is a container view controller that uses the view controller
 hierarchy to display it's content. You always need to define a center view controller.
 This is the view controller that is visible in the center of the `IIViewDeckController`
 and has the same size. You can optionally set a left view controller and / or a
 right view controller that slides in from the left or right side either programatically
 or through a user action.
 
 # Controlling the size of a side view controller
 
 A side view controller always has the same height as the view deck controller
 itself. You can control the width of the view controller by setting `preferredContentSize`
 on your left or right content view controller, similar like you do when presenting
 a view controller as a popover.
 
 # Customizing the appearance
 
 By default side view controllers can slide in from the left or the right and while
 sliding in, a dimm view will be faded in between the center view controller and
 the side view controller to give it a nice iOS like look and feel. However this
 might not be suitable for all cases. You have multiple ways of customizing this
 appearance. The current methods of customization are listed under 'Customizing
 Transitions'. If you feel the current options are not suitable for you, please
 file an issue at https://github.com/ViewDeck/ViewDeck
 */
@interface IIViewDeckController : UIViewController


/// @name Initializing a View Deck Controller

/**
 Initialises an instance of `IIViewDeckController` with the given view controller
 as the center view controller.
 
 When using this method, the receiver has no left or right view controller after
 initialization and you need to set these manually via `setLeftViewController:`
 or `setRightViewController:`.
 
 @see initWithCenterViewController:leftViewController:
 @see initWithCenterViewController:rightViewController:
 @see initWithCenterViewController:leftViewController:rightViewController:

 @param centerController The view controller that should be responsible for the
                         view in the center of the view deck controller.

 @return A newly initialized instance of `IIViewDeckController`.
 */
- (instancetype)initWithCenterViewController:(UIViewController*)centerController;

/**
 Initialises an instance of `IIViewDeckController` with the given center and left
 view controller.

 When using this method, the receiver has no right view controller after
 initialization and you need to set this manually via `setRightViewController:`
 if you want to add one.

 @param centerController The view controller that should be responsible for the
                         view in the center of the view deck controller.
 @param leftController   The view controller that should be responsible for the
                         view on the left side of the view deck controller.

 @return A newly initialized instance of `IIViewDeckController`.
 */
- (instancetype)initWithCenterViewController:(UIViewController*)centerController leftViewController:(nullable UIViewController*)leftController;

/**
 Initialises an instance of `IIViewDeckController` with the given center and
 right view controller.

 When using this method, the receiver has no left view controller after
 initialization and you need to set this manually via `setLeftViewController:`
 if you want to add one.

 @param centerController The view controller that should be responsible for the
                         view in the center of the view deck controller.
 @param rightController  The view controller that should be responsible for the
                         view on the right side of the view deck controller.

 @return A newly initialized instance of `IIViewDeckController`.
 */
- (instancetype)initWithCenterViewController:(UIViewController*)centerController rightViewController:(nullable UIViewController*)rightController;

/**
 Initialises an instance of `IIViewDeckController` with the given center, left,
 and right view controller.
 
 @note This is the designated initializer.

 @param centerController The view controller that should be responsible for the
                         view in the center of the view deck controller.
 @param leftController   The view controller that should be responsible for the
                         view on the left side of the view deck controller.
 @param rightController  The view controller that should be responsible for the
                         view on the right side of the view deck controller.

 @return A newly initialized instance of `IIViewDeckController`.
 */
- (instancetype)initWithCenterViewController:(UIViewController*)centerController leftViewController:(nullable UIViewController*)leftController rightViewController:(nullable UIViewController*)rightController NS_DESIGNATED_INITIALIZER;


/// @name Managing the Delegate

@property (nonatomic, weak) id<IIViewDeckControllerDelegate> delegate;


/// @name Maintaining the Content View Controllers

/**
 The view controller that is responsible for the view in the center of the view
 deck controller.
 */
@property (nonatomic) UIViewController* centerViewController;

/**
 The view controller that is responsible for the view on the left side of the
 view deck controller.
 
 @warning Setting this view controller while is is already on screen will
          trigger an exception.
 */
@property (nonatomic, nullable) UIViewController* leftViewController;

/**
 The view controller that is responsible for the view on the right side of the
 view deck controller.

 @warning Setting this view controller while is is already on screen will
          trigger an exception.
 */
@property (nonatomic, nullable) UIViewController* rightViewController;


/// @name Managing Transitions

/**
 The side of the view deck controller that is currently open or `IIViewDeckSideNone`
 if no side is currently open and the center view controller is the only
 controller that the view deck controller is currently showing.
 
 @see openSide:animated:
 */
@property (nonatomic) IIViewDeckSide openSide;

/**
 Opens the passed in side.
 
 Opening a side that is already open does nothing.
 
 @note You can only switch between no view controller (`IIViewDeckSideNone`) or
       either the left (`IIViewDeckSideLeft`) or right (`IIViewDeckSideRight`)
       view controller. You can not switch directly from left to right without
       dismissing the open side first.
 
 @see closeSide:

 @param side     The side you want to open.
 @param animated `YES` if you want to animate the transition, `NO` otherwise.
 */
- (void)openSide:(IIViewDeckSide)side animated:(BOOL)animated;

/**
 Closes the currently open side.
 
 Closing a side when no side is open does nothing.

 @see openSide:animated:

 @param animated `YES` if you want to animate the transition, `NO` otherwise.
 */
- (void)closeSide:(BOOL)animated;


/// @name Customizing Transitions

/**
 Creates and returns an object that conforms to `IIViewDeckTransitionAnimator` and
 is ready to handle the animation for the passed in transition.
 
 This method is ment to be subclassed if you want to add your own custom animator.
 If you want to customize the animation only in some cases, make sure to call super
 in all the other cases, otherwise calling super is not required.

 @param context The `IIViewDeckTransitionContext` that this animator should use.

 @return A fully configured animator object.
 */
- (id<IIViewDeckTransitionAnimator>)animatorForTransitionWithContext:(id<IIViewDeckTransitionContext>)context;

/**
 Creates and returns a view that can be used as decoration view between the center
 view controller's view and a side view.

 This method is ment to be subclassed if you want to add your own custom decoration
 view or if you want to disable decoration views alltogether. If you want to customize
 the decoration view only in some cases, make sure to call super in all the other
 cases, otherwise calling super is not required.

 @param context The `IIViewDeckTransitionContext` that this decoration view is used in.

 @return A fully configured decoration view.
 */
- (nullable UIView *)decorationViewForTransitionWithContext:(id<IIViewDeckTransitionContext>)context;


/*
typedef void (^IIViewDeckControllerBlock) (IIViewDeckController *controller, BOOL success);
typedef void (^IIViewDeckControllerBounceBlock) (IIViewDeckController *controller);

@property (nonatomic, weak) id<IIViewDeckControllerDelegate> delegate;
@property (nonatomic) IIViewDeckDelegateMode delegateMode;

@property (nonatomic, weak) id<UIGestureRecognizerDelegate> panningGestureDelegate;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, getter=isElastic) BOOL elastic;

@property (nonatomic) CGFloat centerViewOpacity;
@property (nonatomic) CGFloat centerViewCornerRadius;
@property (nonatomic) BOOL shadowEnabled;
@property (nonatomic) BOOL resizesCenterView;
@property (nonatomic) IIViewDeckPanningMode panningMode;
@property (nonatomic) BOOL panningCancelsTouchesInView;
@property (nonatomic) IIViewDeckCenterHiddenInteractivity centerhiddenInteractivity;
@property (nonatomic) CGFloat bounceDurationFactor; // capped between 0.01 and 0.99. defaults to 0.3. Set to 0 to have the old 1.4 behavior (equal time for long part and short part of bounce)
@property (nonatomic) CGFloat bounceOpenSideDurationFactor; // Same as bounceDurationFactor, but if set, will give independent control of the bounce as the side opens fully (first half of the bounce)
@property (nonatomic) CGFloat parallaxAmount;

@property (nonatomic) NSString *centerTapperAccessibilityLabel; // Voice over accessibility label for button to close side panel
@property (nonatomic) NSString *centerTapperAccessibilityHint;  // Voice over accessibility hint for button to close side panel


- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide;
- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide withCompletion:(IIViewDeckControllerBlock)completed;
- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide toDistance:(CGFloat)distance duration:(NSTimeInterval)duration callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;
- (BOOL)previewBounceView:(IIViewDeckSide)viewDeckSide toDistance:(CGFloat)distance duration:(NSTimeInterval)duration numberOfBounces:(CGFloat)numberOfBounces dampingFactor:(CGFloat)zeta callDelegate:(BOOL)callDelegate completion:(IIViewDeckControllerBlock)completed;

- (BOOL)canRightViewPushViewControllerOverCenterController;
- (void)rightViewPushViewControllerOverCenterController:(UIViewController*)controller;

- (BOOL)isSideClosed:(IIViewDeckSide)viewDeckSide;
- (BOOL)isSideOpen:(IIViewDeckSide)viewDeckSide;
- (BOOL)isAnySideOpen;

- (void)disablePanOverViewsOfClass:(Class)viewClass;
- (void)enablePanOverViewsOfClass:(Class)viewClass;
- (BOOL)canPanOverViewsOfClass:(Class)viewClass;
- (NSArray*)viewClassesWithDisabledPan;

@end


// Delegate protocol

@protocol IIViewDeckControllerDelegate <NSObject>

@optional
- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldPan:(UIPanGestureRecognizer*)panGestureRecognizer;

- (void)viewDeckController:(IIViewDeckController*)viewDeckController didChangeOffset:(CGFloat)offset panning:(BOOL)panning;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didBounceViewSide:(IIViewDeckSide)viewDeckSide openingController:(UIViewController*)openingController;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didBounceViewSide:(IIViewDeckSide)viewDeckSide closingController:(UIViewController*)closingController;

- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldOpenViewSide:(IIViewDeckSide)viewDeckSide;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController*)viewDeckController didShowCenterViewFromSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;

- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController willPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;
- (void)viewDeckController:(IIViewDeckController *)viewDeckController didPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated;

- (CGFloat)viewDeckController:(IIViewDeckController*)viewDeckController changesLedge:(CGFloat)ledge forSide:(IIViewDeckSide)viewDeckSide;

- (BOOL)viewDeckController:(IIViewDeckController*)viewDeckController shouldBeginPanOverView:(UIView*)view;

//*/
@end

// You should NOT change the gesture recognizers. These are only available for reference
// in case you want to link them with other gesture recognizers.
@interface IIViewDeckController (GestureRecognizer)

/**
 The gesture recognizer that is used to slide in the left view controller.
 
 @note Do not alter this gesture recognizer. This property should only be used to
       link this gesture recognizer with other gesture recognizers.
 */
@property (nonatomic, readonly) UIGestureRecognizer *leftEdgeGestureRecognizer;

/**
 The gesture recognizer that is used to slide in the right view controller.

 @note Do not alter this gesture recognizer. This property should only be used to
 link this gesture recognizer with other gesture recognizers.
 */
@property (nonatomic, readonly) UIGestureRecognizer *rightEdgeGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
