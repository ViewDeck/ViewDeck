//
//  RightViewController.m
//  ViewDeckExample
//


#import "RightViewController.h"
#import "LeftViewController.h"
#import "ViewController.h"
#import "IIViewDeckController.h"
#import "NestViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RightViewController () <IIViewDeckControllerDelegate>

@property (nonatomic, retain) NSMutableArray* logs;

@end


@implementation RightViewController

@synthesize tableView = _tableView;
@synthesize logs = _logs;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logs = [NSMutableArray array];
    
    self.viewDeckController.delegate = self;
    self.tableView.scrollsToTop = NO;
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

- (IBAction)centerNavController:(id)sender {
    self.viewDeckController.leftController = SharedAppDelegate.leftController;
    
    NestViewController* nestController = [[NestViewController alloc] initWithNibName:@"NestViewController" bundle:nil];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:nestController];
    self.viewDeckController.centerController = navController;
}


#pragma mark - view deck delegate

- (void)addLog:(NSString*)line {
    self.tableView.frame = (CGRect) { self.viewDeckController.rightLedge, self.tableView.frame.origin.y, 
        self.view.frame.size.width - self.viewDeckController.rightLedge, self.tableView.frame.size.height };

    [self.logs addObject:line];
    NSIndexPath* index = [NSIndexPath indexPathForRow:self.logs.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//- (void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
//    [self addLog:@"apply Shadow"];
//
//    shadowLayer.masksToBounds = NO;
//    shadowLayer.shadowRadius = 30;
//    shadowLayer.shadowOpacity = 1;
//    shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
//    shadowLayer.shadowOffset = CGSizeZero;
//    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:rect] CGPath];
//}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController didPanToOffset:(CGFloat)offset {
    [self addLog:[NSString stringWithFormat:@"Pan: %f", offset]];
}

- (BOOL)viewDeckControllerWillOpenLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"will open left view"];
    return YES;
}

- (void)viewDeckControllerDidOpenLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"did open left view"];
}

- (BOOL)viewDeckControllerWillCloseLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"will close left view"];
    return YES;
}

- (void)viewDeckControllerDidCloseLeftView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"did close left view"];
}

- (BOOL)viewDeckControllerWillOpenRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"will open right view"];
    return YES;
}

- (void)viewDeckControllerDidOpenRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"did open right view"];
}

- (BOOL)viewDeckControllerWillCloseRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"will close left view"];
    return YES;
}

- (void)viewDeckControllerDidCloseRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"did close left view"];
}

- (void)viewDeckControllerDidShowCenterView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated {
    [self addLog:@"did show center view"];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    cell.textLabel.text = [self.logs objectAtIndex:indexPath.row];

    return cell;
}


@end
