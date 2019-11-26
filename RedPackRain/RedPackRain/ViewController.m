//
//  ViewController.m
//  RedPackRain
//
//  Created by Lee on 2019/11/26.
//  Copyright © 2019 YONGER. All rights reserved.
//

#import "ViewController.h"
#import "MTRedPackView.h"

@interface ViewController (){
    
    MTRedPackView *redPackView;
    
    NSInteger countTime;
    NSInteger curRedPackCount;
    
}
@property (weak, nonatomic) IBOutlet UILabel *gotTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *countDownButton;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)startRainAction:(id)sender {
    [self configRedPackView];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self beginRedPackAnimal];
    });

}

#pragma mark -
- (void)configRedPackView{
    __weak typeof(self) wkSelf = self;
    redPackView = [[MTRedPackView alloc] initWithFrame:self.view.bounds];
    redPackView.backgroundColor = [UIColor clearColor];
    redPackView.timeDir = .2f;
    redPackView.downSpeed = 2.8f;
    redPackView.endScore = ^(NSInteger score) {
        NSLog(@"最终得分 %@", @(score));
        [wkSelf changedCurScores:score];
    };
    redPackView.changedScore = ^(NSInteger score) {
        NSLog(@"点中积分了 %@", @(score));
        [wkSelf changedCurScores:score];
    };
    [self.view addSubview:redPackView];
}
- (void)changedCurScores:(NSInteger)score{
    curRedPackCount = score;
    self.gotTipLabel.text = [NSString stringWithFormat:@"已抢到%@个红包积分", @(score)];
}

#pragma mark - 倒计时
- (void)beginRedPackAnimal{
    [redPackView beginRainAnimal];
    [self beginCountDownTimer];
}

- (void)beginCountDownTimer{
    [self.timer invalidate];
    countTime = 15;
    //15s倒计时
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDownNum) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)countDownNum{
    [self.countDownButton setTitle:[NSString stringWithFormat:@"%@", @(countTime)] forState:UIControlStateNormal];
    countTime--;
    if (countTime < 0) {
        [self.timer invalidate];
        
        [redPackView removeFromSuperview];
        redPackView = nil;
    }
}

@end
