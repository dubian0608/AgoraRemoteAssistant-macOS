//
//  AgoraRemoteOperation.h
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/12.
//  Copyright © 2018 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AgoraRemoteOperationType) {
    AgoraRemoteOperationTypeStartAssistant = 1,
    AgoraRemoteOperationTypeStopAssistant = 2,
    AgoraRemoteOperationTypeMouseLeftButtonDown = 100,
    AgoraRemoteOperationTypeMouseLeftButtonUp = 101,
    AgoraRemoteOperationTypeMouseLeftButtonDoubleClick = 102,
    AgoraRemoteOperationTypeMouseRightButtonDown = 103,
    AgoraRemoteOperationTypeMouseRightButtonUp = 104,
    AgoraRemoteOperationTypeMouseRightButtonDoubleClick = 105,
    AgoraRemoteOperationTypeMouseMove = 106,
    AgoraRemoteOperationTypeMouseWheel = 107,
    AgoraRemoteOperationTypeKeyboardKeyPress = 1000,
    AgoraRemoteOperationTypeKeyboardKeyDown = 1001,
    AgoraRemoteOperationTypeKeyboardKeyUp = 1002,
    AgoraRemoteOperationTypeKeyboardCut = 1003,
    AgoraRemoteOperationTypeKeyboardCopy = 1004,
    AgoraRemoteOperationTypeKeyboardPaste = 1005,
};

@interface AgoraRemoteOperation : NSObject

@property (readonly, assign) AgoraRemoteOperationType type;
@property (readonly, assign) NSTimeInterval timeStamp;
@property (nullable, readonly, copy) NSDictionary *extraInfo;

- (instancetype)initWithType:(AgoraRemoteOperationType)type timeStamp:(NSTimeInterval)timeStamp extraInfo:(NSDictionary *)info;
- (instancetype)initWithDic:(NSDictionary *)dic;

- (NSDictionary *)convertToDic;
- (NSString *)convertToJsonString;

+ (NSArray<AgoraRemoteOperation *> *)parseJsonString:(NSString *)jsonString;
+ (NSString *)convertArrayToJsonString:(NSArray<AgoraRemoteOperation *> *)commands;

@end
