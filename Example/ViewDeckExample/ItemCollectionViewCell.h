//
//  ItemCollectionViewCell.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) IBOutlet UILabel *titleLabel;

@end
