//
//  TrilionHeaderView.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/4/20.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "TrilionHeaderView.h"

#define mainConfigBtnList @[@{@"title":@"开奖记录",@"color":@"#ec6464"},@{@"title":@"统计结果",@"color":@"#007aff"},@{@"title":@"路珠分析",@"color":@"#686868"},@{@"title":@"走势图",@"color":@"#0062ab"}]
@implementation TrilionHeaderView
+(CGFloat)getTrilionHeaderViewHeight{
    return Button_Height+2*Start_Y;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0 ; i < mainConfigBtnList.count; i++){
            NSDictionary *dict = [mainConfigBtnList objectAtIndex:i];
            NSString *title = [dict objectForKey:@"title"];
            NSString *color = [dict objectForKey:@"color"];
            UIButton *aBt = [UIButton new];
            aBt.tag = i;
            aBt.frame = CGRectMake(Start_X+(Button_Width+Width_Space)*i, Start_Y, Button_Width, Button_Height);
            aBt.layer.masksToBounds = YES;
            aBt.layer.cornerRadius = 5;
            aBt.titleLabel.font = [UIFont systemFontOfSize:16];
            aBt.backgroundColor = [UIColor colorWithHexString:color];
            [aBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [aBt setTitle:title forState:UIControlStateNormal];
            [aBt addTarget:self action:@selector(abtAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:aBt];
        }
    }
    return self;
}
- (void)abtAction:(UIButton *)btn{
    if (_delegate&&[_delegate respondsToSelector:@selector(click:)]) {
        [_delegate click:btn.tag];
    }
}
@end
