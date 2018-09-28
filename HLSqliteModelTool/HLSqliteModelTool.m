//
//  HLSqliteModelTool.m
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/17.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import "HLSqliteModelTool.h"
#import "HLModelTool.h"
#import "HLModelProtocol.h"
#import "HLSqliteTool.h"
#import "HLTableTool.h"

@implementation HLSqliteModelTool

+ (BOOL)createTable:(Class)cls uid:(NSString *)uid
{
    //1.拼接创建表格的sql语句
    //1.1 获取表格名称
    NSString *tableName = [HLModelTool tableName:cls];
    
    //1.2 获取一个模型里面所有的字段,以及类型
    
    if (![cls respondsToSelector:@selector(primaryKey)])
    {
        NSLog(@"若想要操作这个模型,必须实现+ (NSString *)primaryKey;这个方法来告诉我主键信息");
        return NO;
    }
    
    NSString *primaryKey = [cls primaryKey];
    
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@,primary key(%@))",tableName,[HLModelTool columnNamesAndTypesStr:cls],primaryKey];
    

    //2.执行
    return [HLSqliteTool dealWithSql:createTableSql andUid:uid];
}


//判断表是否需要更新
+ (BOOL)isTableRequiredUpdate:(Class)cls uid:(NSString *)uid
{
    NSArray *modelNames = [HLModelTool allTableSortedIvarNames:cls];
    NSArray *tableName = [HLTableTool tableSortedColumnNames:cls uid:uid];
    return ![modelNames isEqualToArray:tableName];
}


+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid
{
    // 1.创建一个拥有正确结构的临时表
    //1.拼接创建表格的sql语句
    //1.1 获取表格名称
    NSString *tmpTableName = [HLModelTool tmpTableName:cls];
    
    NSString *tableName = [HLModelTool tableName:cls];
    
    //1.2 获取一个模型里面所有的字段,以及类型
    
    if (![cls respondsToSelector:@selector(primaryKey)])
    {
        NSLog(@"若想要操作这个模型,必须实现+ (NSString *)primaryKey;这个方法来告诉我主键信息");
        return NO;
    }
    
    NSMutableArray *execSqls = [NSMutableArray array];
    
    NSString *primaryKey = [cls primaryKey];
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@ primary Key(%@))",tableName,[HLModelTool columnNamesAndTypesStr:cls],primaryKey];
    [execSqls  addObject:createTableSql];
    
    //2. 插入主键数据
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@",tmpTableName,primaryKey,primaryKey,tableName];
    [execSqls addObject:insertPrimaryKeyData];
    
    //3.根据主键将所有的数据更新到新表里面
    NSArray *oldNames = [HLTableTool tableSortedColumnNames:cls uid:uid];
    NSArray *newNames = [HLModelTool allTableSortedIvarNames:cls];
    
    //4.获取更名字典
    NSDictionary *newNameToOldNameDic = @{};
//    @{@"age":@"age2"}
    if ([cls respondsToSelector:@selector(newNameToNameDic)])
    {
        newNameToOldNameDic = [cls newNameToNameDic];
    }
    
    for (NSString *columnName in newNames)
    {
        NSString *oldName = columnName;
        //找映射的旧的字段名称
        if([newNameToOldNameDic[columnName] length]){//存在旧的映射
            oldName = newNameToOldNameDic[columnName];
        }
        
        //若包含了新的列名,应该从老表更新到临时表格里面
        if((![oldNames containsObject:columnName] && ![oldNames containsObject:oldName]) || [columnName isEqualToString:primaryKey])
        {
            continue;
        }
//        update xmgstu_tmp set name = (select name from xmgstu where xmgstu_tmp.stuNum = xmgstu.stuNum)
        NSString *updateSql = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)",tmpTableName,columnName,oldName,tableName,tmpTableName,primaryKey,tableName,primaryKey];
        [execSqls addObject:updateSql];
    }
    
    //删除旧表格
    NSString *deleteOldTable = [NSString stringWithFormat:@"drop table if exists %@",tableName];
    [execSqls addObject:deleteOldTable];
    
    //重命名临时表名
    NSString *renameTableName = [NSString stringWithFormat:@"alert table %@ rename to %@",tmpTableName,tableName];
    [execSqls addObject:renameTableName];
    return YES;
}

+ (BOOL)saveOrUpdateModel:(id)model uid:(NSString *)uid
{
    //1.先判断表格是否存在
    Class cls = [model class];
    if(![HLTableTool isTableExists:cls uid:uid])//表格不存在,创建表格
    {
        [self createTable:cls uid:uid];
    }
    //2.判断表是否需要更新
    if([self isTableRequiredUpdate:cls uid:uid])
    {
        [self updateTable:cls uid:uid];
    }
    //3.判断记录是否存在
    //按照主键从表格中进行查询,看记录是否存在
    NSString *tableName = [HLModelTool tableName:cls];
    if (![cls respondsToSelector:@selector(primaryKey)])
    {
        NSLog(@"若想要操作这个模型,必须实现+ (NSString *)primaryKey;这个方法来告诉我主键信息");
        return NO;
    }
//    NSMutableArray *execSqls = [NSMutableArray array];
    NSString *primarykey = [cls primaryKey];
    id primaryValue= [model valueForKeyPath:primarykey];
    NSString *checkSql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",tableName,primarykey,primaryValue];
    //执行查询操作
    NSArray *results = [HLSqliteTool queryWithSql:checkSql andUid:uid];
    //存在对应的数据
    
    //获取所有的keys
    NSArray *columnNames = [HLModelTool classIvarNameAndTypeDic:cls].allKeys;
    //获取所有值
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *columnName in columnNames) {
        [values addObject:[model valueForKeyPath:columnName]];
    }
    
    NSMutableArray *keyValuesArray = [NSMutableArray array];
    for(int i=0;i<columnNames.count;i++)
    {
        NSString *keyValueString = [NSString stringWithFormat:@"%@='%@'",columnNames[i],values[i]];
        [keyValuesArray addObject: keyValueString];
    }
    
    NSString *execSql;
    if(results.count>0){//更新操作
        //update 表名 set 字段1=字段1的值,字段2=字段2的值,...where 主键 = '主键值'
        execSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'",tableName,[keyValuesArray componentsJoinedByString:@","],primarykey,primaryValue];
    }else{//插入操作
        //insert 表名 into 表名(字段1,字段2,字段3) values (值1, 值2, 值3)
        
        execSql = [NSString stringWithFormat:@"insert into %@(%@) values('%@')",tableName,[columnNames componentsJoinedByString:@","],[values componentsJoinedByString:@"','"]];
    }
    
    return [HLSqliteTool dealWithSql:execSql andUid:uid];
}


+ (BOOL)deleteModel:(id)model uid:(NSString *)uid
{
    Class cls = [model class];
    NSString *tableName = [HLModelTool tableName:cls];
    //获取主键
    if (![cls respondsToSelector:@selector(primaryKey)])
    {
        NSLog(@"若想要操作这个模型,必须实现+ (NSString *)primaryKey;这个方法来告诉我主键信息");
        return NO;
    }
    //    NSMutableArray *execSqls = [NSMutableArray array];
    NSString *primarykey = [cls primaryKey];
    id primaryValue = [model valueForKeyPath:primarykey];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",tableName,primarykey,primaryValue];
    
    return [HLSqliteTool dealWithSql:deleteSql andUid:uid];
}


+ (BOOL)deleteModel:(Class)cls whereStr:(NSString *)whereStr uid:(NSString *)uid
{
    NSString *tableName = [HLModelTool tableName:cls];
    
     NSString *deleteSql = [NSString stringWithFormat:@"delete from %@",tableName];
    if (whereStr.length > 0) {
        deleteSql = [deleteSql stringByAppendingFormat:@" where %@",whereStr];
    }
    return [HLSqliteTool dealWithSql:deleteSql andUid:uid];
}

+ (BOOL)deleteModel:(Class)cls columnName:(NSString *)name relation:(HLSqliteModelToolColumnRelationType)relation value:(id)value uid:(NSString *)uid
{
    NSString *tableName = [HLModelTool tableName:cls];
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ %@ '%@'",tableName,name,self.columnNameToValueRelationTypeDic[@(relation)],value];
    
    return [HLSqliteTool dealWithSql:deleteSql andUid:uid];
}

//根据条件进行查询
+ (NSArray *)queryModels:(Class)cls columnName:(NSString *)name relation:(HLSqliteModelToolColumnRelationType)relation value:(id)value uid:(NSString *)uid
{
    NSString *tableName = [HLModelTool tableName:cls];
    // 拼接sql语句
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ %@ '%@'",tableName,name,self.columnNameToValueRelationTypeDic[@(relation)],value];
    
    // 查询结果集
    NSArray <NSDictionary *>*results = [HLSqliteTool queryWithSql:sql andUid:uid];
    // 3.处理查询的结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
    
}

// 处理查询的结果集
+ (NSArray *)parseResults:(NSArray <NSDictionary *>*)results withClass:(Class)cls
{
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *modelDic in results) {
        id model = [[cls alloc]init];
        [models addObject:model];
        [model setValuesForKeysWithDictionary:modelDic];
    }
    return models;
}


//映射表
+ (NSDictionary *)columnNameToValueRelationTypeDic
{
    return @{
             @(HLSqliteModelToolColumnRelationTypeMore):@">",
             @(HLSqliteModelToolColumnRelationTypeLess):@"<",
             @(HLSqliteModelToolColumnRelationTypeEqual):@"==",
             @(HLSqliteModelToolColumnRelationTypeMoreEqual):@">=",
             @(HLSqliteModelToolColumnRelationTypeLessEqual):@"<="
             };
}

+ (NSArray *)queryAllModels:(Class)cls uid:(NSString *)uid
{
    // 1.拼接sql语句
    NSString *tableName = [HLModelTool tableName:cls];
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
    // 2.执行查询
    // 模型的属性名称和属性值
    NSArray <NSDictionary *>*results = [HLSqliteTool queryWithSql:sql andUid:uid];
    // 3.处理查询的结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}

+ (NSArray *)queryModels:(Class)cls withSql:(NSString *)sql uid:(NSString *)uid
{
   
    // 2.执行查询
    // 模型的属性名称和属性值
    NSArray <NSDictionary *>*results = [HLSqliteTool queryWithSql:sql andUid:uid];
    // 3.处理查询的结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}



@end
