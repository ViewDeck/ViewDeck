//
//  ChoiceController.m
//  FeaturesExample
//

#import "ChoiceController.h"
#import "PathlikeSliderController.h"

@interface ChoiceController () {
    IIViewDeckPanningMode _panning;
    IIViewDeckCenterHiddenInteractivity _centerHidden;
    IIViewDeckNavigationControllerBehavior _navBehavior;
}

@end

@implementation ChoiceController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _panning = IIViewDeckNoPanning;
        _centerHidden = IIViewDeckCenterHiddenUserInteractive;
        _navBehavior = IIViewDeckNavigationControllerContained;
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
    
    self.title = @"Features example";
    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES; // UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (IBAction)pressedNavigate:(id)sender {
    PathlikeSliderController* controller = [[PathlikeSliderController alloc] init];  
    controller.panningMode = _panning;
    controller.centerhiddenInteractivity = _centerHidden;
    controller.navigationControllerBehavior = _navBehavior;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)panningChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckPanningMode values[] = { IIViewDeckNoPanning, IIViewDeckFullViewPanning, IIViewDeckNavigationBarPanning };
    _panning = values[control.selectedSegmentIndex];
}

- (IBAction)centerHiddenChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckCenterHiddenInteractivity values[] = { IIViewDeckCenterHiddenUserInteractive, IIViewDeckCenterHiddenNotUserInteractive, IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose };
    _centerHidden = values[control.selectedSegmentIndex];
}

- (IBAction)navigationChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckNavigationControllerBehavior values[] = { IIViewDeckNavigationControllerContained, IIViewDeckNavigationControllerIntegrated };
    _navBehavior = values[control.selectedSegmentIndex];
}

@end
