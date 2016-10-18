//
//  LocalDataSource.h
//  ViewDeckExample
//
//  Created by Michael Ochs on 10/16/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ItemCollectionViewController.h"


@interface LocalDataSource : NSObject <ItemDataSource>

- (instancetype)initWithFolder:(NSURL *)url;

@end
