//
//  UserLocation.h
//  TestCLLocationSpeed
//
//  Created by Gena on 09.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface UserLocation : NSObject

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSDate *date;

- (NSDictionary *)toDictionary;

@end
