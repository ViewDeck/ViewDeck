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
    IIViewDeckSizeMode _sizeMode;
    BOOL _elastic;
    CGFloat _maxLedge;
}

@end

@implementation ChoiceController

@synthesize panningView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _panning = IIViewDeckNoPanning;
        _centerHidden = IIViewDeckCenterHiddenUserInteractive;
        _navBehavior = IIViewDeckNavigationControllerContained;
        _sizeMode = IIViewDeckLedgeSizeMode;
        _elastic = YES;
        _maxLedge = 0;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Features example";
    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
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
    controller.panningView = self.panningView;
    controller.maxSize = _maxLedge > 0 ? self.view.bounds.size.width-_maxLedge : 0;
    controller.sizeMode = _sizeMode;
    controller.elastic = _elastic;
    controller.leftSize = 320;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)panningChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckPanningMode values[] = { IIViewDeckNoPanning, IIViewDeckFullViewPanning, IIViewDeckNavigationBarPanning, IIViewDeckPanningViewPanning };
    _panning = values[control.selectedSegmentIndex];
}

- (IBAction)centerHiddenChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckCenterHiddenInteractivity values[] = { IIViewDeckCenterHiddenUserInteractive, IIViewDeckCenterHiddenNotUserInteractive, IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose, IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing };
    _centerHidden = values[control.selectedSegmentIndex];
}

- (IBAction)navigationChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckNavigationControllerBehavior values[] = { IIViewDeckNavigationControllerContained, IIViewDeckNavigationControllerIntegrated };
    _navBehavior = values[control.selectedSegmentIndex];
}

- (IBAction)rotationChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckSizeMode values[] = { IIViewDeckLedgeSizeMode, IIViewDeckViewSizeMode };
    _sizeMode = values[control.selectedSegmentIndex];
}

- (IBAction)elasticChanged:(id)sender {
    _elastic = ((UISwitch*)sender).on;
}

- (IBAction)maxLedgeChanged:(id)sender {
    _maxLedge = ((UISlider*)sender).value;
}


@end
