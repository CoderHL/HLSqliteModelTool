//
//  HLPerson.h
//  sqlite的封装
//
//  Created by 刘洪 on 2018/9/28.
//  Copyright © 2018年 刘洪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLModelProtocol.h"
@interface HLPerson : NSObject<HLModelProtocol>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) int age;

@property (nonatomic, assign) int num;

@end
