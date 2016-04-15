//
//  SpeedViewController.m
//  TestCLLocationSpeed
//
//  Created by Gena on 14.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import "SpeedViewController.h"
#import "SpeedometerView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@import CoreLocation;

@interface SpeedViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet SpeedometerView *speedView;

@property (nonatomic) BOOL observingLocation;

@property (nonatomic) CGFloat speed;

@end


@implementation SpeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.button setTitle:@"Start" forState:UIControlStateNormal];
    self.speedLabel.text = @"0 km/h";
    
    self.manager = [CLLocationManager new];
    self.manager.delegate = self;
    self.manager.activityType = CLActivityTypeAutomotiveNavigation;
    self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.observingLocation = NO;
    
    self.speed = 0;
}

- (CGFloat)angleWithSpeed:(CGFloat)speed {
    return SpeedLineStartAngle + speed;
}

- (IBAction)buttonPressed:(id)sender {
    if (self.observingLocation) {
        [self stopTrackingLocation];
        
        [self.button setTitle:@"Start" forState:UIControlStateNormal];
    } else {
        [self startTrackingLocation];
        
        if (self.observingLocation) {
            [self.button setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }
}

- (void)updateSpeedFromLocation:(CLLocation *)location {
    
//    int val = arc4random_uniform(2) - 1;
//    if (val == 0) {
//        val++;
//    }
//    
////    self.speed += 2.0 * val;
//    self.speed += 2.0;
    
//    CGFloat speed = self.speed;
//     km/h
    CGFloat speed = MAX(location.speed * 3.6, 0);
    
    self.speedLabel.text = [NSString stringWithFormat:@"%.1f km/h", speed];
    
    CGFloat angle = DEGREES_TO_RADIANS([self angleWithSpeed:speed]);
    [self.speedView rotateSpeedLineToAngle:angle];
}


#pragma mark - Location

- (void)startTrackingLocation {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.manager requestAlwaysAuthorization];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        [self.manager startUpdatingLocation];
        self.observingLocation = YES;
//        [self.speedView startDamping];
    }
}

- (void)stopTrackingLocation {
    [self.manager stopUpdatingLocation];
    self.observingLocation = NO;
    
//    self.speed = 0;
//    CGFloat speed = self.speed;
//    
//    self.speedLabel.text = [NSString stringWithFormat:@"%.1f km/h", speed];
    
    CGFloat angle = DEGREES_TO_RADIANS([self angleWithSpeed:0]);
    [self.speedView rotateSpeedLineToAngle:angle];
    
//    [self.speedView stopDamping];
}

#pragma mark - Location delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    
    [self updateSpeedFromLocation:currentLocation];
}

@end
