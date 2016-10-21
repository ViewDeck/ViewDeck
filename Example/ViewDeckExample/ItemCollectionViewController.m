//
//  ItemCollectionViewController.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "ItemCollectionViewController.h"

#import <ViewDeck/ViewDeck.h>

#import "ItemCollectionViewCell.h"


@interface ItemCollectionViewController ()

@end


@implementation ItemCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(openLeftSide:)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(ItemCollectionViewCell.class) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateLayoutForSize:self.view.bounds.size];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self updateLayoutForSize:size];
    } completion:NULL];
}

- (void)updateLayoutForSize:(CGSize)size {
    if ([self.collectionViewLayout isKindOfClass:UICollectionViewFlowLayout.class]) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
        NSUInteger columns = 1;
        CGFloat width = size.width - layout.sectionInset.left - layout.sectionInset.right;
        while (width > fmax(size.width * 0.3, 320.0)) {
            width = size.width - layout.minimumInteritemSpacing * columns;
            width /= ++columns;
        }
        layout.itemSize = CGSizeMake(width, width / (4.0 / 3.0));
    }
}

- (IBAction)openLeftSide:(id)sender {
    [self.viewDeckController openSide:IIViewDeckSideLeft animated:YES];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemCollectionViewCell *itemCell = (ItemCollectionViewCell *)cell;

    id<Item> item = [self.dataSource itemAtIndex:indexPath.row];

    [self configureCell:itemCell withItem:item];

    __weak typeof(self) weakSelf = self;
    [item resolveFuture:^{
        typeof(weakSelf) self = weakSelf;
        ItemCollectionViewCell *cell = (ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self configureCell:cell withItem:item];
    }];
}

- (void)configureCell:(ItemCollectionViewCell *)cell withItem:(id<Item>)item {
    cell.titleLabel.text = item.title;
    cell.imageView.image = item.image;
}


#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


#pragma mark - Updating the Data Source

- (void)setDataSource:(id<ItemDataSource>)dataSource {
    _dataSource = dataSource;
    if (self.isViewLoaded) {
        [self.collectionView reloadData];
    }
    __weak typeof(self) weakSelf = self;
    [dataSource prepareData:^{
        typeof(weakSelf) self = weakSelf;
        if (self.isViewLoaded) {
            [self.collectionView reloadData];
        }
    }];
}

@end
