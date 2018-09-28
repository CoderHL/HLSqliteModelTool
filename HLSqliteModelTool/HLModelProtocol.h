//
//  HLModelProtocol.h
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/17.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HLModelProtocol <NSObject>
@required
+ (NSString *)primaryKey;//让外界告诉我们使用什么主键

@optional
+ (NSArray *)ignoreColumnNames;//忽略字段数组

//新字段名称->旧字段名称
+ (NSDictionary *)newNameToNameDic ;
@end
