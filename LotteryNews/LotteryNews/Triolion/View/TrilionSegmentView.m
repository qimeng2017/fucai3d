//
//  TrilionSegmentView.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2017/4/20.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "TrilionSegmentView.h"
#define windowContentWidth  ([[UIScreen mainScreen] bounds].size.width)
#define SFQRedColor [UIColor colorWithRed:255/255.0 green:92/255.0 blue:79/255.0 alpha:1]
#define MAX_TitleNumInWindow 6




@interface FunctionTrionlionSegmentView : UIView

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UILabel *functionLable;
@property (nonatomic, strong)UIButton *functionBtn;
+(instancetype)initWithImageName:(NSString *)imageName functionName:(NSString *)functionName;
@end

@implementation FunctionTrionlionSegmentView
+(instancetype)initWithImageName:(NSString *)imageName functionName:(NSString *)functionName{
    FunctionTrionlionSegmentView *functionView = [[FunctionTrionlionSegmentView alloc]initWithImageName:imageName functionName:functionName];
    return functionView;
}
- (instancetype)initWithImageName:(NSString *)imageName functionName:(NSString *)functionName{
    if (self = [super init]) {
        _imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        [self addSubview:_imageView];
        _functionLable = [[UILabel alloc]init];
        _functionLable.text = functionName;
        _functionLable.font = [UIFont systemFontOfSize:HXTitleSize];
        _functionLable.textColor = [UIColor blackColor];
        [_functionLable sizeToFit];
        [self addSubview:_functionLable];
        _functionBtn = [UIButton new];
       
        [self addSubview:_functionBtn];
        
    }
    return self;
}
- (void)setTag:(NSInteger)tag{
    _functionBtn.tag = tag-111;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top).with.offset(0);
    }];
    [_functionLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(_imageView.mas_bottom).with.offset(HXIcoAndTitleSpace);
    }];
    [_functionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(self);
    }];
}

@end
@interface TrilionSegmentView ()
@property (nonatomic,strong) NSMutableArray *btns;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) UIButton *titleBtn;
@property (nonatomic,strong) UIScrollView *bgScrollView;
@property (nonatomic,strong) UIView *selectLine;

@end
@implementation TrilionSegmentView
-(instancetype)initWithFrame:(CGRect)frame clickBlick:(btnClickBlock)block{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowColor=[UIColor blackColor].CGColor;
        self.layer.shadowOffset=CGSizeMake(2, 2);
        self.layer.shadowRadius=2;
        self.layer.shadowOpacity=.2;
        
        NSArray *titleArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"qiu" ofType:@"plist"]];
        _btns=[[NSMutableArray alloc] initWithCapacity:0];
         _defaultIndex=0;
        _titleNomalColor=[UIColor blackColor];
        _titleSelectColor=SFQRedColor;
        _bgScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, windowContentWidth, self.frame.size.height)];
        _bgScrollView.backgroundColor=[UIColor whiteColor];
        _bgScrollView.showsHorizontalScrollIndicator=NO;
        _bgScrollView.contentSize=CGSizeMake(functionW*titleArray.count, self.frame.size.height);
        [self addSubview:_bgScrollView];
        
        _selectLine=[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-2, functionW, 2)];
        _selectLine.backgroundColor=_titleSelectColor;
        [_bgScrollView addSubview:_selectLine];
        
        for (int i=0; i<titleArray.count; i++){
            NSDictionary *dict = [titleArray objectAtIndex:i];
            NSString *imageName = [dict objectForKey:@"image"];
            NSString *title = [dict objectForKey:@"title"];
            FunctionTrionlionSegmentView *funcView = [FunctionTrionlionSegmentView initWithImageName:imageName functionName:title];
            funcView.frame = CGRectMake(i*functionW, 0, functionW, functionH);
            funcView.tag = 111+i;
            [funcView.functionBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
            [_bgScrollView addSubview:funcView];
            self.block=block;
            [_btns addObject:funcView];
            if (i == 0) {
                _titleBtn = funcView.functionBtn;
                funcView.functionBtn.selected = YES;
               
                if (self.block) {
                    self.block(0);
                }
            }
        }
    }
    return self;
}
-(void)btnClick:(UIButton *)btn{
    if (self.block) {
        self.block(btn.tag);
    }
    if (btn.tag==_defaultIndex) {
        return;
    }else{
        _titleBtn.selected=!_titleBtn.selected;
       
        _titleBtn=btn;
        _titleBtn.selected=YES;
        
        _defaultIndex=btn.tag;
    }
    //计算偏移量
    FunctionTrionlionSegmentView *funcView = [_btns objectAtIndex:btn.tag];
    CGFloat offsetX=funcView.frame.origin.x - 2*functionW;
    if (offsetX<0) {
        offsetX=0;
    }
    CGFloat maxOffsetX= _bgScrollView.contentSize.width-functionW;
    if (offsetX>maxOffsetX) {
        offsetX=maxOffsetX;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        
        [_bgScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        _selectLine.frame=CGRectMake(funcView.frame.origin.x, self.frame.size.height-2, btn.frame.size.width, 2);
        
    } completion:^(BOOL finished) {
        
    }];
}
@end
