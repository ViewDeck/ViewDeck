//
//  WrappedController.h
//  JoeyPOC
//
//  Created by Tom Adriaenssen on 13/12/11.
//  Copyright (c) 2011 Adriaenssen BVBA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WrappedController : UIViewController

@property (nonatomic, readonly, retain) UIViewController* wrappedController;

- (id)initWithViewController:(UIViewController*)controller;

@end
