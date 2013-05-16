//
//  IISideController.m
//  IIViewDeck
//
//  Copyright (C) 2011-2013, Tom Adriaenssen
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


#import "IISideController.h"
#import "IIViewDeckController.h"
#import <QuartzCore/QuartzCore.h>

#define II_CGRectOffsetLeftAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x + __o, __r.origin.y, __r.size.width-__o, __r.size.height }; })
#define II_CGRectOffsetRightAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x, __r.origin.y, __r.size.width-__o, __r.size.height }; })
#define II_CGRectOffsetTopAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) {{ __r.origin.x, __r.origin.y + __o}, {__r.size.width, __r.size.height-__o }}; })
#define II_CGRectOffsetBottomAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x, __r.origin.y, __r.size.width, __r.size.height-__o }; })

@interface IISideController ()

@end

@implementation IISideController 

+ (IISideController*)autoConstrainedSideControllerWithViewController:(UIViewController*)controller {
    return [[IISideController alloc] initWithViewController:controller];
}

+ (IISideController*)sideControllerWithViewController:(UIViewController*)controller constrained:(CGFloat)constrainedSize {
    return [[IISideController alloc] initWithViewController:controller constrained:constrainedSize];
}

- (id)initWithViewController:(UIViewController*)controller constrained:(CGFloat)constrainedSize {
    if ((self = [super initWithViewController:controller])) {
        _constrainedSize = constrainedSize;
    }
    return self;
}

- (id)initWithViewController:(UIViewController*)controller {
    if ((self = [super initWithViewController:controller])) {
        _constrainedSize = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self shrinkSide];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.view.backgroundColor = self.wrappedController.view.backgroundColor;
    [self shrinkSideAnimated:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self shrinkSideAnimated:YES];
}

- (void)setConstrainedSize:(CGFloat)constrainedSize {
    [self setConstrainedSize:constrainedSize animated:YES];
}

- (void)setConstrainedSize:(CGFloat)constrainedSize animated:(BOOL)animated {
    _constrainedSize = constrainedSize;
    [self shrinkSideAnimated:animated];
}

- (void)shrinkSide {
    [self shrinkSideAnimated:YES];
}

- (void)shrinkSideAnimated:(BOOL)animated {
    if (self.viewDeckController) {
        // we don't want this animated
        [CATransaction begin];
        if (animated) {
            [UIView beginAnimations:@"shrinkSide" context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        }
        else {
            [CATransaction disableActions];
        }
        
        if (self.viewDeckController.leftController == self) {
            CGFloat offset = self.view.bounds.size.width - (_constrainedSize > 0 ? _constrainedSize : self.viewDeckController.leftViewSize);
            self.wrappedController.view.frame = II_CGRectOffsetRightAndShrink(self.view.bounds, offset);
        }
        else if (self.viewDeckController.rightController == self) {
            CGFloat offset = self.view.bounds.size.width - (_constrainedSize > 0 ? _constrainedSize : self.viewDeckController.rightViewSize);
            self.wrappedController.view.frame = II_CGRectOffsetLeftAndShrink(self.view.bounds, offset);
        }
        else if (self.viewDeckController.topController == self) {
            CGFloat offset = self.view.bounds.size.height - (_constrainedSize > 0 ? _constrainedSize : self.viewDeckController.topViewSize);
            self.wrappedController.view.frame = II_CGRectOffsetBottomAndShrink(self.view.bounds, offset);
        }
        else if (self.viewDeckController.bottomController == self) {
            CGFloat offset = self.view.bounds.size.height - (_constrainedSize > 0 ? _constrainedSize : self.viewDeckController.bottomViewSize);
            self.wrappedController.view.frame = II_CGRectOffsetTopAndShrink(self.view.bounds, offset);
        }
        
        if (animated) {
            [UIView commitAnimations];
        }
        [CATransaction commit];
    }
}

@end


@implementation UIViewController (IISideController)

- (IISideController*)sideController {
    return (IISideController*)self.wrapController;
}

@end
