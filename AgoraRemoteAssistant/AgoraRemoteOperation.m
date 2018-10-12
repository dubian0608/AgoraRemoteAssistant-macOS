//
//  AgoraRemoteOperation.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/12.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "AgoraRemoteOperation.h"

static const NSString *KeyOfType = @"nCmdType";
static const NSString *KeyOfTimeStamp = @"nTimeStamp";
static const NSString *KeyOfExtraInfo = @"EventParam";

@implementation AgoraRemoteOperation

- (instancetype)initWithType:(AgoraRemoteOperationType)type timeStamp:(NSTimeInterval)timeStamp extraInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        _type = type;
        _timeStamp = timeStamp;
        _extraInfo = [info copy];
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _type = [dic[KeyOfType] integerValue];
        _timeStamp = [dic[KeyOfTimeStamp] doubleValue];
        _extraInfo = [dic[KeyOfExtraInfo] copy];
    }
    return self;
}

- (NSDictionary *)convertToDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                @(self.type), KeyOfType, @(self.timeStamp), KeyOfTimeStamp, nil];
    if (self.extraInfo) {
        dic[KeyOfExtraInfo] = self.extraInfo;
    }
    return dic;
}

- (NSString *)convertToJsonString {
    NSDictionary *dic = [self convertToDic];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return nil;
    }
}

+ (NSArray<AgoraRemoteOperation *> *)parseJsonString:(NSString *)jsonString {
    if (jsonString.length == 0) {
        return nil;
    }

    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        AgoraRemoteOperation *operation = [[self alloc] initWithDic:obj];
        return @[operation];
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *operations = [NSMutableArray arrayWithCapacity:[obj count]];
        for (NSDictionary *dic in obj) {
            AgoraRemoteOperation *operation = [[self alloc] initWithDic:dic];
            [operations addObject:operation];
        }
        return operations;
    }
    else {
        return nil;
    }
}

+ (NSString *)convertArrayToJsonString:(NSArray<AgoraRemoteOperation *> *)operations {
    NSMutableArray *dicArray = [NSMutableArray arrayWithCapacity:[operations count]];
    for (AgoraRemoteOperation *operation in operations) {
        [dicArray addObject:[operation convertToDic]];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicArray options:0 error:nil];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return nil;
    }
}

@end
