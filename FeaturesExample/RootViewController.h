//
//  RootViewController.h
//  FeaturesExample
//
//  Created by Tom Adriaenssen on 09/01/12.
//  Copyright (c) 2012 Adriaenssen BVBA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView* choiceView;
@property (nonatomic, retain) IBOutlet UIView* panningView;
@property (nonatomic, retain) UINavigationController* navController;

@end
