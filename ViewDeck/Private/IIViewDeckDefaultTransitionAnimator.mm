//
//  IIViewDeckDefaultTransitionAnimator.m
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

#import "IIViewDeckDefaultTransitionAnimator.h"

#import "IIEnvironment+Private.h"

NS_ASSUME_NONNULL_BEGIN

@implementation IIViewDeckDefaultTransitionAnimator

- (void)prepareForTransition:(id<IIViewDeckTransitionContext>)context {
    // intentionally left empty
}

- (void)updateInteractiveTransition:(id<IIViewDeckTransitionContext>)context fractionCompleted:(double)fractionCompleted {
    // interpolate frames linear for an interactive transition
    const CGRect initialCenter = context.initialCenterFrame;
    const CGRect finalCenter = context.finalCenterFrame;
    const CGRect currentCenter = initialCenter + (finalCenter - initialCenter) * fractionCompleted;
    context.centerView.frame = currentCenter;

    const CGRect initialSide = context.initialSideFrame;
    const CGRect finalSide = context.finalSideFrame;
    const CGRect currentSide = initialSide + (finalSide - initialSide) * fractionCompleted;
    context.sideView.frame = currentSide;

    context.decorationView.alpha = (context.isAppearing ? fractionCompleted : 1.0 - fractionCompleted);
}

- (void)animateTransition:(id<IIViewDeckTransitionContext>)context velocity:(CGPoint)velocity {
    const CGRect finalCenterFame = (context.isCancelled ? context.initialCenterFrame : context.finalCenterFrame);
    const CGRect finalSideFrame = (context.isCancelled ? context.initialSideFrame : context.finalSideFrame);

    const CGFloat animationDistance = CGRectGetMinX(finalSideFrame) - CGRectGetMinX(context.sideView.frame);

    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:(velocity.x/animationDistance) options:UIViewAnimationOptionCurveLinear animations:^{
        context.decorationView.alpha = (context.isAppearing ^ context.isCancelled ? 1.0 : 0.0);
        context.centerView.frame = finalCenterFame;
        context.sideView.frame = finalSideFrame;
    } completion:^(BOOL finished) {
        [context completeTransition];
    }];
}

@end

NS_ASSUME_NONNULL_END
