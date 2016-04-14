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
@import CoreMotion;

#define kCMDeviceMotionUpdateFrequency (1.f/30.f)

@interface ViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelerationLabel;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;

//@property (strong, nonatomic) INTULocationManager *locationManager;
//@property (nonatomic) INTULocationRequestID requestId;
@property (nonatomic) BOOL observingLocation;

@property (nonatomic, strong) Logger *logger;

@property (nonatomic, strong) NSMutableArray *speedValuesArray;
@property (nonatomic) BOOL averagingEnabled;

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.locationManager = [INTULocationManager sharedInstance];
    self.logger = [Logger new];
    
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    self.speedLabel.text = @"0 km/h";
    self.averageSpeedLabel.text = @"0 km/h";
    self.accelerationLabel.text = @"0 km/h / sec";
    self.speedValuesArray = [NSMutableArray arrayWithArray:@[@(0)]];
    
    self.averagingEnabled = NO;
    
    self.manager = [CLLocationManager new];
    self.manager.delegate = self;
    self.manager.activityType = CLActivityTypeAutomotiveNavigation;
    self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.observingLocation = NO;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = kCMDeviceMotionUpdateFrequency;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMotionData)];

//    self.motionManager
}

- (IBAction)buttonPressed:(UIButton *)sender {
    if (self.observingLocation) {
//        [self stopObservingLocation];
        [self stopTrackingLocation];
        
        if ([CMMotionActivityManager isActivityAvailable]) {
            [self.motionManager stopDeviceMotionUpdates];
            [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    } else {
//        [self startObservingLocation];
        [self startTrackingLocation];
        
        if ([CMMotionActivityManager isActivityAvailable]) {
            [self.motionManager startDeviceMotionUpdates];
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        
        if (self.observingLocation) {
            [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }
}
- (IBAction)switchValueChanged:(UISwitch *)sender {
    self.averagingEnabled = sender.on;
}

- (void)updateMotionData {
    CMAcceleration acceleration = self.motionManager.deviceMotion.userAcceleration;
    
    double result = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2));
    result *= 3.6;
    self.accelerationLabel.text = [NSString stringWithFormat:@"%.1f km/h / sec", result];
}

- (void)updateSpeedFromLocation:(CLLocation *)location {
    // km/h
    double speed = MAX(location.speed * 3.6, 0);
    double result = speed;
    
    [self.speedValuesArray addObject:@(speed)];
    
//    if (self.averagingEnabled) {
        int speedValuesCount = 2;
        double speedSum = 0;
        int allValuesCount = (int)self.speedValuesArray.count;
        
        for (int i = allValuesCount - 1; i >= allValuesCount - speedValuesCount; i--) {
            speedSum += [self.speedValuesArray[i] doubleValue];
        }
        double averageResult = speedSum / speedValuesCount;
//    }
    self.averageSpeedLabel.text = [NSString stringWithFormat:@"%.1f km/h", averageResult];
    self.speedLabel.text = [NSString stringWithFormat:@"%.1f km/h", result];
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
