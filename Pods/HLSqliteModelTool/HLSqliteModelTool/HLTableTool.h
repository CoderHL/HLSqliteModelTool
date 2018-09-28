//
//  HLTableTool.h
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/17.
//  Copyright © 2018年 刘洪. All rights reserved.
//  解析表

#import <Foundation/Foundation.h>

@interface HLTableTool : NSObject

+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid;

+ (BOOL)isTableExists:(Class)cls uid:(NSString *)uid;
@end
