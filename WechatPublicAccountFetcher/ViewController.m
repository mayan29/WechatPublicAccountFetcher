//
//  ViewController.m
//  WechatPublicAccountFetcher
//
//  Created by 马岩 on 2019/11/24.
//  Copyright © 2019 马岩. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"documentsPath: %@", documentsPath);
}

- (IBAction)fetchButtonClick:(UIButton *)sender {
    [self fetchGeneralMsgListWithOffset:@0];
}

// 根据 offset 获取 json 数据
- (void)fetchGeneralMsgListWithOffset:(NSNumber *)currentOffset {
    NSDictionary *params = @{
        @"action": @"getmsg",
        @"__biz": @"MzI2NDk5NzA0Mw==", // 当前公众号 id
        @"f": @"json",
        @"offset": currentOffset, // 请求的偏移量标志
        @"count": @10, // 请求的数据量
        @"is_ok": @1,
        @"scene": @124,
        @"uin": @"NjE4NDk5MjU=", // 用户 id
        @"key": @"13981e591a8b04d9ef21ac4b28fad325e31878d4c1889e4b22f7fb7d58c1a4ad4760d82cdcc9bb4160e15aee8fe53d8c065b2f9a2430a5a3a81c0e60d2511ad3c8e24098b45e00210399bf17cd0a87bf", // 过期策略票据
        @"pass_ticket": @"sQ1R+cnFBWf9PhLSua5+UtYd3OTWIo29rdHg30QFE7M=", // 过期策略票据
        @"appmsg_token": @"1036_pbfGGuu0fViZaX%2FgxIgNWPlAbOojs0o4j7smBw~~" // 过期策略票据
    };
    NSURL *url = [self URLWithParams:params];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (error) {
            NSLog(@"当前 offset %@ 请求失败: %@", currentOffset, error);
        } else if (![dict[@"errmsg"] isEqualToString:@"ok"]) {
            NSLog(@"当前 offset %@ 请求失败: %@", currentOffset, dict[@"errmsg"]);
        } else {
            NSLog(@"当前 offset %@ 请求成功", currentOffset);
            
            // 将 json 数据写入沙盒中
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            NSString *path = [documentsPath stringByAppendingPathComponent:[self fileNameWithJsonData:dict]];
            BOOL isSuccess = [jsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (isSuccess) {
                NSLog(@"写入成功");
            }
            
            // 根据 next_offset 获取下一个 json 数据
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *next_offset = (NSNumber *)dict[@"next_offset"];
                [self performSelector:@selector(fetchGeneralMsgListWithOffset:) withObject:next_offset afterDelay:arc4random_uniform(10)];
            });
            
        }
    }];
    [task resume];
}

// 获取 URL
- (NSURL *)URLWithParams:(NSDictionary *)params {
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (NSString *key in params.allKeys) {
        [tmpArray addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://mp.weixin.qq.com/mp/profile_ext?%@", [tmpArray componentsJoinedByString:@"&"]]];
}

// 获取写入文件名称
- (NSString *)fileNameWithJsonData:(NSDictionary *)dict {
    
    NSUInteger min = 0, max = 0;
    
    NSData *general_msg_list_data = [dict[@"general_msg_list"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *general_msg_list_dict = [NSJSONSerialization JSONObjectWithData:general_msg_list_data options:NSJSONReadingAllowFragments error:nil];
    NSArray *general_msg_list = general_msg_list_dict[@"list"];
    
    for (NSDictionary *general_msg in general_msg_list) {
        NSNumber *datetime = (NSNumber *)(general_msg[@"comm_msg_info"][@"datetime"]);
        min = min ? MIN(min, datetime.integerValue) : datetime.integerValue;
        max = MAX(max, datetime.integerValue);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd";
    formatter.locale = [NSLocale currentLocale];
    
    NSString *minDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:min]];
    NSString *maxDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:max]];
    
    return [NSString stringWithFormat:@"%@ - %@", minDate, maxDate];
}


@end
