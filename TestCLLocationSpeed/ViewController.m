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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;

@property (strong, nonatomic) INTULocationManager *locationManager;
@property (nonatomic) INTULocationRequestID requestId;
@property (nonatomic) BOOL observingLocation;

@property (nonatomic, strong) Logger *logger;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [INTULocationManager sharedInstance];
    self.logger = [Logger new];
    
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    self.speedLabel.text = @"0 km/h";
}

- (IBAction)buttonPressed:(UIButton *)sender {
    if (self.observingLocation) {
        [self stopObservingLocation];
        
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    } else {
        [self startObservingLocation];
        
        [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)updateSpeedFromLocation:(CLLocation *)location {
    // km/h
    double speed = location.speed * 3.6;
    
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f km/h", speed];
}

#pragma mark - Location

- (void)startObservingLocation {
    [self stopObservingLocation];
    self.observingLocation = YES;
    
    self.requestId = [self.locationManager subscribeToLocationUpdatesWithDesiredAccuracy:INTULocationAccuracyHouse block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        
        UserLocation *userLocation = [UserLocation new];
        userLocation.location = currentLocation;
        userLocation.date = [[NSDate alloc] init];
        
        [self.logger addUserLocation:userLocation];
        
        [self updateSpeedFromLocation:currentLocation];
    }];
}

- (void)stopObservingLocation {
    [self.locationManager cancelLocationRequest:self.requestId];
    self.observingLocation = NO;
    
    [self.logger saveToFile];
}

@end
