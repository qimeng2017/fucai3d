//
//  TriolionViewController.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2016/12/20.
//  Copyright © 2016年 邹壮壮. All rights reserved.
//

#import "TriolionViewController.h"
#import "LottoryCategoryModel.h"
#import "LNLotteryCategories.h"
#import <MJRefresh/MJRefresh.h>
#import "UserStore.h"
#import "LiuXSegmentView.h"
#import "TriolionModel.h"
#import "TriolionCell.h"
#import "TriolionTopAdModel.h"
#import "LNWebViewController.h"
#import "TriolionFootCell.h"
#import "LNLottoryConfig.h"
#import "LNScrollerView.h"
#import <SVProgressHUD.h>
#import "RankListModel.h"
#import "PersonalHomePageViewController.h"
#import "LoginViewController.h"
#import "LNAlertView.h"
#import "TriolionNewCenterView.h"
#import "PPMViewController.h"
#import "AwarddataModel.h"
#import "NSDate+Formatter.h"
#import "HRSystem.h"
#import "TrilionSegmentView.h"
#import "TrilionHeaderView.h"

#import "MoreHistoryVC.h"
#import "StatisticalViewController.h"
#import "RoadmapViewController.h"
#import "ScrollKLineViewController.h"
static CGFloat const TimerIntervals = 3.0;
static NSString *triolionCellCellWithIdentifier = @"triolionCellCellWithIdentifier";
static NSString *TriolionFootCellWithIdentifier = @"TriolionFootCellWithIdentifier";
@interface TriolionViewController ()<UITableViewDelegate,UITableViewDataSource,TriolionFootCellDelagate,LNScrollerViewDelegate,TriolionNewCenterViewDelegate,TrilionHeaderViewDelegate>
{
    MJRefreshNormalHeader *header;
    UILabel  *_lotteryDateLabel;//期数
    UIView   *_ballBgView;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) LottoryCategoryModel *categoryModel;
@property (nonatomic, strong) LiuXSegmentView *segmentView;
@property (nonatomic, strong) NSMutableArray *adArray;
@property (nonatomic, strong) LNScrollerView *scrollerView;
@property (nonatomic, strong) NSMutableArray *rankListArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong)NSMutableArray *topAdArray;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) BOOL isPage2;
@property (nonatomic, copy) NSString *lottory_number;/**<解释*/

@property (nonatomic, strong)AwarddataModel *awarddataModel;

@property(nonatomic,strong) NSTimer *timer;

@property (nonatomic, strong)NSArray *randomArray;

@property (nonatomic, strong)TriolionFootCell *triolionFootCell;
@end

@implementation TriolionViewController
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)topAdArray{
    if (_topAdArray == nil) {
        _topAdArray = [NSMutableArray array];
    }
    return _topAdArray;
}
- (NSMutableArray *)adArray{
    if (_adArray == nil) {
        _adArray = [NSMutableArray array];
    }
    return _adArray;
}
- (NSMutableArray *)rankListArray{
    if (_rankListArray == nil) {
        _rankListArray = [NSMutableArray array];
    }
    return _rankListArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configUI];
    self.kNavigationOpenTitle = YES;
    self.navigationItemTitle = [HRSystem appName];
    [self getTopAD];
    [self rankList];
}
- (void)configUI{
    
    UIView *headerView = [[UIView alloc]init];
    _scrollerView = [[LNScrollerView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    _scrollerView.delegate = self;
    [headerView addSubview:_scrollerView];
    
    //date
    _lotteryDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollerView.frame)+10, kScreenWidth, 20)];
    _lotteryDateLabel.textColor = [UIColor grayColor];
    _lotteryDateLabel.font = [UIFont systemFontOfSize:18];
    _lotteryDateLabel.textAlignment = NSTextAlignmentCenter;
    //[headerView addSubview:_lotteryDateLabel];
    //ball
    UIImage *ballImage = [UIImage imageNamed:@"ball_red"];
    
    _ballBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lotteryDateLabel.frame)+10, kScreenWidth, ballImage.size.height)];
    //[headerView addSubview:_ballBgView];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_ballBgView.frame)+5, kScreenWidth, 1)];
    line.backgroundColor = RGBA(0, 0, 0, 0.2);
    //[headerView addSubview:line];
    
    TriolionNewCenterView *centerView = [[TriolionNewCenterView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame)+10, kScreenWidth, [TriolionNewCenterView getHeight])];
    centerView.delegate = self;
   // [headerView addSubview:centerView];
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(centerView.frame)+5, kScreenWidth, 1)];
    line1.backgroundColor = RGBA(0, 0, 0, 0.2);
    //[headerView addSubview:line1];
    
    
    TrilionSegmentView *segmentView = [[TrilionSegmentView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollerView.frame), kScreenWidth, 62) clickBlick:^(NSInteger index) {
        LottoryCategoryModel *model =  [[LNLotteryCategories sharedInstance].categoryArray objectAtIndex:index];
        _selectedIndex = 0;
        _categoryModel = model;
        [self loadNewData];
        [header beginRefreshing];
    }];
    [headerView addSubview:segmentView];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(segmentView.frame), kScreenWidth-10, 30)];
    lable.backgroundColor = RGBA(242, 242, 242, 1);
    lable.text = @"玩法帮助";
    [headerView addSubview:lable];
    
    TrilionHeaderView *tHeaderView = [[TrilionHeaderView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lable.frame), kScreenWidth, [TrilionHeaderView getTrilionHeaderViewHeight])];
    tHeaderView.delegate = self;
    [headerView addSubview:tHeaderView];
    
    headerView.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(_scrollerView.frame)+CGRectGetHeight(segmentView.frame)+30+[TrilionHeaderView getTrilionHeaderViewHeight]);
    
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SCREEN_HEIGHT-tabBarHeight-navigationBarHeight-statusBarHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [[UIView alloc]init];
    _tableView.rowHeight =  115;
    _tableView.estimatedRowHeight = 100;//必须设置好预估值
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TriolionCell class]) bundle:nil] forCellReuseIdentifier:triolionCellCellWithIdentifier];
    [_tableView registerClass:[TriolionFootCell class] forCellReuseIdentifier:TriolionFootCellWithIdentifier];
    LottoryCategoryModel *caModel=  [LNLotteryCategories sharedInstance].currentLottoryModel;
    _categoryModel = caModel;
    
    [self refreshHeader];
    //[self refreshFooter];
}
- (void)tapHelpAction{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"playDesc" ofType:@"html"];
    
    LNWebViewController *viewCtrl = [[LNWebViewController alloc] initWithURL:[NSURL fileURLWithPath:path]];
    viewCtrl.title = LSTR(@"玩法说明");
    viewCtrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewCtrl animated:NO];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kLotteryDataCategoryNotification:) name:kLotteryDataCategoryNotification object:nil];
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    [MobClick beginLogPageView:@"TriolionViewController"];
   
    NSData *data =  [[NSUserDefaults standardUserDefaults] objectForKey:@"myBusinessCard"];
    double nextTime = 0;
    if (data) {
        AwarddataModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        nextTime  = [NSDate dateWithString:model.next.awardTime];
        self.awarddataModel = model;
    }
    
    double currentTime = [NSDate currentDate];
    if (currentTime > nextTime) {
       // [self getawarddata];
    }

}
#pragma mark - 数据加载
#pragma mark -- 刷新数据
- (void)refreshHeader{
    header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    // 设置文字
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"刷新数据" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    header.stateLabel.textColor = [UIColor grayColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor grayColor];
    
    // 马上进入刷新状态
    //[header beginRefreshing];
    
    // 设置刷新控件
    self.tableView.mj_header = header;
     self.tableView.mj_footer.automaticallyChangeAlpha = YES;
}

- (void)refreshFooter{
    // 添加默认的上拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 设置文字
    [footer setTitle:@"点击或上拉刷新" forState:MJRefreshStateIdle];
    [footer setTitle:@"加载更多" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:17];
    
    // 设置颜色
    footer.stateLabel.textColor = [UIColor  grayColor];
    footer.automaticallyHidden = YES;
    footer.automaticallyRefresh = NO;
    // 设置footer
    
    self.tableView.mj_footer = footer;
}



- (void)loadNewData{
     _currentPage = 1;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
         [self loadData:ScrollDirectionDown];
    });
     dispatch_group_async(group, queue, ^{
         if (_selectedIndex == 0) {
            
         }
         });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [_tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
        });


   
}
- (void)loadMoreData{
    if (_selectedIndex != 0) {
        _currentPage += 1;
        [self loadData:ScrollDirectionUp];
    }else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        self.tableView.mj_footer.hidden = YES;
    }
    
    
}
- (void)loadData:(ScrollDirection)direction{
    [SVProgressHUD showWithStatus:@"Loading..."];
    kWeakSelf(self);
    [[UserStore sharedInstance] newsCategory:_categoryModel.caipiaoid page:_currentPage sucess:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"%@",responseObject);
        NSNumber *codeNum = [responseObject objectForKey:@"code"];
        NSInteger code = [codeNum integerValue];
        if (code == 1) {
            NSArray *datas = [responseObject objectForKey:@"data"];
            NSMutableArray *arrayM = [NSMutableArray array];
            for (NSDictionary *dict in datas) {
                TriolionModel *model = [[TriolionModel alloc]initWithDictionary:dict error:nil];
                [arrayM addObject:model];
                
            }
            if (direction == ScrollDirectionDown) {
                weakself.dataArray = [arrayM mutableCopy];
            }else{
                [weakself.dataArray addObjectsFromArray:arrayM];
               
            }
            
            
        }else{
            [weakself.tableView.mj_footer endRefreshingWithNoMoreData];
            weakself.tableView.mj_footer.hidden = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [SVProgressHUD dismissWithDelay:1];
            if (direction == ScrollDirectionDown) {
                
                [weakself.tableView.mj_header endRefreshing];
                [weakself.tableView reloadData];
            }else if(direction == ScrollDirectionUp){
                
                [weakself.tableView reloadData];
                [weakself.tableView.mj_footer endRefreshing];
                
            }
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)getTopAD{
    [[UserStore sharedInstance]topAdSucess:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *top_ad_arr = [responseObject objectForKey:@"top_ad"];
        if (top_ad_arr.count > 0) {
            if (self.topAdArray.count > 0) {
                [_topAdArray removeAllObjects];
            }
        }
        for (NSDictionary *dict in top_ad_arr) {
            TriolionTopAdModel *model = [[TriolionTopAdModel alloc]initWithDictionary:dict error:nil];
            [self.topAdArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_topAdArray.count>0) {
                _scrollerView.imageArray = _topAdArray;
            }
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
- (void)rankList{
    NSDictionary *dict = @{@"playtype":@"1039",@"caipiaoid":@"1001",@"jisu_api_id":@"11"};
    
        kWeakSelf(self);
        
        [[UserStore sharedInstance]expert_rank:dict sucess:^(NSURLSessionDataTask *task, id responseObject) {
            
            //NSLog(@"%@",responseObject);
            NSNumber *codeNum = [responseObject objectForKey:@"code"];
            NSInteger code= [codeNum integerValue];
            if (code == 1) {
                NSArray *datas = [responseObject objectForKey:@"data"];
                if (datas.count > 0) {
                    if (_rankListArray.count > 0) {
                        [_rankListArray removeAllObjects];
                    }
                }
                for (NSDictionary *dict in datas) {
                    RankListModel *model = [[RankListModel alloc]initWithDictionary:dict error:nil];
                    [weakself.rankListArray addObject:model];
                }
               
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.tableView.mj_header endRefreshing];
                [weakself.tableView reloadData];
                [SVProgressHUD dismiss];
                [self startTimer];
                
            });
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_selectedIndex == 0) {
        if (self.rankListArray.count > 0) {
            return 2;
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return _dataArray.count;
    }else{
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 130;
    }else{
        return 140;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *HeaderInSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    HeaderInSectionView.backgroundColor = RGBA(242, 242, 242, 1);
    UILabel*titleLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 40)];
    titleLable.textAlignment = NSTextAlignmentLeft;
    [HeaderInSectionView addSubview:titleLable];
    UIButton *changBtn = [[UIButton alloc]init];
    [changBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [changBtn addTarget:self action:@selector(changAction) forControlEvents:UIControlEventTouchUpInside];
    [HeaderInSectionView addSubview:changBtn];
    [changBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(HeaderInSectionView.mas_top).with.offset(0);
        make.right.mas_equalTo(HeaderInSectionView.mas_right).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(120, 40));
    }];
    if (section == 1) {
        titleLable.text = @"推荐专家";
        [changBtn setTitle:@"换一换" forState:UIControlStateNormal];
        
        
    }else{
        titleLable.text = @"资讯";
    }
    return HeaderInSectionView;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        TriolionCell *cell = [tableView dequeueReusableCellWithIdentifier:triolionCellCellWithIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.dataArray.count > indexPath.row) {
            TriolionModel *model = [self.dataArray objectAtIndex:indexPath.row];
            cell.triolionModel = model;
        }
        return cell;
    }else{
        TriolionFootCell *cell = [tableView dequeueReusableCellWithIdentifier:TriolionFootCellWithIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.rankListArray.count > 0) {
            _randomArray = [self generateRandArray:3];
            [cell reloadScrollerView:_randomArray];
        }
        _triolionFootCell = cell;
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_dataArray.count > indexPath.row) {
        TriolionModel *model = [self.dataArray objectAtIndex:indexPath.row];
        NSURL *url = [NSURL URLWithString:model.url];
        LNWebViewController *web = [[LNWebViewController alloc]initWithURL:url];
        web.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:web animated:NO];
    }
    
}
- (void)selectedImageView:(RankListModel *)model{
    NSString *userID = UserDefaultObjectForKey(LOTTORY_AUTHORIZATION_UID);
    if (userID) {
        PersonalHomePageViewController *personalHomeVC = [[PersonalHomePageViewController alloc]init];
        personalHomeVC.expert_id = model.expert_id;
        personalHomeVC.nickname = model.nickname;
        personalHomeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personalHomeVC animated:YES];
    }else{
        [self alertView];
    }
    
}

- (void)alertView{
    LNAlertView *alert = [LNAlertView alertWithTitle:@"提示" message:@"您需要登录才允许查看该内容" cancelButtonTitle:@"取消"];
    [alert addDefaultStyleButtonWithTitle:@"登录" handler:^(LNAlertView *alertView, LNAlertButtonItem *buttonItem) {
        [alertView dismiss];
        [self presentViewController:[[LoginViewController alloc]init] animated:YES completion:nil];
    }];
    [alert show];
    
}
- (void)LNScrollerViewDidClicked:(NSUInteger)index{
    TriolionTopAdModel *model = [_adArray objectAtIndex:index];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:model.link]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timer invalidate];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [MobClick endLogPageView:@"TriolionViewController"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 20;//此高度为heightForHeaderInSection高度值
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}



- (void)clickLottory:(NSInteger)didSelectIndex{
    PPMViewController *pp = [[PPMViewController alloc]init];
    pp.hidesBottomBarWhenPushed = YES;
    pp.fromTriolionNewViewController = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController pushViewController:pp animated:YES];
}
-(void)getawarddata{
    
    [[UserStore sharedInstance]getawarddataSucessBlock:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict =(NSDictionary *)responseObject;
        AwarddataModel *Model = [[AwarddataModel alloc]initWithDictionary:dict error:nil];
        self.awarddataModel =Model;
        NSLog(@"ddd");
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
- (void)setAwarddataModel:(AwarddataModel *)awarddataModel{
    NSData*udObject= [NSKeyedArchiver archivedDataWithRootObject:awarddataModel];
    [[NSUserDefaults standardUserDefaults] setObject:udObject forKey:@"myBusinessCard"];
    
    _lottory_number = awarddataModel.current.awardNumbers;
    
    [self headerViewLayout:awarddataModel];
}
- (void)headerViewLayout:(AwarddataModel *)model{
    _lotteryDateLabel.text = [NSString stringWithFormat:@"%@ %@期 开奖号码", model.current.awardTime,model.current.periodNumber];
  
    [self customBall];
}
- (void)customBall
{
    for (UIView *view in _ballBgView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat x = 20;
    
    
    
    NSArray *nums = [_lottory_number componentsSeparatedByString:@","];
    NSUInteger count = nums.count;
    
    UIImage *ballImage = [UIImage imageNamed:@"ball_red"];
    x = (kScreenWidth - count*ballImage.size.width-(count-1)*10)/2;
    for (NSInteger index = 0; index < [nums count]; index ++) {
        
        UIButton *ballBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [ballBtn setBackgroundImage:[UIImage imageNamed:@"ball_red"] forState:UIControlStateNormal];
        ballBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [ballBtn setTitle:[nums objectAtIndex:index] forState:UIControlStateNormal];
        [ballBtn sizeToFit];
        ballBtn.frame = CGRectMake(x, 0, CGRectGetWidth(ballBtn.frame), CGRectGetHeight(ballBtn.frame));
        
        x += CGRectGetWidth(ballBtn.frame) + 10;
        
        [_ballBgView addSubview:ballBtn];
        
    }
    
}
#pragma mark - 私有方法
- (void)startTimer
{
    // 让之前的定时器失效并置为空
    [_timer invalidate];
    _timer = nil;
    
    // 1.创建一个定时器
    NSTimer *timer = [NSTimer timerWithTimeInterval:TimerIntervals target:self selector:@selector(chang) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _timer = timer;
}
- (void)chang{
    _randomArray = [self generateRandArray:3];
    if (_triolionFootCell) {
       [_triolionFootCell reloadScrollerView:_randomArray];
        [self setTransitionAnimations];
    }
    
}
- (void)changAction{
    [_timer invalidate];
    _timer = nil;
    
    _randomArray = [self generateRandArray:3];
    if (_triolionFootCell) {
       [_triolionFootCell reloadScrollerView:_randomArray];
        [self setTransitionAnimations];
    }
    [self startTimer];
}
- (NSArray *)generateRandArray:(NSInteger)count{
    NSMutableSet *randomSet = [[NSMutableSet alloc] init];
    
    while ([randomSet count] <= count) {
        int r = arc4random() % [_rankListArray count];
        [randomSet addObject:[_rankListArray objectAtIndex:r]];
    }
    
    NSArray *arr = [randomSet allObjects];
    return arr;
}
// 自定义转场动画
- (void)setTransitionAnimations
{
    self.triolionFootCell.userInteractionEnabled = YES;
    
    CATransition *transition = [CATransition animation];
    transition.duration = TimerIntervals * 0.3;
    transition.type = @"cube";
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.triolionFootCell.layer addAnimation:transition forKey:kCATransition];
}
#pragma mark -  TrilionHeaderViewDelegate
- (void)click:(NSInteger)index{
    switch (index) {
        case 0:
        {
            MoreHistoryVC *moreVC = [[MoreHistoryVC alloc]init];
            [self m_pushViewController:moreVC];
        }
            break;
        case 1:{
            StatisticalViewController *statistiaclVC = [[StatisticalViewController alloc]init];
            [self m_pushViewController:statistiaclVC];
        }
            break;
        case 2:{
            //路珠分析
            RoadmapViewController *roadMapVC = [[RoadmapViewController alloc]init];
            [self m_pushViewController:roadMapVC];
        }
            break;
        case 3:{
            //走势图
            ScrollKLineViewController *srollKLinVC = [[ScrollKLineViewController alloc]init];
            [self m_pushViewController:srollKLinVC];
        }
            break;
        default:
            break;
    }
}
- (void)m_pushViewController:(UIViewController *)viewController{
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
