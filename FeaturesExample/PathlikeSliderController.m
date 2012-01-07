//
//  PathlikeSliderController.m
//  FeaturesExample
//

#import "PathlikeSliderController.h"
#import "PhotosController.h"
#import "SelectionController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PathlikeSliderController

- (id)init {
    PhotosController* photosController = [[PhotosController alloc] initWithNibName:@"PhotosController" bundle:nil];
    SelectionController* selectionController = [[SelectionController alloc] initWithNibName:@"SelectionController" bundle:nil];
    
    if ((self = [super initWithCenterViewController:photosController leftViewController:selectionController])) {
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

- (void)loadView
{
    [super loadView];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
                                              [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back)],
                                              [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(showSelector)], 
                                              nil];
    
    self.navigationItem.title = @"Slide away";
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSelector {
    [self toggleLeftViewAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.leftLedge = self.view.bounds.size.width-320;
    
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSThread sleepForTimeInterval:0.01];
        [self openLeftViewAnimated:YES];
    });

    /*
    // add rounded corner mask
    if (!self.slidingController.view.layer.mask) {
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.frame = self.slidingController.view.bounds;
        mask.path = [UIBezierPath bezierPathWithRoundedRect:self.slidingController.view.bounds 
                                          byRoundingCorners:UIRectCornerAllCorners
                                                cornerRadii:CGSizeMake(50, 50)].CGPath;
        
        // Don't add masks to layers already in the hierarchy!
        UIView* superview = self.slidingController.view.superview;
        UIView* belowView = nil;
        
        for (UIView* view in [[superview subviews] reverseObjectEnumerator]) {
            if (self.slidingController.view == view) break;
            belowView = view;
        }
        
        [self.slidingController.view removeFromSuperview];
        self.slidingController.view.layer.mask = mask;
        
        if (belowView)
            [superview insertSubview:self.slidingController.view belowSubview:belowView];    
        else
            [superview addSubview:self.slidingController.view];    
    }
     */
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
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    self.leftLedge = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 1024 : 768) - 320;
//    NSLog(@"%d", toInterfaceOrientation);
//}
@end
