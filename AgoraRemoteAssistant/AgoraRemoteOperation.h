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
    eKeyboardType_ESC = 1,
    eKeyboardType_F1 = 2,
    eKeyboardType_F2 = 3,
    eKeyboardType_F3 = 4,
    eKeyboardType_F4 = 5,
    eKeyboardType_F5 = 6,
    eKeyboardType_F6 = 7,
    eKeyboardType_F7 = 8,
    eKeyboardType_F8 = 9,
    eKeyboardType_F9 = 10,
    eKeyboardType_F10 = 11,
    eKeyboardType_F11 = 12,
    eKeyboardType_F12 = 13,
    eKeyboardType_Home = 14,
    eKeyboardType_End = 15,
    eKeyboardType_Insert = 16,
    eKeyboardType_Delete = 17,
    eKeyboardType_Comma = 18, // ~,`
    eKeyboardType_Num0 = 19,
    eKeyboardType_Num1 = 20,
    eKeyboardType_Num2 = 21,
    eKeyboardType_Num3 = 22,
    eKeyboardType_Num4 = 23,
    eKeyboardType_Num5 = 24,
    eKeyboardType_Num6 = 25,
    eKeyboardType_Num7 = 26,
    eKeyboardType_Num8 = 27,
    eKeyboardType_Num9 = 28,
    eKeyboardType_Sub = 29, // _,-
    eKeyboardType_Equ = 30, // +,=
    eKeyboardType_BackSpace = 31,
    eKeyboardType_Tab = 32,
    eKeyboardType_Q = 33,
    eKeyboardType_W = 34,
    eKeyboardType_E = 35,
    eKeyboardType_R = 36,
    eKeyboardType_T = 37,
    eKeyboardType_Y = 38,
    eKeyboardType_U = 39,
    eKeyboardType_I = 40,
    eKeyboardType_O = 41,
    eKeyboardType_P = 42,
    eKeyboardType_Left_Parentheses = 43, // {,[
    eKeyboardType_Right_Parentheses = 44, // },]
    eKeyboardType_Right_Slash = 45, // \,|
    eKeyboardType_CapsLock = 46, // uppercase and lowercase switch
    eKeyboardType_A = 47,
    eKeyboardType_S = 48,
    eKeyboardType_D = 49,
    eKeyboardType_F = 50,
    eKeyboardType_G = 51,
    eKeyboardType_H = 52,
    eKeyboardType_J = 53,
    eKeyboardType_K = 54,
    eKeyboardType_L = 55,
    eKeyboardType_colon = 56, // ;,:
    eKeyboardType_quotation = 57, // ',"
    eKeyboardType_Enter = 58,
    eKeyboardType_Left_Shift = 59,
    eKeyboardType_Z = 60,
    eKeyboardType_X = 61,
    eKeyboardType_C = 62,
    eKeyboardType_V = 63,
    eKeyboardType_B = 64,
    eKeyboardType_N = 65,
    eKeyboardType_M = 66,
    eKeyboardType_Left_brackets = 67, // <,,
    eKeyboardType_Right_brackets = 68, // >,.
    eKeyboardType_Question = 69, // ?,/
    eKeyboardType_Right_Shift = 70,
    eKeyboardType_Fn = 71,
    eKeyboardType_Left_Ctrl = 72,
    eKeyboardType_Ctrl = 73,
    eKeyboardType_Windows = 74,
    eKeyboardType_Left_Alt = 75,
    eKeyboardType_Space = 76,
    eKeyboardType_Right_Alt = 77,
    eKeyboardType_Right_Ctrl = 78,
    eKeyboardType_PgUp = 79,
    eKeyboardType_Left_Direction = 80,
    eKeyboardType_Up_Direction = 81,
    eKeyboardType_Down_Direction = 82,
    eKeyboardType_PgDn = 83,
    eKeyboardType_Right_Direction = 84,
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
