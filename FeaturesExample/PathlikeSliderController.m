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
    [self closeLeftView];
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

}



@end
