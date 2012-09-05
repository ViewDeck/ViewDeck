//
//  SecondViewController.m
//  TabbedExample
//
//  Created by Tom Adriaenssen on 03/02/12.
//  Copyright (c) 2012 Adriaenssen BVBA. All rights reserved.
//

#import "SecondViewController.h"

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"second init");
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second.png"];
    }
    return self;
}
							

@end
