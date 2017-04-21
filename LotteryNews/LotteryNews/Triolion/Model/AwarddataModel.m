//
//  AwarddataModel.m
//  StockMarket
//
//  Created by 邹壮壮 on 2017/3/15.
//  Copyright © 2017年 邹壮壮. All rights reserved.
//

#import "AwarddataModel.h"

@implementation currentModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
@implementation nextModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
@implementation AwarddataModel
@synthesize current,next,time;
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.current = [aDecoder decodeObjectForKey:@"current"];
        self.next = [aDecoder decodeObjectForKey:@"next"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.current forKey:@"current"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.next forKey:@"next"];
}
@end
