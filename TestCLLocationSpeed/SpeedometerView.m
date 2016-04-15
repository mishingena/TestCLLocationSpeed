//
//  SpeedometerView.m
//  SpeedometerDemo
//
//  Created by Gena on 11.04.16.
//  Copyright © 2016 Gennadiy Mishin. All rights reserved.
//

#import "SpeedometerView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface SpeedometerView ()

@property (nonatomic, weak) UIView *speedView;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGPoint centerPoint;
@property (weak, nonatomic) UIView *speedLine;
@property (weak, nonatomic) UIView *speedLine2;

@property (nonatomic, strong) CASpringAnimation *dampingAnimation;
@property (nonatomic, strong) CASpringAnimation *rotationAnimation;

@end

CGFloat const LabelsRadiusOffset = -22.0;
CGFloat const SpeedLineRadiusOffset = -76.0;


@implementation SpeedometerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    self.centerPoint = CGPointMake(rect.size.height/2, rect.size.width/2);
    self.radius = (rect.size.width-50)/2;
    
    [self drawArcWithCenterPoint:self.centerPoint radius:self.radius startAngle:M_PI-M_PI/4 endAngle: M_PI/4];
    
    
    NSMutableArray *angelsArray = [NSMutableArray new];
    NSMutableArray *textAngelsArray = [NSMutableArray new];
    NSMutableArray *textArray = [NSMutableArray new];
    NSMutableArray *extraHeightArray = [NSMutableArray new];
    
    for (int i = -1; i < 24; i++) {
        [angelsArray addObject:@(-i*10+20)];
    }
    for (int i = -1; i < 24; i+=2) {
        [textAngelsArray addObject:@(-i*10+20)];
        int value = (i+1)*10;
        
        NSString *text = [NSString new];
        text = [NSString stringWithFormat:@"%d", value];
        
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text];
        
        [textArray insertObject:attrStr atIndex:0];
    }
    
    for (int i = 0; i < 26; i++) {
        if (i % 4 == 0) {
            [extraHeightArray addObject:@(8)];
        } else {
            [extraHeightArray addObject:@(0)];
        }
    }
    
    for (int i = 0; i < angelsArray.count; i++) {
        NSNumber *angle = angelsArray[i];
        CGFloat extraHeight = -[extraHeightArray[i] floatValue];
        [self placeViewWithAngle:DEGREES_TO_RADIANS(angle.floatValue) extraHeight:extraHeight];
    }
    
    for (int i = 0; i < textAngelsArray.count; i++) {
        NSNumber *angle = textAngelsArray[i];
        
        NSAttributedString *text = textArray[i];
        [self placeText:text withAngle:DEGREES_TO_RADIANS(angle.floatValue)];
    }
    
//    [self drawArcWithCenterPoint:self.centerPoint radius:self.radius+LabelsRadiusOffset startAngle:M_PI-M_PI/4 endAngle: M_PI/4];
    
    [self addSpeedLineWithRadius:self.radius+SpeedLineRadiusOffset angle:DEGREES_TO_RADIANS(SpeedLineStartAngle)];
    self.speedLineAngle = DEGREES_TO_RADIANS(SpeedLineStartAngle);
    
    CGFloat size = 16;
    CGRect circleFrame = CGRectMake(self.centerPoint.x-size/2, self.centerPoint.y-size/2, size, size);
    UIView *circle = [[UIView alloc] initWithFrame:circleFrame];
//    circle.backgroundColor = [UIColor redColor];
    circle.layer.borderColor = [UIColor redColor].CGColor;
    circle.layer.borderWidth = 1.0;
    circle.layer.cornerRadius = size/2;
    
    [self addSubview:circle];
}

- (void)drawArcWithCenterPoint:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    path.lineWidth = 2.0;
    [[UIColor whiteColor] setStroke];
    [[UIColor clearColor] setFill];
    
    [path stroke];
}

- (void)placeViewWithAngle:(CGFloat)angle extraHeight:(CGFloat)extraHeight {
    CGFloat x = self.centerPoint.x + (self.radius-extraHeight/2) * cos(angle);
    CGFloat y = self.centerPoint.y + (self.radius-extraHeight/2) * sin(angle);
    
    CGFloat width = 2;
    CGFloat height = 16+ABS(extraHeight);
    
    CGRect frame = CGRectMake(x-(width)/2, y-(height)/2, width, height);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle + M_PI/2);
    view.transform = transform;
    
    // to rerender and apply filters
    view.layer.shouldRasterize = YES;
}

- (void)placeText:(NSAttributedString *)text withAngle:(CGFloat)angle {
    CGFloat radius = self.radius + LabelsRadiusOffset;
    
    CGFloat x = self.centerPoint.x + radius * cos(angle);
    CGFloat y = self.centerPoint.y + radius * sin(angle);
    
    UIFont *font = [UIFont systemFontOfSize:12];

    CGSize stringSize = [[text string] sizeWithAttributes:@{NSFontAttributeName: font}];
    
    CGFloat width = stringSize.width;
    CGFloat height = stringSize.height;
    
    CGRect frame = CGRectMake(x-width/2, y-height/2, width, height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.attributedText = text;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    label.textColor = [UIColor whiteColor];
    label.center = CGPointMake(x, y);
    
//    label.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    label.layer.borderWidth = 1.0;
    
    label.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [self addSubview:label];
}

//- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
//    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
//}
//
//- (CGFloat)heightOfString:(NSString *)string withFont:(NSFont *)font {
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
//    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
//}

- (void)addSpeedLineWithRadius:(CGFloat)radius angle:(CGFloat)angle {
    CGFloat x = self.centerPoint.x + radius * cos(angle);
    CGFloat y = self.centerPoint.y + radius * sin(angle);
    
    CGFloat height = sqrt(ABS(x*x - self.centerPoint.x*self.centerPoint.x + y*y - self.centerPoint.y*self.centerPoint.y));
    CGFloat width = 2;
    
    CGRect frame = CGRectMake(0, 0, width, height);
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    frame.origin.y -= frame.size.height * 0.5;
    UIView *view2 = [[UIView alloc] initWithFrame:frame];
    
    [view addSubview:view2];
    
    view.layer.anchorPoint = CGPointMake(0.5, 0);
    view2.layer.anchorPoint = CGPointMake(0.5, 0);
    
    
    self.speedLine = view;
    self.speedLine2 = view2;
    
//    self.speedLine2.hidden = YES;
    
    
//    frame.origin.x = self.centerPoint.x - width/2;
//    frame.origin.y = self.centerPoint.y - height/2;
//    UIView *view = [[UIView alloc] initWithFrame:frame];
//    
//    view.backgroundColor = [UIColor whiteColor];
//    
    [self addSubview:view];
    view.center = self.centerPoint;
    
//    view.layer.anchorPoint = CGPointMake(0.5, 0);
//    self.speedLine = view;
//    self.speedLine.backgroundColor = [UIColor greenColor];
    
    self.speedLine.backgroundColor = [UIColor clearColor];
    
//
//    frame.origin.x = self.centerPoint.x - width/2;
//    frame.origin.y = self.centerPoint.y - height/2;
//    UIView *view2 = [[UIView alloc] initWithFrame:frame];
//    [view addSubview:view2];
//    
//    self.speedLine2 = view2;
    self.speedLine2.backgroundColor = [UIColor redColor];
//
    view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
//    view2.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
    
    // to rerender and apply filters
    self.speedLine.layer.shouldRasterize = YES;
    self.speedLine2.layer.shouldRasterize = YES;
    self.contentMode = UIViewContentModeRedraw;
}

- (void)rotateSpeedLineToAngle:(CGFloat)toAngle {
    [self rotateSpeedLineFromAngle:self.speedLineAngle toAngle:toAngle];
}

- (void)rotateSpeedLineFromAngle:(CGFloat)fromAngle toAngle:(CGFloat)toAngle {
    
    [self.speedLine.layer removeAnimationForKey:@"rotationAnimation"];
    
    if (self.rotationAnimation) {
        self.rotationAnimation.toValue = [NSNumber numberWithFloat:toAngle];
        self.rotationAnimation.fromValue = [NSNumber numberWithFloat:fromAngle];
        
        self.speedLineAngle = toAngle;
        
        [self.speedLine.layer addAnimation:self.rotationAnimation forKey:@"rotationAnimation"];
        
        return;
    }
    
    CGFloat duration = 1;
    
    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.rotation.z"];
    springAnimation.toValue = [NSNumber numberWithFloat:toAngle];
    springAnimation.fromValue = [NSNumber numberWithFloat:fromAngle];
    springAnimation.duration = duration;
//    springAnimation.repeatCount = HUGE_VALF;
    springAnimation.fillMode = kCAFillModeForwards;
    springAnimation.removedOnCompletion = NO;
    springAnimation.damping = 40;
//    springAnimation.autoreverses = YES;
    
//    springAnimation.additive = YES;
//    springAnimation.stiffness = 10;
    
//    [self.speedLine.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self.speedLine.layer addAnimation:springAnimation forKey:@"rotationAnimation"];
    
    self.speedLineAngle = toAngle;
    self.rotationAnimation = springAnimation;
//    self.dampingAnimation = springAnimation;
}

- (void)startDamping {
    CGFloat duration = 0.2;
    CGFloat byValue = 1;
    
    CGFloat fromFalue; //= self.speedLine.layer.presentationLayer
//    if (!self.dampingAnimation) {
    fromFalue = 0-byValue;
        
//    } else {
//        fromFalue = [self.dampingAnimation.toValue floatValue];
////        self.dampingAnimation = from
//    }
    
    CGFloat startAngle = DEGREES_TO_RADIANS(fromFalue);
    CGFloat endAngle = DEGREES_TO_RADIANS(fromFalue+byValue*2);
    
    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"transform.rotation.z"];
    springAnimation.toValue = [NSNumber numberWithFloat:startAngle];
    springAnimation.fromValue = [NSNumber numberWithFloat:endAngle];
    springAnimation.duration = duration;
    springAnimation.repeatCount = HUGE_VALF;
//    springAnimation.fillMode = kCAFillModeBoth;
    springAnimation.removedOnCompletion = NO;
    springAnimation.damping = 40;
    springAnimation.autoreverses = YES;
    
    [self.speedLine2.layer addAnimation:springAnimation forKey:@"speedLineDampingAnimation"];
    
    self.dampingAnimation = springAnimation;
}

- (void)stopDamping {
    self.dampingAnimation = nil;
    [self.speedLine2.layer removeAnimationForKey:@"speedLineDampingAnimation"];
}


@end
