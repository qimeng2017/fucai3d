//
//  TrilionHeaderView.h
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/4/20.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import <UIKit/UIKit.h>
#define Start_X 5.0f*kScaleW           // 第一个按钮的X坐标
#define Start_Y 10.0f*kScaleW           // 第一个按钮的Y坐标
#define Width_Space 10.0f*kScaleW        // 2个按钮之间的横间距
#define Height_Space 20.0f*kScaleW      // 竖间距
#define Button_Height  80*kScaleW   // 高
#define Button_Width (kScreenWidth - Start_X*2 - Width_Space*3)/4      // 宽

@protocol TrilionHeaderViewDelegate <NSObject>

- (void)click:(NSInteger)index;

@end
@interface TrilionHeaderView : UIView
@property (nonatomic, weak)id<TrilionHeaderViewDelegate>delegate;
+(CGFloat)getTrilionHeaderViewHeight;
@end
