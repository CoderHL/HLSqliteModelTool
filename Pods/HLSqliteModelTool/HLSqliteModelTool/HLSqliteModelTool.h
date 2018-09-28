//
//  HLSqliteModelTool.h
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/17.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HLSqliteModelToolColumnRelationType) {
    HLSqliteModelToolColumnRelationTypeMore,///>
    HLSqliteModelToolColumnRelationTypeLess,///<
    HLSqliteModelToolColumnRelationTypeEqual,///==
    HLSqliteModelToolColumnRelationTypeMoreEqual,///>=
    HLSqliteModelToolColumnRelationTypeLessEqual///<=
};

@interface HLSqliteModelTool : NSObject

//创建表格
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid;

//更新表格
+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid;

// 保存更新model
+ (BOOL)saveOrUpdateModel:(id)model uid:(NSString *)uid;

// 删除指定model
+ (BOOL)deleteModel:(id)model uid:(NSString *)uid;

// 根据条件删除
// whereStr 条件语句
+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid;

// 根据条件删除
+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(HLSqliteModelToolColumnRelationType)relation value:(id)value uid:(NSString *)uid;

// 查询所有的数据模型
+ (NSArray *)queryAllModels:(Class)cls uid:(NSString *)uid;

// 根据条件查询数据模型
+ (NSArray *)queryModels:(Class)cls columnName:(NSString *)name relation:(HLSqliteModelToolColumnRelationType)relation value:(id)value uid:(NSString *)uid;

// 使用sql查询数据模型
+ (NSArray *)queryModels:(Class)cls withSql:(NSString *)sql uid:(NSString *)uid;


@end
