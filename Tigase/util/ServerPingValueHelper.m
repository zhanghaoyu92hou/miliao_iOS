//
//  ServerPingValueHelper.m
//  Tigase
//
//  Created by 齐科 on 2019/10/9.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "ServerPingValueHelper.h"

@implementation ServerPingValueHelper
+ (void)getCurrentXmppServerPingValue:(void (^)(NSDictionary * _Nonnull))pingBlock {
     NSString *hostUrl = [NSString stringWithFormat:@"http://%@:9090", g_config.XMPPHost];
    [self getPingValuesWithUrl:hostUrl host:g_config.XMPPHost serverPingBlock:^(NSDictionary *pingDic) {
        if (pingBlock) {
            pingBlock(pingDic);
        }
    }];
}
+ (void)getNodesServerPingValue:(void (^)(NSDictionary * _Nonnull))pingBlock {
    NSMutableDictionary *mutDic = [NSMutableDictionary new];
    for (int i = 0; i < g_config.nodesInfoList.count; i++) {
        NSDictionary *dict = [g_config.nodesInfoList objectAtIndex:0];
        NSString *xmpphost = [NSString stringWithFormat:@"%@",dict[@"nodeIp"]];
        NSString *port = [NSString stringWithFormat:@"%@",dict[@"nodePort"]];
        NSString *urlString = [NSString stringWithFormat:@"http://%@:%@", xmpphost, port];
        [self getPingValuesWithUrl:urlString host:xmpphost serverPingBlock:^(NSDictionary *pingDic) {
            [mutDic setObject:[pingDic allValues][0] forKey:[pingDic allKeys][0]];
            if (i == (g_config.nodesInfoList.count - 1)) {
                if (pingBlock) {
                    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:mutDic];
                    pingBlock(dic);
                }
            }
        }];
    }
}
+ (void)getPingValuesWithUrl:(NSString *)url host:(NSString *)host serverPingBlock:(void (^) (NSDictionary *pingDic))pingBlock {
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [manger GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (task.response && [task.response isKindOfClass:NSHTTPURLResponse.class]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200) {
                double respondTime = (CFAbsoluteTimeGetCurrent() - startTime);
                NSString *timeInterval = [NSString stringWithFormat:@"%0.3f",respondTime*1000];
                if (pingBlock) {
                    pingBlock(@{host:timeInterval});
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (task.response && [task.response isKindOfClass:NSHTTPURLResponse.class]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200) {
                double respondTime = (CFAbsoluteTimeGetCurrent() - startTime);
                NSString *timeInterval = [NSString stringWithFormat:@"%0.3f",respondTime*1000];
                if (pingBlock) {
                    pingBlock(@{host:timeInterval});
                }
            }
        }
    }];
}
@end
