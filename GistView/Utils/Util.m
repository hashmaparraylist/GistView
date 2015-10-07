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
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    [dateFormatter setTimeZone:sourceTimeZone];
    
    
    NSDate *rawDate = [dateFormatter dateFromString:dateTime];
    
    NSDateFormatter *localFormatter = [[NSDateFormatter alloc] init];
    
    [localFormatter setTimeZone:destinationTimeZone];

    [localFormatter setDateStyle:NSDateFormatterMediumStyle];
    [localFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [localFormatter stringFromDate:rawDate];
//    
//    return [localFormatter localizedStringFromDate:rawDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

#pragma mark - Private

@end
