//
//  ViewController.m
//  ViewDeckExample
//
//  Copyright (C) 2011-2016, ViewDeck
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "ViewController.h"
#import <ViewDeck/ViewDeck.h>


static CGFloat const LedgeSizeFactor = 88.0;


@interface ViewController () <UIImagePickerControllerDelegate>

@end


@implementation ViewController

@synthesize popoverController = _popoverController2;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray<UIBarButtonItem *> *leftItems = @[
                                              [[UIBarButtonItem alloc] initWithTitle:@"left" style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftSide:)],
//                                              [[UIBarButtonItem alloc] initWithTitle:@"bounce" style:UIBarButtonItemStylePlain target:self action:@selector(previewBounceLeftView:)],
                                              ];
    self.navigationItem.leftBarButtonItems = leftItems;

    NSArray<UIBarButtonItem *> *rightItems = @[
                                               [[UIBarButtonItem alloc] initWithTitle:@"right" style:UIBarButtonItemStylePlain target:self action:@selector(toggleRightSide:)],
//                                               [[UIBarButtonItem alloc] initWithTitle:@"bounce" style:UIBarButtonItemStylePlain target:self action:@selector(previewBounceRightView:)],
                                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCam:)],
                                               ];
    self.navigationItem.rightBarButtonItems = rightItems;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)toggleLeftSide:(id)sender {
    IIViewDeckController *viewDeckController = self.viewDeckController;
    IIViewDeckSide side = viewDeckController.openSide;
    [viewDeckController openSide:(side == IIViewDeckSideNone ? IIViewDeckSideLeft : IIViewDeckSideNone) animated:YES];
}

- (IBAction)toggleRightSide:(id)sender {
    IIViewDeckController *viewDeckController = self.viewDeckController;
    IIViewDeckSide side = viewDeckController.openSide;
    [viewDeckController openSide:(side == IIViewDeckSideNone ? IIViewDeckSideRight : IIViewDeckSideNone) animated:YES];
}

- (IBAction)previewBounceLeftView:(id)sender {
    IIViewDeckController *viewDeckController = self.viewDeckController;
//    [viewDeckController previewBounceView:IIViewDeckSideLeft];
}

- (IBAction)previewBounceRightView:(id)sender {
    IIViewDeckController *viewDeckController = self.viewDeckController;
//    [viewDeckController previewBounceView:IIViewDeckSideRight];
}

- (void)showCam:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        picker.sourceType =  UIImagePickerControllerSourceTypeCamera;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.popoverController dismissPopoverAnimated:NO];
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES]; 
    }
    else {
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return !section ? @"Left" : @"Right";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textAlignment = indexPath.section ? NSTextAlignmentRight : NSTextAlignmentLeft;
    cell.textLabel.text = [NSString stringWithFormat:@"ledge: %g", indexPath.row * LedgeSizeFactor];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UIViewController *leftViewController = self.viewDeckController.leftViewController;
        CGSize contentSize = leftViewController.preferredContentSize;
        contentSize.width = indexPath.row * LedgeSizeFactor;
        leftViewController.preferredContentSize = contentSize;
    } else {
        UIViewController *rightViewController = self.viewDeckController.rightViewController;
        CGSize contentSize = rightViewController.preferredContentSize;
        contentSize.width = indexPath.row * LedgeSizeFactor;
        rightViewController.preferredContentSize = contentSize;
    }
}

@end
