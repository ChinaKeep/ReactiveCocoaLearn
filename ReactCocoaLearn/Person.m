
//
//  Person.m
//  ReactCocoaLearn
//
//  Created by 随风流年 on 2020/3/25.
//  Copyright © 2020 随风流年. All rights reserved.
//

#import "Person.h"

@implementation Person
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary{
    Person *person = [[Person alloc]init];
    person.name = dictionary[@"name"];
    person.age = dictionary[@"age"];
    person.height = dictionary[@"height"];
    return person;
}
@end
