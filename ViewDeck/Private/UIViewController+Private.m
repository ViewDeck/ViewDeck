//
//  UIViewController+Private.m
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

#import "UIViewController+Private.h"

@implementation UIViewController (II_Private)

- (void)ii_exchangeViewController:(UIViewController *)oldController withViewController:(UIViewController *)newController viewTransition:(void(^)(void))viewTransition {
    [oldController willMoveToParentViewController:nil];
    [self addChildViewController:newController];

    if (self.isViewLoaded && viewTransition) {
        viewTransition();
    }

    [newController didMoveToParentViewController:self];
    [oldController removeFromParentViewController];
}

- (void)ii_exchangeViewFromController:(UIViewController *)oldController toController:(UIViewController *)newController inContainerView:(UIView *)containerView {
    if (oldController == nil && newController == nil) {
        return;
    }

    NSParameterAssert(oldController.view == nil || oldController.view.superview == containerView);

    newController.view.frame = containerView.bounds;
    newController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    // Check if the view is inside a window and if the container view is within the bounds of the controller's view.
    // If the container is not within the bounds of the controller's view, we consider the container to be non-visible.
    CGRect containerFrame = [self.view convertRect:containerView.bounds fromView:containerView];
    BOOL viewVisible = (self.view.window && CGRectIntersectsRect(self.view.bounds, containerFrame));
    if (viewVisible) {
        [oldController beginAppearanceTransition:NO animated:NO];
        [newController beginAppearanceTransition:YES animated:NO];
    }

    [containerView addSubview:newController.view];
    [oldController.view removeFromSuperview];

    if (viewVisible) {
        [newController endAppearanceTransition];
        [oldController endAppearanceTransition];
    }
}

@end
