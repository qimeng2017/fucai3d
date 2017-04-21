//
//  AwarddataModel.h
//  StockMarket
//
//  Created by 邹壮壮 on 2017/3/15.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface currentModel : JSONModel
@property (nonatomic, strong) NSString *awardNumbers;
@property (nonatomic, strong) NSString *awardTime;
@property (nonatomic, strong) NSString *periodDate;
@property (nonatomic, strong) NSString *periodNumber;
@end
@interface nextModel : JSONModel
@property (nonatomic, strong) NSString *awardTime;
@property (nonatomic, strong) NSString *awardTimeInterval;
@property (nonatomic, strong) NSString *delayTimeInterval;
@property (nonatomic, strong) NSString *periodDate;
@property (nonatomic, strong) NSString *periodNumber;
@end
@interface AwarddataModel : JSONModel<NSCoding>
@property (nonatomic, strong) currentModel *current;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) nextModel *next;
@end
