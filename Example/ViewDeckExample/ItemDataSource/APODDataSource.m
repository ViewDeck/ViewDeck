//
//  APODDataSource.m
//  ViewDeckExample
//
//  Created by Michael Ochs on 10/17/16.
//  Copyright © 2016 ViewDeck. All rights reserved.
//

#import "APODDataSource.h"

#import "URLItem.h"


NS_ASSUME_NONNULL_BEGIN


static NSString *const NASAApiKey = @"DEMO_KEY";


@interface APODDataSource ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) NSCalendar *calendar;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

@property (nonatomic, copy) NSArray<URLItem *> *items;

@end


@implementation APODDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];

        _calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];

        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"YYYY-MM-dd";
        _dateFormatter = dateFormatter;

        _items = @[];
    }
    return self;
}

- (void)prepareData:(void(^)())completionHandler {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        dispatch_group_t group = dispatch_group_create();

        NSCalendar *calendar = self.calendar;
        NSDateFormatter *dateFormatter = self.dateFormatter;
        NSDateComponents *components = [NSDateComponents new];
        NSDate *now = [NSDate new];

        NSMutableDictionary<NSNumber *, URLItem *> *items = [NSMutableDictionary new];

        for (int i = 0; i < 20; i++) {
            dispatch_group_enter(group);
            components.day = -i;
            NSDate *date = [calendar dateByAddingComponents:components toDate:now options:0];
            NSString *dateString = [dateFormatter stringFromDate:date];

            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.nasa.gov/planetary/apod?api_key=%@&date=%@", NASAApiKey, dateString]];
            NSURLSessionTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error loading APOD data: %@", error);
                    return;
                }
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                if (jsonResponse) {
                    NSURL *url = [NSURL URLWithString:jsonResponse[@"url"]];
                    if (url) {
                        NSString *title = jsonResponse[@"title"];
                        NSString *copyright = jsonResponse[@"copyright"];
                        NSMutableString *itemTitle = [NSMutableString stringWithString:title];
                        if (copyright.length > 0) {
                            if (itemTitle.length > 0) {
                                [itemTitle appendString:@" – "];
                            }
                            [itemTitle appendFormat:@"\u00A9 %@", copyright];
                        }
                        URLItem *item = [[URLItem alloc] initWithTitle:itemTitle url:url];
                        items[@(i)] = item;
                    }
                }

                dispatch_group_leave(group);
            }];
            [task resume];
        }

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            typeof(weakSelf) self = weakSelf;
            if (self == nil) { return; }

            NSArray<NSNumber *> *keys = [items.allKeys sortedArrayUsingSelector:@selector(compare:)];
            NSMutableArray *itemsArray = [NSMutableArray new];
            for (NSNumber *key in keys) {
                [itemsArray addObject:items[key]];
            }

            self.items = itemsArray;
            completionHandler();
        });
    });
}

- (NSUInteger)numberOfItems {
    return self.items.count;
}

- (id<Item>)itemAtIndex:(NSUInteger)index {
    return self.items[index];
}

@end


NS_ASSUME_NONNULL_END
