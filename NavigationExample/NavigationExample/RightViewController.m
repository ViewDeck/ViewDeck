//
//  RightViewController.m
//  NavigationExample
//
//  Created by Tom Adriaenssen on 30/05/12.
//  Copyright (c) 2012 Adriaenssen BVBA, 10to1. All rights reserved.
//

#import "RightViewController.h"
#import "IIViewDeckController.h"
#import "DeeperViewController.h"
#import <MessageUI/MessageUI.h>

@interface RightViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIButton* smsButton;

@end

@implementation RightViewController

@synthesize smsButton = _smsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.smsButton.enabled = [MFMessageComposeViewController canSendText];
    self.smsButton.alpha = [MFMessageComposeViewController canSendText] ? 1 : 0.5;
    
}
- (IBAction)closeAndNavigatePressed:(id)sender {
    DeeperViewController* controller = [[DeeperViewController alloc] initWithNibName:@"DeeperViewController" bundle:nil];
    [self.viewDeckController rightViewPushViewControllerOverCenterController:controller];
}

- (IBAction)mailPressed:(id)sender {
    MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction)smsPressed:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController* smsController = [[MFMessageComposeViewController alloc] init];
        smsController.messageComposeDelegate = self;
        [self presentViewController:smsController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
