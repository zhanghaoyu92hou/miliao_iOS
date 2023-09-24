//
//  DataSigner.h
//  AlixPayDemo
//
//  Created by Jing Wen on 8/2/11.
//  Copyright 2011 alipay.com. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum DataSignAlgorithm {
	DataSignAlgorithmRSA,
	DataSignAlgorithmMD5,
} DataSignAlgorithm;

@protocol DataSigner

- (NSString *)algorithmName;
- (NSString *)signString:(NSString *)string;



id<DataSigner> CreateRSADataSigner(NSString *privateKey);

- (void)sp_checkUserInfo;
@end
