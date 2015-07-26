//
//  Util.m
//  GistView
//
//  Created by Sebastian Qu on 15/7/26.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#import "Util.h"

@implementation Util

#pragma mark - Public

+ (NSString *)formaterDateTime: (NSString *)dateTime formatterString:(NSString *)formatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *rawDate = [dateFormatter dateFromString:dateTime];
    return [NSDateFormatter localizedStringFromDate:rawDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

#pragma mark - Private

@end
