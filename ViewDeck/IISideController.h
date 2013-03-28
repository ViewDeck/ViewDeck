//
//  IISideController.h
//  Drache
//
//  Created by Tom Adriaenssen on 05/12/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "IIWrapController.h"

@interface IISideController : IIWrapController

@property (nonatomic, assign) CGFloat constrainedSize;

- (id)initWithViewController:(UIViewController*)controller constrained:(CGFloat)constrainedSize;

- (void)shrinkSide;
- (void)shrinkSideAnimated:(BOOL)animated;

@end


// category on UIViewController to provide access to the sideController in the
// contained viewcontrollers, a la UINavigationController.
@interface UIViewController (IISideController)

@property(nonatomic,readonly,retain) IISideController *sideController;

@end
