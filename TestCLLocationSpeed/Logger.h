//
//  Logger.h
//  TestCLLocationSpeed
//
//  Created by Gena on 09.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserLocation;

@interface Logger : NSObject

- (void)addUserLocation:(UserLocation *)userLocation;

- (void)saveToFile;

@end
