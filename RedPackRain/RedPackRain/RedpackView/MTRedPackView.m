//
//  MTRedPackView.m
//  RedPackDemo
//
//  Created by Lee on 2019/7/8.
//  Copyright © 2019 YONGER. All rights reserved.
//

#import "MTRedPackView.h"

#define kRedPackSizeW 70
#define kRedPackSizeH 70

@interface MTRedPackView()<CAAnimationDelegate>{
    
    NSInteger lastRand;
    NSInteger totalScore;
    UILabel *scoreLabel;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval startTimeStemp;

@end

@implementation MTRedPackView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.timeDir = 1.0;
        self.downSpeed = 3.0;
        self.scaleMax = 1.6;
        self.timeCost = 15.0;
        
    }
    return self;
}


#pragma mark - public meatherd
- (void)beginRainAnimal{
    [self.timer invalidate];

    self.startTimeStemp = [[NSDate date] timeIntervalSince1970];

    //.15
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeDir target:self selector:@selector(showRedPackRain) userInfo:nil repeats:YES];
    [self.timer fire];
    
    lastRand = -1;
    totalScore = 0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPackAction:)];
    [self addGestureRecognizer:tap];
}

- (void)endAnimal{
    [self.timer invalidate];
}

- (void)calculateTotalScore{
    if (self.endScore) {
        _endScore(totalScore);
    }
}

#pragma mark - red pack rain
- (void)showRedPackRain{
    
    [self.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((CALayer *)obj).animationKeys.count == 0 && ![obj isKindOfClass:[CATextLayer class]]
             && ![obj isKindOfClass:NSClassFromString(@"_UILabelLayer")] ) {
            [((CALayer *)obj) removeFromSuperlayer];
        };
    }];
    CGFloat dir = [[NSDate date] timeIntervalSince1970] - self.startTimeStemp;
    if (dir >= _timeCost-_downSpeed) {
        [self endAnimal];
        [self calculateTotalScore];
        return;
    }
    
    CALayer *addARedPack = [self getARedPack:CGPointMake(-100, -100)];
    [self.layer addSublayer:addARedPack];
    [self addAnimationForLayer:addARedPack];
}

- (void)clickPackAction:(UIGestureRecognizer *)tapgesture{
    CGPoint touchPoint = [tapgesture locationInView:self];
    touchPoint = CGPointMake(touchPoint.x, touchPoint.y+10);
    //for (CALayer *redPackLayer in self.layer.sublayers) {
    __weak typeof(self) wkSelf = self;
    [self.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CALayer *redPackLayer = (CALayer *)obj;
        
        if ([redPackLayer.presentationLayer hitTest:touchPoint]) {
            //NSLog(@"点击了 %@", redPackLayer);
            *stop = YES;
            if ([redPackLayer.animationKeys containsObject:@"click"]) {
                NSLog(@"重复点击 %@", redPackLayer);
                
            }else{
                __strong typeof(wkSelf) strongSelf = wkSelf;
                //点击动画
                [redPackLayer removeAllAnimations];
                [strongSelf addClickAnimationForLayer:redPackLayer];

                NSInteger rate = arc4random()%10;
                //概率： 0 -10%   1-70%  3-20%
                if (rate < 1) {
                    
                }else{
                    NSInteger score = 1;
                    if (rate > 7) {
                        score = 3;
                    }
                    self->totalScore += score;
                    
                    self->scoreLabel.text = [NSString stringWithFormat:@"得分：%@", @(self->totalScore)];
                    if (strongSelf.changedScore) {
                        _changedScore(totalScore);
                    }
                    
                    CGPoint p = redPackLayer.presentationLayer.position;
                    CGSize size = redPackLayer.presentationLayer.bounds.size;
                    redPackLayer.position = p;
                    
                    CATextLayer *txt = [strongSelf getTextLayer:CGPointMake(p.x-size.width*.5f, p.y-size.height*1.2) score:score];
                    
                    [strongSelf.layer addSublayer:txt];
                }
            }
        }
    }];
}
- (CALayer *)getARedPack:(CGPoint)position{
    CALayer *redLayer = [[CALayer alloc] init];
    redLayer.bounds = CGRectMake(0, 0, kRedPackSizeW, kRedPackSizeH);
    redLayer.anchorPoint = CGPointMake(.5f, .5f);
    redLayer.position = position;
    redLayer.contents =  (__bridge id _Nullable)([[UIImage imageNamed:@"money_bag_icon"] CGImage]);;
    return redLayer;
}

- (CATextLayer *)getTextLayer:(CGPoint)position score:(NSInteger)score{
    CATextLayer *textLayer = [CATextLayer new];
    textLayer.string = [NSString stringWithFormat:@"+%@", @(score)];
    textLayer.bounds = CGRectMake(0, 0, kRedPackSizeW, 30);
    textLayer.anchorPoint = CGPointZero;
    textLayer.position = position;
    textLayer.fontSize = 30;
    textLayer.foregroundColor = [UIColor redColor].CGColor;
    return textLayer;
}


- (void)addAnimationForLayer:(CALayer *)redLayer{
    CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH =UIScreen.mainScreen.bounds.size.height;
    CGFloat sizeW = redLayer.preferredFrameSize.width;
    //CGFloat sizeH = redLayer.preferredFrameSize.height;
    
    NSInteger count = screenW/sizeW;
    //CGFloat dir = (NSInteger)screenW % (NSInteger)sizeW;
    
    NSInteger rand = (arc4random()%count);
    
    
    NSInteger mid = count/2;
    while (lastRand == rand || ((mid < lastRand)&&(mid < rand)) ||
           ((mid > lastRand)&&(mid > rand)) ) {
        rand = (arc4random()%count);
    }
    //NSLog(@"通过 %@ - %@", @(lastRand), @(rand));
    lastRand = rand;
    
    //NSLog(@"通过- %@ -", @(lastRand));
    CGFloat startX = (rand + .5 +1 ) * (screenW/count);
    
    moveAnimation.values = @[[NSValue valueWithCGPoint:CGPointMake(startX, 0)],
                             [NSValue valueWithCGPoint:CGPointMake(startX-tan(8.0*M_PI/180.0)*screenH, screenH)]];
    moveAnimation.duration = _downSpeed;
    moveAnimation.repeatCount = 0;
    
    //动画的速度
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [redLayer addAnimation:moveAnimation forKey:@"move"];
}



- (void)addClickAnimationForLayer:(CALayer *)redLayer{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.fromValue = @1.0;
    
    animation.toValue = @(_scaleMax);
    
    //    animation.autoreverses = NO;
    
    //    animation.repeatCount = repertTimes;
    
    animation.duration = .50;//不设置时候的话，有一个默认的缩放时间.
    
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *opanimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    
    opanimation.fromValue=@1.0;
    
    opanimation.toValue=@0.0;
    
    opanimation.repeatCount = 0;
    
    opanimation.duration=.1;
    
    opanimation.removedOnCompletion=NO;
    
    opanimation.fillMode=kCAFillModeForwards;
    
    opanimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAAnimationGroup *groupAni = [self groupAnimation:@[animation] durTimes:.5 Rep:0];
    groupAni.delegate = self;
    [redLayer addAnimation:groupAni forKey:@"click"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        
        [self.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (((CALayer *)obj).animationKeys.count == 0
                && ![obj isKindOfClass:NSClassFromString(@"_UILabelLayer")]) {
                [((CALayer *)obj) removeFromSuperlayer];
            };
        }];
    }
}



-(CAAnimationGroup *)groupAnimation:(NSArray *)animationAry durTimes:(float)time Rep:(float)repeatTimes

{
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    
    animation.animations = animationAry;
    
    animation.duration = time;
    
    animation.removedOnCompletion = YES;
    
    animation.repeatCount = repeatTimes;
    
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
    
}



@end
