//
//  MTRedPackView.h
//  RedPackDemo
//
//  Created by Lee on 2019/7/8.
//  Copyright © 2019 YONGER. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^StatisticsEndScore)(NSInteger score);
typedef void(^ChangedScore)(NSInteger score);

@interface MTRedPackView : UIView

/* 红包雨的时间间隔
 * 下的多少
 */
@property (nonatomic, assign) CGFloat timeDir;

/* 单个红包下降时间/速度
 * 下的快慢
 */
@property (nonatomic, assign) CGFloat downSpeed;//

/* 点击放大倍数
 * 放大倍数
 */
@property (nonatomic, assign) CGFloat scaleMax;//

/* 倒计时间
 * 下多久
 */
@property (nonatomic, assign) CGFloat timeCost;//

@property (nonatomic, copy) StatisticsEndScore endScore;
@property (nonatomic, copy) ChangedScore changedScore;

- (void)beginRainAnimal;

- (void)endAnimal;

@end

NS_ASSUME_NONNULL_END
