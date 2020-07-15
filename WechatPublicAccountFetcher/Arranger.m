//
//  Arranger.m
//  WechatPublicAccountFetcher
//
//  Created by mayan on 2020/7/15.
//  Copyright © 2020 马岩. All rights reserved.
//

#import "Arranger.h"

@implementation Arranger

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)arrangeGeneralMsgList {
    // 自定义文件目录
    NSString *inputPath = @"/Users/may-g/Desktop/Intput/wow36kr";
    NSString *outputPath = @"/Users/may-g/Desktop/Output";
    
    NSArray *dir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputPath error:nil];
    
    // 获取所有 general_msg_list
    NSMutableArray *responseObjects = [NSMutableArray array];
    for (NSString *path in dir) {
        NSData *data = [NSData dataWithContentsOfFile:[inputPath stringByAppendingPathComponent:path]];
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (responseObject) {
            data = [responseObject[@"general_msg_list"] dataUsingEncoding:NSUTF8StringEncoding];
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [responseObjects addObjectsFromArray:responseObject[@"list"]];
        }
    }
    
    // 遍历 general_msg_list 打印其中包含的 key 和 key 的个数
    NSMutableDictionary *keyMap = [NSMutableDictionary dictionary];
    for (NSDictionary *data in responseObjects) {
        for (NSString *key in data.allKeys) {
            NSNumber *num = keyMap[key];
            keyMap[key] = [NSNumber numberWithInt:num.intValue + 1];
        }
    }
    NSLog(@"keyMap: %@", keyMap);
    
    NSMutableArray *msglistArray = [NSMutableArray array];
    
    // 遍历 general_msg_list 组装数据
    for (NSDictionary *data in responseObjects) {
        NSDictionary *comm_msg_info      = data[@"comm_msg_info"];
        NSDictionary *image_msg_ext_info = data[@"image_msg_ext_info"];
        NSDictionary *app_msg_ext_info   = data[@"app_msg_ext_info"];
        
        NSMutableArray *msglist = [NSMutableArray array];

        // 1. 只有标题，没有跳转页面（字典 data 中只有 comm_msg_info 一个键值对，没有其他）
        if ([comm_msg_info[@"content"] length] > 0) {
            NSDictionary *data = @{
                @"title": comm_msg_info[@"content"]
            };
            [msglist addObject:data];
        }
        
        // 2. 只有图片（字典 data 中只有 comm_msg_info 和 image_msg_ext_info 两个键值对，没有其他）
        if (image_msg_ext_info) {
            NSDictionary *data = @{
                @"title": @"图片",
                @"content_url": image_msg_ext_info[@"cdn_url"]
            };
            [msglist addObject:data];
        }
        
        // 3. 可跳转的文章
        if (app_msg_ext_info) {
            // 可能 app_msg_ext_info 为空，但是 multi_app_msg_item_list 中有数据
            if ([app_msg_ext_info[@"content_url"] length]) {
                NSDictionary *data = @{
                    @"title": app_msg_ext_info[@"title"],
                    @"digest": app_msg_ext_info[@"digest"],
                    @"content_url": app_msg_ext_info[@"content_url"],
                    @"source_url": app_msg_ext_info[@"source_url"]
                };
                [msglist addObject:data];
            }

            NSArray *multi_app_msg_item_list = app_msg_ext_info[@"multi_app_msg_item_list"];
            if (multi_app_msg_item_list) {
                for (int i = 0; i < multi_app_msg_item_list.count; i++) {
                    NSDictionary *multi_app_msg_item = multi_app_msg_item_list[i];

                    NSDictionary *data = @{
                        @"title": multi_app_msg_item[@"title"],
                        @"digest": multi_app_msg_item[@"digest"],
                        @"content_url": multi_app_msg_item[@"content_url"],
                        @"source_url": multi_app_msg_item[@"source_url"]
                    };
                    [msglist addObject:data];
                }
            }
        }
    
        NSDictionary *json = @{
            @"id": comm_msg_info[@"id"],
            @"datetime": comm_msg_info[@"datetime"],
            @"msglist": msglist
        };
        [msglistArray addObject:json];
    }
    
    // 将数据写入指定目录
    NSString *path = [outputPath stringByAppendingPathComponent:@"data"];
    BOOL success = [msglistArray writeToURL:[NSURL fileURLWithPath:path] atomically:YES];
    if (success) {
        NSLog(@"%@", [NSString stringWithFormat:@"文件写入成功"]);
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"文件写入失败: %@", path]);
    }
}


@end
