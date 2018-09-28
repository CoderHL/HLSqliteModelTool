//
//  HLModelTool.m
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/17.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import "HLModelTool.h"
#import <objc/runtime.h>
#import "HLModelProtocol.h"

typedef NS_ENUM(NSUInteger, OCEncodingType) {
    OCEncodingTypeA,
    OCEncodingTypeB,
    OCEncodingTypeC,
};

@implementation HLModelTool
const void * LH;
+ (NSString *)tableName:(Class)cls
{
    
//    objc_getAssociatedObject(self,  LH);
//    objc_setAssociatedObject(self, LH, @10, OBJC_ASSOCIATION_ASSIGN);
    return NSStringFromClass(cls);
}

+ (NSString *)tmpTableName:(Class)cls
{
    return [NSStringFromClass(cls) stringByAppendingString:@"_tmp"];
}

// 有效的成员变量名称,以及对应的类型(去掉忽略的)
+ (NSMutableDictionary *)classIvarNameAndTypeDic:(Class)cls;
{
    //获取这个类里面所有的成员变量以及类型
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    NSMutableDictionary *tempDic = @{}.mutableCopy;
    
    NSArray *ignoreNames = nil;
    if([cls respondsToSelector:@selector(ignoreColumnNames)]){
        ignoreNames = [cls ignoreColumnNames];
    }
    
    
    for (int i=0;i<outCount;i++){
        Ivar ivar = ivars[i];
        //获取成员变量名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        if([ivarName hasPrefix:@"_"]){//去掉下划线
            ivarName = [ivarName substringFromIndex:1];
        }
        
        if ([ignoreNames containsObject:ivarName]) continue;//去除忽略字段
        
        //获取成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        //注意:该方法代表压缩(去除)字符集合
        ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
        [tempDic setObject:ivarType forKey:ivarName];
    }
    return tempDic;
}

+ (NSMutableDictionary *)classIvarNameAndSqliteTypeDic:(Class)cls
{
    NSMutableDictionary *dic = [self classIvarNameAndTypeDic:cls];
    NSDictionary *typeDic = [self ocTypeToSqliteTypeDic];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        dic[key] = typeDic[obj];
    }];
    return dic;
}


+ (NSArray *)allTableSortedIvarNames:(Class)cls
{
    NSDictionary *dic = [self classIvarNameAndTypeDic:cls];
    NSArray *keys = dic.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return keys;
}


#pragma  mark - 私有方法

// 映射
+ (NSDictionary *)ocTypeToSqliteTypeDic {
    return @{
             @"d": @"real",
             @"f": @"real",
             
             @"i": @"integer",
             @"q": @"integer",
             @"Q": @"integer",
             @"B": @"integer",
             
             @"NSData": @"blob",
             @"NSDictionary": @"blob",
             @"NSMutableDictionary": @"blob",
             @"NSArray": @"blob",
             @"NSMutableArray": @"blob",
             
             @"NSString": @"text"
             };
}


+ (NSString *)columnNamesAndTypesStr:(Class)cls
{
    
    NSDictionary *nameTypeDic = [self classIvarNameAndSqliteTypeDic:cls];
    
    NSMutableArray *result = @[].mutableCopy;
    [nameTypeDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [result addObject:[NSString stringWithFormat:@"%@ %@",key,obj]];
    }];
    // 拼接
    return   [result componentsJoinedByString:@","];
}








@end
