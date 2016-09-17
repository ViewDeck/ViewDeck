//
//  ItemCollectionViewCell.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 9/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "ItemCollectionViewCell.h"

@implementation ItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    self.backgroundView = imageView;
    self.imageView = imageView;
}

@end
