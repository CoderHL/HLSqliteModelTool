//
//  HLSqliteTool.m
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/13.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import "HLSqliteTool.h"
#import "sqlite3.h"

#define KCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

sqlite3 *db = nil;
@implementation HLSqliteTool

+ (BOOL)dealWithSql:(NSString *)sql andUid:(NSString *)uid
{
    if ([self openSqliteWithUid:uid] != SQLITE_OK) return NO;//打开数据库失败
    char *errmsg;
    BOOL result = sqlite3_exec(db, sql.UTF8String, nil, nil, &errmsg) == SQLITE_OK;
    if (errmsg) NSLog(@"errmsg == %s",errmsg);
    [self closeSqlite];
    return result;
}

+ (NSMutableArray <NSDictionary *> *)queryWithSql:(NSString *)sql andUid:(NSString *)uid
{
    //1.打开数据库
    [self openSqliteWithUid:uid];
    
    //使用准备语句(不然查出的类型全是string类型)
    sqlite3_stmt *ppStmt;
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &ppStmt, nil);
    if (result != SQLITE_OK) return nil;
    
    // 准备语句预处理成功
    // 绑定参数 (因为sql语句中没有占位符,所以此处省略)
    // 执行
    NSMutableArray *columnDicArray = [NSMutableArray array];
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {//有下一行
        //获取所有列的个数(属性)
        int count = sqlite3_column_count(ppStmt);
        NSMutableDictionary *columnDic = [NSMutableDictionary dictionary];
        [columnDicArray addObject:columnDic];
        for(int i=0;i<count;i++){
            //获取对应列的类型
           int type = sqlite3_column_type(ppStmt, i);
            NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(ppStmt, i)];
            id value;
            switch (type) {
                    case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                    case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                    case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                    case SQLITE_NULL:
                    value = @"";
                    break;
                    case SQLITE3_TEXT:
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                default:
                    break;
            }
            [columnDic setObject:value forKey:columnName];
        }
        
    }
    return columnDicArray;
}
+ (BOOL)dealSqls:(NSArray <NSString *>*)sqls uid:(NSString *)uid
{
    [self beginTransaction:uid];
    for (NSString *sql in sqls) {
       if(![self dealWithSql:sql andUid:uid])//有执行失败的
        {
            [self rollBackTransaction:uid];
            return NO;
        }
    }
    [self commitTransaction:uid];
    return YES;
}

#pragma mark-事务相关
//开启事务
+ (void)beginTransaction:(NSString *)uid
{
    [self dealWithSql:@"begin transaction" andUid:uid];
}


//提交事务
+ (void)commitTransaction:(NSString *)uid
{
    [self dealWithSql:@"commit transaction" andUid:uid];
}

//回滚事务
+ (void)rollBackTransaction:(NSString *)uid
{
    [self dealWithSql:@"rollback transaciton" andUid:uid];
}


#pragma mark -私有方法

+ (BOOL)openSqliteWithUid:(NSString *)uid
{
    //打开数据库
    NSString *dbName = @"common.sqlite";
    if(uid && uid.length)
    {
        dbName = [NSString stringWithFormat:@"%@.sqlite",uid];
    }
    
    NSString *dbPath = [KCachePath stringByAppendingPathComponent:dbName];
    
    //1.创建数据库
    return sqlite3_open(dbPath.UTF8String, &db);
}

+ (void)closeSqlite
{
    // 关闭
    sqlite3_close(db);
}






@end
