//
//  HLSqliteTool.h
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/13.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLSqliteTool : NSObject

// 操作数据库(非查询)
+ (BOOL)dealWithSql:(NSString *)sql andUid:(NSString *)uid;

// 查询
+ (NSMutableArray <NSDictionary *> *)queryWithSql:(NSString *)sql andUid:(NSString *)uid;

// 同时执行多条语句
+ (BOOL)dealSqls:(NSArray <NSString *>*)sqls uid:(NSString *)uid;

@end
