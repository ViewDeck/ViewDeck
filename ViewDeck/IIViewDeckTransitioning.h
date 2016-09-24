//
//  IIViewDeckTransitioning.h
//  IIViewDeck
//
//  Copyright (C) 2016, ViewDeck
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A transition context is used to communicate all the necessary information for transitioning
 between a side view controller and the center view controller.
 */
@protocol IIViewDeckTransitionContext <NSObject>

/// @name State of a Transition

/**
 `YES` if the transition is interactive, `NO` otherwise.
 */
@property (nonatomic, readonly, getter=isInteractive) BOOL interactive;

/**
 `YES` if a transition has been cancelled. Essentially this means that after the
 transition finishes, everything will be in the initial state again, instead of
 the final state.
 
 Due to its nature this property might change at any time during a transition.
 */
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

/**
 `YES` if the transition manages the appearance of a side view, `NO` if it manages
 the disappearing of a side view.
 */
@property (nonatomic, readonly, getter=isAppearing) BOOL appearing;


/// @name Center View

/**
 The view that is shown in the center and is participating in the transition.
 */
@property (nonatomic, readonly) UIView *centerView;

/**
 The initial frame of the center view at the beginning of the transition.
 */
@property (nonatomic, readonly) CGRect initialCenterFrame;

/**
 The final frame of the center view at the end of the transition.
 */
@property (nonatomic, readonly) CGRect finalCenterFrame;


/// @name Side View

/**
 The view that is shown on the side and is sliding over the center view.
 */
@property (nonatomic, readonly) UIView *sideView;

/**
 The initial frame of the side view at the beginning of the transition.
 */
@property (nonatomic, readonly) CGRect initialSideFrame;

/**
 The final frame of the side view at the end of the transition.
 */
@property (nonatomic, readonly) CGRect finalSideFrame;


/// @name Decorational Elements

/**
 The decoration view that is visible on top of the center view but underneath the
 side view.
 */
@property (nonatomic, readonly, nullable) UIView *decorationView;


/// @name Notifying about States

/**
 Call this method when the animation is done. Any sort of clean up will be done
 inside this method.
 
 @note It is important to call this method regardless of whether the transition
       was cancelled or not!
 */
- (void)completeTransition;

@end


/**
 An animator is responsible for handling the actual animation from the beginning
 to the final state as well as any animation that needs to be done when a transition
 is cancelled.
 
 An animator is also responsible for controlling any intermediate state during an
 interactive transition.
 
 When a transition is taking place, this is how the animator will be called:
 1. `prepareForTransition` is called.
 2. If the transition is an interactive transition the animator will receive multiple
    calls to `updateInteractiveTransition:fractionCompleted:`.
 3. The animator will receive a call to `animateTransition` which tells it to animate
    everything to its final position (or its initial position if the transition
    has been cancelled).
 
 After the animation has finished, the animator is responsible to call `completeTransition`
 on the context. Otherwise the transition will never finish and is stuck in an incomplete
 state.
 */
@protocol IIViewDeckTransitionAnimator <NSObject>

@required

/**
 The animator should prepare for the transition based on the information in the
 passed in context object. The transition is about to start.

 @param context The context that defines the current transition.
 */
- (void)prepareForTransition:(id<IIViewDeckTransitionContext>)context;

/**
 The animator should handle an interactive transition and layout everything according
 to the current percentage of the transition.

 @param context           The context that defines the current transition.
 @param fractionCompleted The fraction telling the animator how much of the transition has already been completed.
 */
- (void)updateInteractiveTransition:(id<IIViewDeckTransitionContext>)context fractionCompleted:(double)fractionCompleted;

/**
 The animator should trigger an animation that finishes the transition.
 
 After the animation finishes, remember to call `completeTransition` on the context.

 @param context  The context that defines the current transition.
 @param velocity The velocity of the current movement in an interactive transition or `CGPointZero`.
 */
- (void)animateTransition:(id<IIViewDeckTransitionContext>)context velocity:(CGPoint)velocity;

@end

NS_ASSUME_NONNULL_END
