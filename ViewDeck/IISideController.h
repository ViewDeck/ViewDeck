//
//  IISideController.h
//  Drache
//
//  Created by Tom Adriaenssen on 05/12/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "IIWrapController.h"

@interface IISideController : IIWrapController

- (id)initWithViewController:(UIViewController*)controller constrained:(CGFloat)constrainedSize;

@end
