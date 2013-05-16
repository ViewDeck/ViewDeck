//
//  RightViewController.m
//  ViewDeckExample
//


#import "RightViewController.h"
#import "LeftViewController.h"
#import "ViewController.h"
#import "IIViewDeckController.h"
#import "NestViewController.h"
#import "PushedViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RightViewController () <IIViewDeckControllerDelegate>

@property (nonatomic, retain) NSMutableArray* logs;

@end


@implementation RightViewController

@synthesize tableView = _tableView;
@synthesize logs = _logs;
@synthesize pushButton = _pushButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logs = [NSMutableArray array];
    
    self.viewDeckController.delegate = self;
    self.tableView.scrollsToTop = NO;
    self.pushButton.enabled = NO;
    self.pushButton.layer.opacity = 0.2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addLog:@"view will appear"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addLog:@"view will disappear"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addLog:@"view did appear"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self addLog:@"view did disappear"];
}


#pragma mark - View lifecycle

- (IBAction)defaultCenterPressed:(id)sender {
    self.viewDeckController.centerController = SharedAppDelegate.centerController;
    self.viewDeckController.leftController = SharedAppDelegate.leftController;
    self.pushButton.enabled = NO;
    self.pushButton.layer.opacity = 0.2;
}

- (IBAction)swapLeftAndCenterPressed:(id)sender {
    self.viewDeckController.centerController = SharedAppDelegate.leftController;
    self.viewDeckController.leftController = SharedAppDelegate.centerController;
    self.pushButton.enabled = NO;
    self.pushButton.layer.opacity = 0.2;
}

- (IBAction)centerNavController:(id)sender {
    self.viewDeckController.leftController = SharedAppDelegate.leftController;
    
    NestViewController* nestController = [[NestViewController alloc] initWithNibName:@"NestViewController" bundle:nil];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:nestController];
    self.viewDeckController.centerController = navController;

    self.pushButton.enabled = YES;
    self.pushButton.layer.opacity = 1;
}

- (void)pushOverCenter:(id)sender {
    PushedViewController* controller = [[PushedViewController alloc] initWithNibName:@"PushedViewController" bundle:nil];
    [self.viewDeckController rightViewPushViewControllerOverCenterController:controller];
}

- (IBAction)moveToLeft:(id)sender {
    [self.viewDeckController toggleOpenView];
}

- (IBAction)presentModal:(id)sender {
    IIViewDeckController* controller = [SharedAppDelegate generateControllerStack];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - view deck delegate

- (void)addLog:(NSString*)line {
    self.tableView.frame = (CGRect) { self.viewDeckController.rightSize, self.tableView.frame.origin.y,
        self.view.frame.size.width - self.viewDeckController.rightSize, self.tableView.frame.size.height };

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

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning {
    [self addLog:[NSString stringWithFormat:@"%@: %f", panning ? @"Pan" : @"Offset", offset]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"will open %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did open %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"will close %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did close %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didShowCenterViewFromSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did show center view from %@", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController willPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"will preview bounce %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didPreviewBounceViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    [self addLog:[NSString stringWithFormat:@"did preview bounce %@ view", NSStringFromIIViewDeckSide(viewDeckSide)]];
}

// don't pan over "bounce" buttons
- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldBeginPanOverView:(UIView *)view {
    if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationButton"] && [[[(id)view titleLabel] text] isEqualToString:@"bounce"])
        return NO;
    return YES;
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
