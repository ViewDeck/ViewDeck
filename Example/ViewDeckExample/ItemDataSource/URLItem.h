//
//  URLItem.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 10/16/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ItemCollectionViewController.h"


NS_ASSUME_NONNULL_BEGIN


@interface URLItem : NSObject <Item>

- (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url;

@end


NS_ASSUME_NONNULL_END
