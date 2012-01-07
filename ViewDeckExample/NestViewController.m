//
//  NestViewController.m
//  ViewDeckExample
//

#import "NestViewController.h"

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pressedGoDeeper:(id)sender {
    NestViewController* nestController = [[NestViewController alloc] initWithNibName:@"NestViewController" bundle:nil];
    nestController.level = self.level + 1;
    
    [self.navigationController pushViewController:nestController animated:YES];
}

@end
