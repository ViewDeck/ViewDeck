//
//  LeftMenuViewController.m
//  ViewDeckTest
//
//  Created by Justin Carstens on 8/8/13.
//  Copyright (c) 2013 BitSuites. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController () {
	NSArray *rows;
}

@end

@implementation LeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	rows = @[@"Home", @"Explore", @"Help +", @"Tags +", @"Log out"];
}

#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	[cell.textLabel setText:[rows objectAtIndex:indexPath.row]];
	return cell;
}

@end
