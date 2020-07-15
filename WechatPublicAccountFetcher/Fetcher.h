//
//  Fetcher.h
//  WechatPublicAccountFetcher
//
//  Created by mayan on 2020/7/15.
//  Copyright © 2020 马岩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Fetcher : NSObject

+ (instancetype)shareInstance;

- (void)fetchGeneralMsgListWithOffset:(NSNumber *)currentOffset;


@end

NS_ASSUME_NONNULL_END
