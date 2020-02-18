//
//  main.m
//  Objective-C的本质3
//
//  Created by 赵鹏 on 2019/4/30.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

//从main-arm64.cpp文件中复制过来的，它表示NSObject类的底层实现。
struct NSObject_IMPL {
    Class isa;
};

//自定义Person类
@interface Person : NSObject
{
    int _age;
}

@end

@implementation Person

@end

/**
 自定义Person类的父类是NSObject，所以它的底层实现如下：
 按照下面的计算结果，Person类的对象占内存空间应该是8+4 = 12字节，但是由源码可知，一个OC对象至少占16个字节的内存空间。另外也可根据内存对齐的规则：结构体的最终大小必须是其最大成员的倍数，所以应该应该是8*2 = 16字节。
 */
struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS;  //相当于NSObject_IMPL结构体中的Class isa成员变量，在64位环境下占8个字节。
    int _age;  //int类型的成员变量在64位环境下占4个字节。
};

//自定义Student类
@interface Student : Person
{
    int _no;
}

@end

@implementation Student

@end

/**
 自定义Student类的父类是Person类，它的底层实现如下：
 经过上面的分析，结构体内的Person_IMPL Person_IVARS成员变量占16个字节的内存空间，这16个字节中的前8个字节用来存储NSObject_IMPL NSObject_IVARS成员变量，后面的4个字节用来存储int _age成员变量，另外还剩余的4个字节用来存储该结构体的int _no成员变量，所以该结构体占用16个字节的内存空间。
 */
struct Student_IMPL {
    struct Person_IMPL Person_IVARS; //占16个字节的内存空间
    int _no; //占4个字节的内存空间
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *student = [[Student alloc] init];
        NSLog(@"student - %zd", class_getInstanceSize([Student class]));
        NSLog(@"student - %zd", malloc_size((__bridge const void *)(student)));
        
        Person *person = [[Person alloc] init];
        NSLog(@"person - %zd", class_getInstanceSize([Person class]));  //Person对象内部的成员变量所占的实际空间应该是8+4 = 12，此方法虽然返回的是对象内部的成员变量所占的空间，但是返回的应该是内存对齐过后的内存空间大小，所以返回的不应该是12，而是16。
        NSLog(@"person - %zd", malloc_size((__bridge const void *)(person)));
    }
    return 0;
}
