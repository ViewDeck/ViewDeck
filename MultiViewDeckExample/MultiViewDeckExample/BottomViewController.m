//
//  BottomViewController.m
//  MultiViewDeckExample
//
//  Created by Tom Adriaenssen on 06/05/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "BottomViewController.h"
#import "UITableViewCell+AutoDequeue.h"
#import "IIViewDeckController.h"
#import "ModalViewController.h"

@interface BottomViewController ()

@end

@implementation BottomViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.4 alpha:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%i", section]; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section+1)*2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell tableViewAutoDequeueCell:tableView];
    
    cell.textLabel.text = indexPath.section ? @"Close Toplevel" : @"Modal";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        [self.viewDeckController.viewDeckController closeLeftView];
    }
    else {
        ModalViewController* modal = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
        [self presentModalViewController:modal animated:YES];
    }
}

@end
