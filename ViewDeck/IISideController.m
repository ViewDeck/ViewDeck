//
//  IISideController.m
//  Drache
//
//  Created by Tom Adriaenssen on 05/12/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
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

@implementation IISideController {
    CGFloat _constrainedSize;
}

- (id)initWithViewController:(UIViewController*)controller constrained:(CGFloat)constrainedSize {
    if ((self = [super initWithViewController:controller])) {
        _constrainedSize = constrainedSize;
        _animatedShrink = NO;
    }
    return self;
}

- (id)initWithViewController:(UIViewController*)controller {
    if ((self = [super initWithViewController:controller])) {
        _constrainedSize = -1;
        _animatedShrink = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self shrinkSide];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CATransaction begin];
    if (!self.animatedShrink) {
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    }
    self.view.backgroundColor = self.wrappedController.view.backgroundColor;
    [CATransaction commit];
    [self shrinkSide];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self shrinkSide];
}

- (void)shrinkSide {
    if (self.viewDeckController) {
        // we don't want this animated
        [CATransaction begin];
        if (!self.animatedShrink) {
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
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
        
        [CATransaction commit];
    }
}

@end
