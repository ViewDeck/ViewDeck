//
//  ItemCollectionViewController.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "ItemCollectionViewController.h"

#import <ViewDeck/ViewDeck.h>

#import "Item.h"
#import "ItemFinder.h"
#import "ItemCollectionViewCell.h"


@interface ItemCollectionViewController ()

@property (nonatomic, copy) NSArray *items;
@property (nonatomic) NSCache *imageCache;

@end


@implementation ItemCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _imageCache = NSCache.new;
        self.term = @"Game of Thrones";
        [self loadItems];

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
        while (width > 200.0) {
            width = size.width - layout.minimumInteritemSpacing * columns;
            width /= ++columns;
        }
        layout.itemSize = CGSizeMake(width, width * 1.5);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    [self.imageCache removeAllObjects];
}

- (void)loadItems {
    __weak typeof(self) weakSelf = self;
    [[ItemFinder sharedInstance] findItemsWithTerm:self.term completionHandler:^(NSArray<Item *> * _Nullable items, NSError * _Nullable error) {
        typeof(weakSelf) self = weakSelf;
        self.items = items;
        if (self.isViewLoaded) {
            [self.collectionView reloadData];
        }
    }];
}

- (void)setTerm:(NSString *)term {
    _term = term;
    self.title = term;
    [self.imageCache removeAllObjects];
    [self loadItems];
}

- (IBAction)openLeftSide:(id)sender {
    [self.viewDeckController openSide:IIViewDeckSideLeft animated:YES];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    Item *item = self.items[indexPath.row];

    cell.titleLabel.text = item.title;

    UIImage *image = [self.imageCache objectForKey:indexPath.copy];
    cell.imageView.image = image;

    if (image) {
        return cell;
    }

    __weak typeof(self) weakSelf = self;
    [[ItemFinder sharedInstance] fetchImageForItem:item completionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
        typeof(weakSelf) self = weakSelf;
        if (image) {
            [self.imageCache setObject:image forKey:indexPath.copy];

            ItemCollectionViewCell *cell = (ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                cell.imageView.image = image;
            }
        } else {
            NSLog(@"Error loading image: %@", error);
        }
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemCollectionViewCell *itemCell = (ItemCollectionViewCell *)cell;
    itemCell.imageView.image = [self.imageCache objectForKey:indexPath.copy];
}


#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
