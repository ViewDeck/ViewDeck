//
//  IIViewDeckTransition.h
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

#import "IIViewDeckTransitioning.h"

#import "IIEnvironment.h"


@class IIViewDeckController;
@interface IIViewDeckTransition : NSObject <IIViewDeckTransitionContext>

- (instancetype)initWithViewDeckController:(IIViewDeckController *)viewDeckController from:(IIViewDeckSide)fromSide to:(IIViewDeckSide)toSide;

@property (nonatomic, copy) void(^completionHandler)(BOOL cancelled);

/// @name Managing Interactive Transitions
- (void)beginInteractiveTransition:(UIGestureRecognizer *)recognizer;
- (void)updateInteractiveTransition:(UIGestureRecognizer *)recognizer;
- (void)endInteractiveTransition:(UIGestureRecognizer *)recognizer;

/// @name Managing Animated Transitions
- (void)performTransition:(BOOL)animated;

@end
