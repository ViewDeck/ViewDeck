//
//  IIViewDeckTransitionCoordinator.m
//  Pods
//
//  Created by Michael Ochs on 7/9/16.
//
//

#import "IIViewDeckLayoutSupport.h"

#import "IIEnvironment+Private.h"
#import "IIViewDeckController.h"

NS_ASSUME_NONNULL_BEGIN

@interface IIViewDeckLayoutSupport ()

@property (nonatomic, assign) IIViewDeckController *viewDeckController; // this is not weak as it is a required link! If the corresponding view deck controller will be removed, this class can no longer fullfill its purpose!

@end

@implementation IIViewDeckLayoutSupport

- (instancetype)init {
    NSAssert(NO, @"Please use initWithViewDeckController: instead.");
    return self;
}

- (instancetype)initWithViewDeckController:(IIViewDeckController *)viewDeckController {
    NSParameterAssert(viewDeckController);
    self = [super init];

    _viewDeckController = viewDeckController;

    return self;
}

static inline CGSize IIViewDeckSanitizeContentSize(const CGSize size) {
    if (size.width == 0.0 || size.height == 0.0) {
        return CGSizeMake(320.0, 480.0);
    } else {
        return size;
    }
}

- (CGSize)sizeForSide:(IIViewDeckSide)side inContainer:(UIView *)containerView {
    switch (side) {
        case IIViewDeckSideNone:
            return containerView.bounds.size;
        case IIViewDeckSideLeft: {
            CGSize size = IIViewDeckSanitizeContentSize(self.viewDeckController.leftViewController.preferredContentSize);
            size.height = CGRectGetHeight(containerView.bounds);
            return size;
        }
        case IIViewDeckSideRight: {
            CGSize size = IIViewDeckSanitizeContentSize(self.viewDeckController.rightViewController.preferredContentSize);
            size.height = CGRectGetHeight(containerView.bounds);
            return size;
        }
    }
}

- (CGRect)frameForSide:(IIViewDeckSide)side openSide:(IIViewDeckSide)openSide {
    UIView *containerView = self.viewDeckController.view;
    
    CGSize size = [self sizeForSide:side inContainer:containerView];
    CGRect frame = (CGRect){ .origin = CGPointZero, .size = size };
    if (side == IIViewDeckSideRight) {
        frame.origin.x = CGRectGetWidth(containerView.bounds) - CGRectGetWidth(frame);
    }
    if (side != IIViewDeckSideNone && side != openSide) {
        // calculate closed frame
        if (side == IIViewDeckSideLeft) {
            frame.origin.x -= CGRectGetWidth(frame);
        } else { // IIViewDeckSideRight
            frame.origin.x += CGRectGetWidth(frame);
        }
    }

    // parallax center
    if (side == IIViewDeckSideNone && openSide != IIViewDeckSideNone) {
        CGSize maxSize = [self sizeForSide:openSide inContainer:containerView];
        CGFloat xOffset = (openSide == IIViewDeckSideLeft ? maxSize.width * 0.1 : -maxSize.width * 0.1);
        frame.origin.x += xOffset;
    }

    return frame;
}

@end

NS_ASSUME_NONNULL_END
