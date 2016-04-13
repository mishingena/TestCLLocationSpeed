//
//  ViewController.m
//  TestCLLocationSpeed
//
//  Created by Gena on 09.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import "ViewController.h"
#import <INTULocationManager.h>
#import "UserLocation.h"
#import "Logger.h"

@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;

//@property (strong, nonatomic) INTULocationManager *locationManager;
//@property (nonatomic) INTULocationRequestID requestId;
@property (nonatomic) BOOL observingLocation;

@property (nonatomic, strong) Logger *logger;

@property (nonatomic, strong) NSMutableArray *speedValuesArray;
@property (nonatomic) BOOL averagingEnabled;

@property (nonatomic, strong) CLLocationManager *manager;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.locationManager = [INTULocationManager sharedInstance];
    self.logger = [Logger new];
    
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    self.speedLabel.text = @"0 km/h";
    self.speedValuesArray = [NSMutableArray arrayWithArray:@[@(0)]];
    
    self.averagingEnabled = NO;
    
    self.manager = [CLLocationManager new];
    self.manager.delegate = self;
    self.observingLocation = NO;
}

- (IBAction)buttonPressed:(UIButton *)sender {
    if (self.observingLocation) {
//        [self stopObservingLocation];
        [self stopTrackingLocation];
        
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    } else {
//        [self startObservingLocation];
        [self startTrackingLocation];
        
        if (self.observingLocation) {
            [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }
}
- (IBAction)switchValueChanged:(UISwitch *)sender {
    self.averagingEnabled = sender.on;
}

- (void)updateSpeedFromLocation:(CLLocation *)location {
    // km/h
    double speed = MAX(location.speed * 3.6, 0);
    double result = speed;
    
    [self.speedValuesArray addObject:@(speed)];
    
    if (self.averagingEnabled) {
        int speedValuesCount = 2;
        double speedSum = 0;
        int allValuesCount = (int)self.speedValuesArray.count;
        
        for (int i = allValuesCount - 1; i >= allValuesCount - speedValuesCount; i--) {
            speedSum += [self.speedValuesArray[i] doubleValue];
        }
        result = speedSum / speedValuesCount;
    }
    
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f km/h", result];
}

#pragma mark - Location

- (void)startTrackingLocation {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestAlwaysAuthorization];
    } //else {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.manager startUpdatingLocation];
        self.observingLocation = YES;
    }
//    }
}

- (void)stopTrackingLocation {
    [self.manager stopUpdatingLocation];
    self.observingLocation = NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    
    UserLocation *userLocation = [UserLocation new];
    userLocation.location = currentLocation;
    userLocation.date = [[NSDate alloc] init];

    [self.logger addUserLocation:userLocation];
    
    [self updateSpeedFromLocation:currentLocation];
}


//- (void)startObservingLocation {
//    [self stopObservingLocation];
//    self.observingLocation = YES;
//    
//    self.requestId = [self.locationManager subscribeToLocationUpdatesWithDesiredAccuracy:INTULocationAccuracyHouse block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
//        
//        UserLocation *userLocation = [UserLocation new];
//        userLocation.location = currentLocation;
//        userLocation.date = [[NSDate alloc] init];
//        
//        [self.logger addUserLocation:userLocation];
//        
//        [self updateSpeedFromLocation:currentLocation];
//    }];
//}
//
//- (void)stopObservingLocation {
//    [self.locationManager cancelLocationRequest:self.requestId];
//    self.observingLocation = NO;
//    
//    [self.logger saveToFile];
//}

@end
