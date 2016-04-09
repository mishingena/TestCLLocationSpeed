//
//  Logger.m
//  TestCLLocationSpeed
//
//  Created by Gena on 09.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import "Logger.h"
#import "UserLocation.h"

@interface Logger ()

@property (nonatomic, strong) NSMutableArray *userLocations;
@property (nonatomic, strong) NSString *fileName;

@end


@implementation Logger

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _userLocations = [NSMutableArray new];
        [self prepareFile];
    }
    return self;
}

- (void)prepareFile {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"userLocationLog.txt"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    }
    
    _fileName = fileName;
}

- (void)addUserLocation:(UserLocation *)userLocation {
    [self.userLocations addObject:[userLocation toDictionary]];
}


- (void)writeJSONToFile:(NSData *)json {
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:self.fileName];
    [file seekToEndOfFile];
    [file writeData:json];
    [file seekToEndOfFile];
    [file writeData:[@"\n------------------------------------------\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

- (void)saveToFile {
    if (self.userLocations.count > 0) {
        
        NSError *error;
        NSData *json = [NSJSONSerialization dataWithJSONObject:self.userLocations options:NSJSONWritingPrettyPrinted error:&error];
        
        if (!error) {
            [self writeJSONToFile:json];
            
            self.userLocations = [NSMutableArray new];
        }
    }
}

@end
