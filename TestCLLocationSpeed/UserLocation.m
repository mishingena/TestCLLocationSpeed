//
//  UserLocation.m
//  TestCLLocationSpeed
//
//  Created by Gena on 09.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import "UserLocation.h"

@implementation UserLocation

- (NSDictionary *)toDictionary {
    NSDictionary *coord = @{
                            @"latitude": @(self.location.coordinate.latitude).stringValue,
                            @"longitude": @(self.location.coordinate.longitude).stringValue
                            };
    NSString *dateString = [NSDateFormatter localizedStringFromDate:self.date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    return @{
             @"coordinate": coord,
             @"date": dateString,
             @"speed": @(self.location.speed).stringValue
             };
}

@end
