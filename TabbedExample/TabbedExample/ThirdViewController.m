//
//  ThirdViewController.m
//  TabbedExample
//
//  Created by Tom Adriaenssen on 03/02/12.
//  Copyright (c) 2012 Adriaenssen BVBA. All rights reserved.
//

#import "ThirdViewController.h"

@implementation ThirdViewController

- (IBAction)changeItem:(id)sender {
    self.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Third";
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.view.backgroundColor = [UIColor brownColor];
}

@end
