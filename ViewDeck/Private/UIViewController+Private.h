//
//  UIViewController+Private.h
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

#import <UIKit/UIKit.h>

@interface UIViewController (II_Private)

/// Wraps the view controller container methods and exchanges the old view controller with the new view controller.
///
/// @param oldController  The controller to be removed.
/// @param newController  The controller to be added.
/// @param viewTransition A block that manages the view transition of the two controllers if necessary.
- (void)ii_exchangeViewController:(UIViewController *)oldController withViewController:(UIViewController *)newController viewTransition:(void(^)(void))viewTransition;

/// Wraps the exchange of the views of two view controllers including the appearance calls.
///
/// @param oldController The controller whoes view needs to be removed.
/// @param newController The controller whoes view needs to be added.
/// @param containerView The container view in which this replacement should take place.
- (void)ii_exchangeViewFromController:(UIViewController *)oldController toController:(UIViewController *)newController inContainerView:(UIView *)containerView;

@end
