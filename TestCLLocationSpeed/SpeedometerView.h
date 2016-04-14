//
//  SpeedometerView.h
//  SpeedometerDemo
//
//  Created by Gena on 11.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat const SpeedLineStartAngle = 30.0;

@interface SpeedometerView : UIView

- (void)rotateSpeedLineFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle;
- (void)rotateSpeedLineToAngle:(CGFloat)toAngle;

@property (nonatomic) CGFloat speedLineAngle;

- (void)startDamping;
- (void)stopDamping;

@end
