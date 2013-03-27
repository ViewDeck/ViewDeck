//
//  SelectionController.m
//  FeaturesExample
//

#import "SelectionController.h"
#import "IIViewDeckController.h"
#import "PhotosController.h"
#import "SimpleController.h"
#import "WebController.h"

@implementation SelectionController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
                                              [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back)],
                                              [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(showSelector)],
                                              nil];
    
    self.navigationItem.title = @"Slide away";
}

- (void)back {
    [self.viewDeckController closeLeftView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSelector {
    [self.viewDeckController toggleLeftViewAnimated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel* label = [[UILabel alloc] initWithFrame:(CGRect) { 10, 0, 80, 100 }];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    label.text = @"Lorem Ipsum";
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = (CGSize) { 0, -1 };
    
    UIView* view = [[UIView alloc] initWithFrame:(CGRect) { 0, 0, 100, 100 }];
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    view.opaque = NO;
    
    return view;
}
                                                                                
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell0.0.0.0
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = indexPath.row == 0 ? @"Photos" : indexPath.row == 1 ? @"Web" : @"Simple";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            self.viewDeckController.centerController = [[PhotosController alloc] initWithNibName:@"PhotosController" bundle:nil];
            break;
        case 1:
            self.viewDeckController.centerController = [[WebController alloc] initWithNibName:@"WebController" bundle:nil];
            break;
        case 2:
            self.viewDeckController.centerController = [[SimpleController alloc] initWithNibName:@"SimpleController" bundle:nil];
            break;
    }
    
}

@end
