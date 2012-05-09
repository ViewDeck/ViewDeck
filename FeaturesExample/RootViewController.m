//
//  RootViewController.m
//  FeaturesExample
//

#import "RootViewController.h"
#import "IIViewDeckController.h"
#import "ChoiceController.h"
#import "SelectionController.h"

@implementation RootViewController

@synthesize choiceView = _choiceView;
@synthesize panningView = _panningView;
@synthesize navController = _navController;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Override point for customization after application launch.
    ChoiceController* choiceController = [[ChoiceController alloc] initWithNibName:@"ChoiceController" bundle:nil];
    choiceController.panningView = self.panningView;
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:choiceController];
    self.navController.navigationBar.tintColor = [UIColor darkGrayColor];
    [self addChildViewController:self.navController];
    
    self.navController.view.frame = self.choiceView.bounds;
    [self.choiceView addSubview:self.navController.view];
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


@end
