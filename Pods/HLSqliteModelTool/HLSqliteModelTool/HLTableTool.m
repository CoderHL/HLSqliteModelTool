//
//  HLTableTool.m
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/17.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import "HLTableTool.h"
#import "HLModelTool.h"
#import "HLSqliteTool.h"

@implementation HLTableTool

+ (NSArray *)tableSortedColumnNames:(Class)cls uid:(NSString *)uid
{
    NSString *tableName = [HLModelTool tableName:cls];
    //从对应的表中获取创建该表的sql语句
    NSString *createSqlStr = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    
    NSDictionary *dic = [HLSqliteTool queryWithSql:createSqlStr andUid:uid].firstObject;
    NSString *createTableSql = [dic[@"sql"] lowercaseString];
    if (createTableSql.length == 0){
        return nil;
    }
    //解析表中的属性(正则匹配)
    NSString *nameTypeStr = [createTableSql componentsSeparatedByString:@"("][1];
    NSArray *nameTypeArray = [nameTypeStr componentsSeparatedByString:@","];
    NSMutableArray *names = [NSMutableArray array];
    for(NSString *nameType in nameTypeArray)
    {
        if ([nameType containsString:@"primary"]) continue;
        NSString *name = [nameType componentsSeparatedByString:@" "].firstObject;
        [names addObject:name];
    }
    
    //排序
    [names sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return names;
}


+ (BOOL)isTableExists:(Class)cls uid:(NSString *)uid
{
    NSString *tableName = [HLModelTool tableName:cls];
    NSString *queryString = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName ];
    NSMutableArray *result = [HLSqliteTool queryWithSql:queryString andUid:uid];
    return result.count > 0;
}




@end
