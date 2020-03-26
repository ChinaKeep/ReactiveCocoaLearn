//
//  Person.h
//  ReactCocoaLearn
//
//  Created by 随风流年 on 2020/3/25.
//  Copyright © 2020 随风流年. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
@property (nonatomic, strong)   NSString *name;
@property (nonatomic, strong)   NSString *age;
@property (nonatomic, strong)   NSString *height;
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
