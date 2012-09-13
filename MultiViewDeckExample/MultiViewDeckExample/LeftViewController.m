//
//  LeftViewController.m
//  MultiViewDeckExample
//
//  Created by Tom Adriaenssen on 06/05/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "LeftViewController.h"
#import "UITableViewCell+AutoDequeue.h"
#import "IIViewDeckController.h"
#import "ModalViewController.h"

@interface LeftViewController () <IIViewDeckControllerDelegate>

- (IIViewDeckController*)topViewDeckController;

@end

@implementation LeftViewController

- (IIViewDeckController*)topViewDeckController {
    return self.viewDeckController.viewDeckController;
}

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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self.viewDeckController action:@selector(toggleLeftView)];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.2 alpha:1];
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

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self.topViewDeckController setLeftSize:22];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self.viewDeckController action:@selector(toggleLeftView)];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self.topViewDeckController setLeftSize:44];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self.viewDeckController action:@selector(toggleLeftView)];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
    
    cell.textLabel.text = indexPath.section == 0 ? @"Close" : indexPath.section == 1 ? @"Modal" : @"Nothing";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.viewDeckController.viewDeckController closeLeftView];
    }
    else if (indexPath.section == 1) {
        ModalViewController* modal = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
        [self presentModalViewController:modal animated:YES];
    }
}


@end
