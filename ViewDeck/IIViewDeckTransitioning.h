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


@protocol IIViewDeckTransitionContext <NSObject>

@property (nonatomic, readonly, getter=isInteractive) BOOL interactive;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, getter=isAppearing) BOOL appearing;

@property (nonatomic, readonly) UIView *centerView;
@property (nonatomic, readonly) CGRect initialCenterFrame;
@property (nonatomic, readonly) CGRect finalCenterFrame;

@property (nonatomic, readonly) UIView *sideView;
@property (nonatomic, readonly) CGRect initialSideFrame;
@property (nonatomic, readonly) CGRect finalSideFrame;

@property (nonatomic, readonly, nullable) UIView *decorationView;

- (void)completeTransition;

@end


@protocol IIViewDeckTransitionAnimator <NSObject>

@required
- (void)prepareForTransition:(id<IIViewDeckTransitionContext>)context;
- (void)updateInteractiveTransition:(id<IIViewDeckTransitionContext>)context fractionCompleted:(double)fractionCompleted;
- (void)animateTransition:(id<IIViewDeckTransitionContext>)context velocity:(CGPoint)velocity;

@end
