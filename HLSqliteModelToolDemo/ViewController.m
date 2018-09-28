//
//  ViewController.m
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/13.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import "ViewController.h"
#import "HLSqliteModelTool.h"
#import "HLPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    CREATE TABLE IF NOT EXISTS t_student(name test,age integer,score real);
//    NSString *sql = @"create table if not exists s_stu(id integer primary key autoincrement,name text not null,age integer,score real)";
//    NSString *sql = @"insert into s_stu(name ,age ,score) values('lH','20','90')";
//    BOOL result = [HLSqliteTool dealWithSql:sql andUid:nil];
    
//    [self addObject];
    
//    [self updateTable];
    
    [self queryModel];
//    [self queryWithCondition];
//    [self deleteTheModel];
//    [self queryModelWithCondition];
}

//增 或 更新
- (void)addObject
{
    HLPerson *person = [[HLPerson alloc]init];
    person.name = @"HL";
    person.age = 11;
    person.num = 4;
    [HLSqliteModelTool saveOrUpdateModel:person uid:@"3"];
    
}

//更新表格
- (void)updateTable
{
    [HLSqliteModelTool updateTable:[HLPerson class] uid:@"1"];
}

//查询所有
- (void)queryModel
{
    NSArray *queryModels = [HLSqliteModelTool queryAllModels:[HLPerson class] uid:@"3"];
    NSLog(@"queryModels == %@",queryModels);
}


//根据条件查询
- (void)queryWithCondition
{
    /// 1   通过sql语句进行查询
//   NSArray *array = [HLSqliteModelTool queryModels:[HLPerson class] withSql:@"select * from HLPerson where num = 2" uid:@"3"];
//    NSLog(@"array == %@",array);
    
    /// 2
    NSArray *array = [HLSqliteModelTool queryModels:[HLPerson class] columnName:@"num" relation:HLSqliteModelToolColumnRelationTypeEqual value:@2 uid:@"3"];
    NSLog(@"array == %@",array);
}

// 删除指定model

- (void)deleteTheModel
{
    HLPerson *person = [[HLPerson alloc]init];
    person.name = @"HL";
    person.age = 11;
    person.num = 2;
//    BOOL result = [HLSqliteModelTool deleteModel:person uid:@"3"];
    // 删除所有
    BOOL result = [HLSqliteModelTool deleteModel:[HLPerson class] whereStr:nil uid:@"3"];
    
}

/// 根据条件删除
- (void)queryModelWithCondition
{
    // 删除指定模型
//   BOOL result = [HLSqliteModelTool deleteModel:[HLPerson class] whereStr:@"num = 1" uid:@"3"];
    
    BOOL result = [HLSqliteModelTool deleteModel:[HLPerson class] columnName:@"num" relation:HLSqliteModelToolColumnRelationTypeMore value:@2 uid:@"3"];
    
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
