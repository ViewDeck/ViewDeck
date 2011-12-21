//
//  RightViewController.m
//  ViewDeckExample
//


#import "RightViewController.h"
#import "LeftViewController.h"
#import "ViewController.h"
#import "IIViewDeckController.h"

@implementation RightViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (IBAction)defaultCenterPressed:(id)sender {
    self.viewDeckController.centerController = SharedAppDelegate.centerController;
    self.viewDeckController.leftController = SharedAppDelegate.leftController;
}

- (IBAction)swapLeftAndCenterPressed:(id)sender {
    self.viewDeckController.centerController = SharedAppDelegate.leftController;
    self.viewDeckController.leftController = SharedAppDelegate.centerController;
}

- (IBAction)imageAsCenterPressed:(id)sender {
}


@end
