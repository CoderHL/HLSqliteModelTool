//
//  HLModelTool.h
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/17.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLModelTool : NSObject

+ (NSString *)tableName:(Class)cls;

+ (NSString *)tmpTableName:(Class)cls;

// 所有的成员变量,以及成员变量对应的类型.
+ (NSMutableDictionary *)classIvarNameAndTypeDic:(Class)cls;

//成员变量OC类型编码映射到数据库中的类型
+ (NSMutableDictionary *)classIvarNameAndSqliteTypeDic:(Class)cls;

+ (NSString *)columnNamesAndTypesStr:(Class)cls;

+ (NSArray *)allTableSortedIvarNames:(Class)cls;

@end
