//
//  TrilionSegmentView.h
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/4/20.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import <UIKit/UIKit.h>

#define functionH 60
#define functionW kScreenWidth/4
#define HXTitleSize 14.0 //标签字体大小
#define HXIcoAndTitleSpace 10.0 //图标和标题间的间隔
typedef void(^btnClickBlock)(NSInteger index);
@interface TrilionSegmentView : UIView
/**
 *  未选中时的文字颜色,默认黑色
 */
@property (nonatomic,strong) UIColor *titleNomalColor;

/**
 *  选中时的文字颜色,默认红色
 */
@property (nonatomic,strong) UIColor *titleSelectColor;

/**
 *  字体大小，默认15
 */
@property (nonatomic,strong) UIFont  *titleFont;

/**
 *  默认选中的index=1，即第一个
 */
@property (nonatomic,assign) NSInteger defaultIndex;

/**
 *  点击后的block
 */
@property (nonatomic,copy)btnClickBlock block;

/**
 *  初始化方法
 *
 *  @param frame      frame
 *  @param titleArray 传入数组
 *  @param block      点击后的回调
 *
 *  @return;
 */
-(instancetype)initWithFrame:(CGRect)frame clickBlick:(btnClickBlock)block;
@end
