//
//  PhotosController.m
//  FeaturesExample
//

#import "PhotosController.h"
#import "IIViewDeckController.h"

@implementation PhotosController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 124;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        for (int i=0; i<8; ++i) {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:(CGRect) { 30 + 124*i, 10, 106, 106 }];
            imageView.tag = i;
            imageView.backgroundColor = [UIColor greenColor];
            imageView.image = [UIImage imageNamed:@"photo.png"];
            [cell addSubview:imageView];
        }
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
