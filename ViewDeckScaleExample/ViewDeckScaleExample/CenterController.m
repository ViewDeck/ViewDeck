//
//  CenterController.m
//  ViewDeckTest
//
//  Created by Justin Carstens on 8/7/13.
//  Copyright (c) 2013 BitSuites. All rights reserved.
//

#import "CenterController.h"
#import "IIViewDeckController.h"

@interface CenterController ()

@end

@implementation CenterController

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (IBAction)openAction:(id)sender {
	[self.viewDeckController openLeftViewAnimated:YES];
}

- (IBAction)openRight:(id)sender {
	[self.viewDeckController openRightViewAnimated:YES];
}
@end
