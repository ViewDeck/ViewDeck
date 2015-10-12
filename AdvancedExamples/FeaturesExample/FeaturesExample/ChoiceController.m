//
//  ChoiceController.m
//  FeaturesExample
//

#import "ChoiceController.h"
#import "PhotosController.h"
#import "SelectionController.h"
#import "IIViewDeckController.h"

@interface ChoiceController () <IIViewDeckControllerDelegate> {
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
    PhotosController* photosController = [[PhotosController alloc] initWithNibName:@"PhotosController" bundle:nil];
    SelectionController* selectionController = [[SelectionController alloc] initWithNibName:@"SelectionController" bundle:nil];

    IIViewDeckController* controller = [[IIViewDeckController alloc] initWithCenterViewController:photosController leftViewController:selectionController];
    controller.panningMode = _panning;
    controller.centerhiddenInteractivity = _centerHidden;
    controller.navigationControllerBehavior = _navBehavior;
    controller.panningView = self.panningView;
    controller.maxSize = _maxLedge > 0 ? self.view.bounds.size.width-_maxLedge : 0;
    controller.sizeMode = _sizeMode;
    controller.elastic = _elastic;
    controller.leftSize = 320;
    controller.delegate = self;
    [controller openLeftView];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)panningChanged:(id)sender {
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    IIViewDeckPanningMode values[] = { IIViewDeckNoPanning, IIViewDeckFullViewPanning, IIViewDeckNavigationBarPanning, IIViewDeckPanningViewPanning, IIViewDeckDelegatePanning, IIViewDeckNavigationBarOrOpenCenterPanning };
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

#define CGRectOffsetRightAndShrink(rect, offset)         \
({                                                        \
__typeof__(rect) __r = (rect);                          \
__typeof__(offset) __o = (offset);                      \
(CGRect) {  { __r.origin.x, __r.origin.y },            \
{ __r.size.width - __o, __r.size.height }  \
};                                            \
})

- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGRect halfRect = self.navigationController.navigationBar.bounds;
    halfRect = CGRectOffsetRightAndShrink(halfRect, halfRect.size.width/2);
    
    UIView* flash = [UIView new];
    BOOL ok = CGRectContainsPoint(halfRect, [panGestureRecognizer locationInView:self.navigationController.navigationBar]);
    if (ok) {
        flash.frame = halfRect;
        flash.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    }
    else {
        flash.frame = self.navigationController.navigationBar.bounds;
        flash.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
    }

    [self.navigationController.navigationBar addSubview:flash];
    [UIView animateWithDuration:0.3 animations:^{
        flash.alpha = 0;
    } completion:^(BOOL finished) {
        [flash removeFromSuperview];
    }];

    return ok;
}

@end
