//
//  ViewController.m
//  SizableExample
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "IIViewDeckController.h"
#import "LeftController.h"
#import "CenterController.h"

@interface ViewController ()

@property (nonatomic, strong) IIViewDeckController* containerController;

@end

@implementation ViewController

@synthesize containerView = _containerView;
@synthesize containerController = _containerController;

- (IBAction)zoomPressed:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect cBounds = self.containerView.superview.bounds;
        if (self.containerView.frame.size.height != cBounds.size.height)
            self.containerView.frame = self.containerView.superview.bounds;
        else
            self.containerView.frame = (CGRect) { 0, 48, cBounds.size.width, cBounds.size.height - 48 - 48 };
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeZero;
    self.containerView.layer.shadowRadius = 15;
    self.containerView.layer.shadowOpacity = 1;
    
    UIViewController* leftController = [[LeftController alloc] initWithNibName:@"LeftController" bundle:nil];
    UIViewController* centerController = [[CenterController alloc] initWithNibName:@"CenterController" bundle:nil];
    self.containerController = [[IIViewDeckController alloc] initWithCenterViewController:centerController leftViewController:leftController];
    [self addChildViewController:self.containerController];
    self.containerController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.containerController.view];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
