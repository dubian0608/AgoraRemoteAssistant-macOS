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

enum KeyboardTransferType {
    eKeyboardType_NULL = 0,
    eKeyboardType_ESC,
    eKeyboardType_F1,
    eKeyboardType_F2,
    eKeyboardType_F3,
    eKeyboardType_F4,
    eKeyboardType_F5,
    eKeyboardType_F6,
    eKeyboardType_F7,
    eKeyboardType_F8,
    eKeyboardType_F9,
    eKeyboardType_F10,
    eKeyboardType_F11,
    eKeyboardType_F12,
    eKeyboardType_Home,
    eKeyboardType_End,
    eKeyboardType_Insert,
    eKeyboardType_Delete,
    eKeyboardType_Comma, // ~,`
    eKeyboardType_Num0,
    eKeyboardType_Num1,
    eKeyboardType_Num2,
    eKeyboardType_Num3,
    eKeyboardType_Num4,
    eKeyboardType_Num5,
    eKeyboardType_Num6,
    eKeyboardType_Num7,
    eKeyboardType_Num8,
    eKeyboardType_Num9,
    eKeyboardType_Sub, // _,-
    eKeyboardType_Equ, // +,=
    eKeyboardType_BackSpace,
    eKeyboardType_Tab,
    eKeyboardType_Q,
    eKeyboardType_W,
    eKeyboardType_E,
    eKeyboardType_R,
    eKeyboardType_T,
    eKeyboardType_Y,
    eKeyboardType_U,
    eKeyboardType_I,
    eKeyboardType_O,
    eKeyboardType_P,
    eKeyboardType_Left_Parentheses, // {,[
    eKeyboardType_Right_Parentheses, // },]
    eKeyboardType_Right_Slash, // \,|
    eKeyboardType_CapsLock, // uppercase and lowercase switch
    eKeyboardType_A,
    eKeyboardType_S,
    eKeyboardType_D,
    eKeyboardType_F,
    eKeyboardType_G,
    eKeyboardType_H,
    eKeyboardType_J,
    eKeyboardType_K,
    eKeyboardType_L,
    eKeyboardType_colon, // ;,:
    eKeyboardType_quotation, // ',"
    eKeyboardType_Enter,
    eKeyboardType_Left_Shift,
    eKeyboardType_Z,
    eKeyboardType_X,
    eKeyboardType_C,
    eKeyboardType_V,
    eKeyboardType_B,
    eKeyboardType_N,
    eKeyboardType_M,
    eKeyboardType_Left_brackets, // <,,
    eKeyboardType_Right_brackets, // >,.
    eKeyboardType_Question, // ?,/
    eKeyboardType_Right_Shift,
    eKeyboardType_Fn,
    eKeyboardType_Left_Ctrl,
    eKeyboardType_Ctrl,
    eKeyboardType_Windows,
    eKeyboardType_Left_Alt,
    eKeyboardType_Space,
    eKeyboardType_Right_Alt,
    eKeyboardType_Right_Ctrl,
    eKeyboardType_PgUp,
    eKeyboardType_Left_Direction,
    eKeyboardType_Up_Direction,
    eKeyboardType_Down_Direction,
    eKeyboardType_PgDn,
    eKeyboardType_Right_Direction,
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

+ (CGKeyCode)agoraKeyCodeToCGKeyCode:(unichar)keyCode;
+ (unichar)cgKeyCodeToAgoraKeyCode:(CGKeyCode)CGKeyCode;

@end
