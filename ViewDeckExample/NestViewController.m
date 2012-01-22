//
//  NestViewController.m
//  ViewDeckExample
//

#import "NestViewController.h"
#import "IIViewDeckController.h"

@implementation NestViewController

@synthesize level;
@synthesize levelLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.level = 0;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.levelLabel.text = [NSString stringWithFormat:@"Level %d", self.level];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.level == 1) {
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        self.viewDeckController.view.frame = [[UIScreen mainScreen] applicationFrame];
        [self.viewDeckController.view setNeedsDisplay]; // .frame = self.viewDeckController.view.bounds;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.level == 1) {
        [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        self.viewDeckController.view.frame = [[UIScreen mainScreen] applicationFrame];
        [self.viewDeckController.view setNeedsDisplay]; // .frame = self.viewDeckController.view.bounds;
    }
}

- (void)hideOrShow {
    [UIApplication.sharedApplication setStatusBarHidden:!UIApplication.sharedApplication.isStatusBarHidden withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)pressedGoDeeper:(id)sender {
    NestViewController* nestController = [[NestViewController alloc] initWithNibName:@"NestViewController" bundle:nil];
    nestController.level = self.level + 1;
    
    [self.navigationController pushViewController:nestController animated:YES];
}

@end
