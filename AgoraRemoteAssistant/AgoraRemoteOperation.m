//
//  AgoraRemoteOperation.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/12.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "AgoraRemoteOperation.h"
#import <Carbon/Carbon.h>

static const NSString *KeyOfType = @"cmdType";
static const NSString *KeyOfTimeStamp = @"timestamp";
static const NSString *KeyOfExtraInfo = @"param";

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
    NSInteger timeStamp = self.timeStamp;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                @(self.type), KeyOfType, @(timeStamp), KeyOfTimeStamp, nil];
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

+ (CGKeyCode)agoraKeyCodeToCGKeyCode:(unichar)keyCode {
    CGKeyCode cgKeyCode = USHRT_MAX;
    
    switch (keyCode) {
        case eKeyboardType_ESC:
            cgKeyCode = kVK_Escape;
            break;
            
        case eKeyboardType_F1:
            cgKeyCode = kVK_F1;
            break;
            
        case eKeyboardType_F2:
            cgKeyCode = kVK_F2;
            break;
            
        case eKeyboardType_F3:
            cgKeyCode = kVK_F3;
            break;
            
        case eKeyboardType_F4:
            cgKeyCode = kVK_F4;
            break;
            
        case eKeyboardType_F5:
            cgKeyCode = kVK_F5;
            break;
            
        case eKeyboardType_F6:
            cgKeyCode = kVK_F6;
            break;
            
        case eKeyboardType_F7:
            cgKeyCode = kVK_F7;
            break;
            
        case eKeyboardType_F8:
            cgKeyCode = kVK_F8;
            break;
            
        case eKeyboardType_F9:
            cgKeyCode = kVK_F9;
            break;
            
        case eKeyboardType_F10:
            cgKeyCode = kVK_F10;
            break;
            
        case eKeyboardType_F11:
            cgKeyCode = kVK_F11;
            break;
            
        case eKeyboardType_F12:
            cgKeyCode = kVK_F12;
            break;
            
        case eKeyboardType_Comma:
            cgKeyCode = kVK_ANSI_Grave;
            break;
            
        case eKeyboardType_Num1:
            cgKeyCode = kVK_ANSI_1;
            break;
            
        case eKeyboardType_Num2:
            cgKeyCode = kVK_ANSI_2;
            break;
            
        case eKeyboardType_Num3:
            cgKeyCode = kVK_ANSI_3;
            break;
            
        case eKeyboardType_Num4:
            cgKeyCode = kVK_ANSI_4;
            break;
            
        case eKeyboardType_Num5:
            cgKeyCode = kVK_ANSI_5;
            break;
            
        case eKeyboardType_Num6:
            cgKeyCode = kVK_ANSI_6;
            break;
            
        case eKeyboardType_Num7:
            cgKeyCode = kVK_ANSI_7;
            break;
            
        case eKeyboardType_Num8:
            cgKeyCode = kVK_ANSI_8;
            break;
            
        case eKeyboardType_Num9:
            cgKeyCode = kVK_ANSI_9;
            break;
            
        case eKeyboardType_Num0:
            cgKeyCode = kVK_ANSI_0;
            break;
            
        case eKeyboardType_Sub:
            cgKeyCode = kVK_ANSI_Minus;
            break;
            
        case eKeyboardType_Equ:
            cgKeyCode = kVK_ANSI_Equal;
            break;
            
        case eKeyboardType_BackSpace:
            cgKeyCode = kVK_Delete;
            break;
            
        case eKeyboardType_Tab:
            cgKeyCode = kVK_Tab;
            break;
            
        case eKeyboardType_Left_Parentheses:
            cgKeyCode = kVK_ANSI_LeftBracket;
            break;

        case eKeyboardType_Right_Parentheses:
            cgKeyCode = kVK_ANSI_RightBracket;
            break;
            
        case eKeyboardType_Right_Slash:
            cgKeyCode = kVK_ANSI_Backslash;
            break;
            
        case eKeyboardType_CapsLock:
            cgKeyCode = kVK_CapsLock;
            break;
            
        case eKeyboardType_colon:
            cgKeyCode = kVK_ANSI_Semicolon;
            break;
            
        case eKeyboardType_quotation:
            cgKeyCode = kVK_ANSI_Quote;
            break;
            
        case eKeyboardType_Enter:
            cgKeyCode = kVK_Return;
            break;
            
        case eKeyboardType_Left_Shift:
            cgKeyCode = kVK_Shift;
            break;
            
        case eKeyboardType_Left_brackets:
            cgKeyCode = kVK_ANSI_Comma;
            break;
            
        case eKeyboardType_Right_brackets:
            cgKeyCode = kVK_ANSI_Period;
            break;
            
        case eKeyboardType_Question:
            cgKeyCode = kVK_ANSI_Slash;
            break;
            
        case eKeyboardType_Right_Shift:
            cgKeyCode = kVK_RightShift;
            break;
            
        case eKeyboardType_Fn:
            cgKeyCode = kVK_Function;
            break;
            
        case eKeyboardType_Left_Ctrl:
            cgKeyCode = kVK_Control;
            break;
            
        case eKeyboardType_Ctrl:
            cgKeyCode = kVK_Control;
            break;
            
        case eKeyboardType_Left_Alt:
            cgKeyCode = kVK_Option;
            break;
            
        case eKeyboardType_Windows:
            cgKeyCode = kVK_Command;
            break;
            
        case eKeyboardType_Space:
            cgKeyCode = kVK_Space;
            break;
            
        case eKeyboardType_Right_Alt:
            cgKeyCode = kVK_RightOption;
            break;
            
        case eKeyboardType_Right_Ctrl:
            cgKeyCode = kVK_RightControl;
            break;

        case eKeyboardType_A:
            cgKeyCode = kVK_ANSI_A;
            break;
            
        case eKeyboardType_B:
            cgKeyCode = kVK_ANSI_B;
            break;
            
        case eKeyboardType_C:
            cgKeyCode = kVK_ANSI_C;
            break;
            
        case eKeyboardType_D:
            cgKeyCode = kVK_ANSI_D;
            break;
            
        case eKeyboardType_E:
            cgKeyCode = kVK_ANSI_E;
            break;
            
        case eKeyboardType_F:
            cgKeyCode = kVK_ANSI_F;
            break;
            
        case eKeyboardType_G:
            cgKeyCode = kVK_ANSI_G;
            break;
            
        case eKeyboardType_H:
            cgKeyCode = kVK_ANSI_H;
            break;
            
        case eKeyboardType_I:
            cgKeyCode = kVK_ANSI_I;
            break;
            
        case eKeyboardType_J:
            cgKeyCode = kVK_ANSI_J;
            break;
            
        case eKeyboardType_K:
            cgKeyCode = kVK_ANSI_K;
            break;
            
        case eKeyboardType_L:
            cgKeyCode = kVK_ANSI_L;
            break;
            
        case eKeyboardType_M:
            cgKeyCode = kVK_ANSI_M;
            break;
            
        case eKeyboardType_N:
            cgKeyCode = kVK_ANSI_N;
            break;
            
        case eKeyboardType_O:
            cgKeyCode = kVK_ANSI_O;
            break;
            
        case eKeyboardType_P:
            cgKeyCode = kVK_ANSI_P;
            break;
            
        case eKeyboardType_Q:
            cgKeyCode = kVK_ANSI_Q;
            break;
            
        case eKeyboardType_R:
            cgKeyCode = kVK_ANSI_R;
            break;
            
        case eKeyboardType_S:
            cgKeyCode = kVK_ANSI_S;
            break;
            
        case eKeyboardType_T:
            cgKeyCode = kVK_ANSI_T;
            break;
            
        case eKeyboardType_U:
            cgKeyCode = kVK_ANSI_U;
            break;
            
        case eKeyboardType_V:
            cgKeyCode = kVK_ANSI_V;
            break;
            
        case eKeyboardType_W:
            cgKeyCode = kVK_ANSI_W;
            break;
            
        case eKeyboardType_X:
            cgKeyCode = kVK_ANSI_X;
            break;
            
        case eKeyboardType_Y:
            cgKeyCode = kVK_ANSI_Y;
            break;
            
        case eKeyboardType_Z:
            cgKeyCode = kVK_ANSI_Z;
            break;
            
        case eKeyboardType_Insert:
            cgKeyCode = kVK_Help;
            break;
            
        case eKeyboardType_Delete:
            cgKeyCode = kVK_ForwardDelete;
            break;
            
        case eKeyboardType_Home:
            cgKeyCode = kVK_Home;
            break;
            
        case eKeyboardType_End:
            cgKeyCode = kVK_End;
            break;
            
        case eKeyboardType_PgUp:
            cgKeyCode = kVK_PageUp;
            break;
            
        case eKeyboardType_PgDn:
            cgKeyCode = kVK_PageDown;
            break;
            
        case eKeyboardType_Left_Direction:
            cgKeyCode = kVK_LeftArrow;
            break;
            
        case eKeyboardType_Up_Direction:
            cgKeyCode = kVK_UpArrow;
            break;
            
        case eKeyboardType_Down_Direction:
            cgKeyCode = kVK_DownArrow;
            break;
            
        case eKeyboardType_Right_Direction:
            cgKeyCode = kVK_RightArrow;
            break;
            
        default:
            break;
    }
    
    return cgKeyCode;
}

+ (unichar)cgKeyCodeToAgoraKeyCode:(CGKeyCode)cgKeyCode {
    unichar keyCode = USHRT_MAX;
    
    switch (cgKeyCode) {
        case kVK_Escape:
            keyCode = eKeyboardType_ESC;
            break;
            
        case kVK_F1:
            keyCode = eKeyboardType_F1;
            break;
            
        case kVK_F2:
            keyCode = eKeyboardType_F2;
            break;
            
        case kVK_F3:
            keyCode = eKeyboardType_F3;
            break;
            
        case kVK_F4:
            keyCode = eKeyboardType_F4;
            break;
            
        case kVK_F5:
            keyCode = eKeyboardType_F5;
            break;
            
        case kVK_F6:
            keyCode = eKeyboardType_F6;
            break;
            
        case kVK_F7:
            keyCode = eKeyboardType_F7;
            break;
            
        case kVK_F8:
            keyCode = eKeyboardType_F8;
            break;
            
        case kVK_F9:
            keyCode = eKeyboardType_F9;
            break;
            
        case kVK_F10:
            keyCode = eKeyboardType_F10;
            break;
            
        case kVK_F11:
            keyCode = eKeyboardType_F11;
            break;
            
        case kVK_F12:
            keyCode = eKeyboardType_F12;
            break;
            
        case kVK_ANSI_Grave:
            keyCode = eKeyboardType_Comma;
            break;
            
        case kVK_ANSI_1:
            keyCode = eKeyboardType_Num1;
            break;
            
        case kVK_ANSI_2:
            keyCode = eKeyboardType_Num2;
            break;
            
        case kVK_ANSI_3:
            keyCode = eKeyboardType_Num3;
            break;
            
        case kVK_ANSI_4:
            keyCode = eKeyboardType_Num4;
            break;
            
        case kVK_ANSI_5:
            keyCode = eKeyboardType_Num5;
            break;
            
        case kVK_ANSI_6:
            keyCode = eKeyboardType_Num6;
            break;
            
        case kVK_ANSI_7:
            keyCode = eKeyboardType_Num7;
            break;
            
        case kVK_ANSI_8:
            keyCode = eKeyboardType_Num8;
            break;
            
        case kVK_ANSI_9:
            keyCode = eKeyboardType_Num9;
            break;
            
        case kVK_ANSI_0:
            keyCode = eKeyboardType_Num0;
            break;
            
        case kVK_ANSI_Minus:
            keyCode = eKeyboardType_Sub;
            break;
            
        case kVK_ANSI_Equal:
            keyCode = eKeyboardType_Equ;
            break;
            
        case kVK_Delete:
            keyCode = eKeyboardType_BackSpace;
            break;
            
        case kVK_Tab:
            keyCode = eKeyboardType_Tab;
            break;
            
        case kVK_ANSI_LeftBracket:
            keyCode = eKeyboardType_Left_Parentheses;
            break;
            
        case kVK_ANSI_RightBracket:
            keyCode = eKeyboardType_Right_Parentheses;
            break;
            
        case kVK_ANSI_Backslash:
            keyCode = eKeyboardType_Right_Slash;
            break;
            
        case kVK_CapsLock:
            keyCode = eKeyboardType_CapsLock;
            break;
            
        case kVK_ANSI_Semicolon:
            keyCode = eKeyboardType_colon;
            break;
            
        case kVK_ANSI_Quote:
            keyCode = eKeyboardType_quotation;
            break;
            
        case kVK_Return:
            keyCode = eKeyboardType_Enter;
            break;
            
        case kVK_Shift:
            keyCode = eKeyboardType_Left_Shift;
            break;
            
        case kVK_ANSI_Comma:
            keyCode = eKeyboardType_Left_brackets;
            break;
            
        case kVK_ANSI_Period:
            keyCode = eKeyboardType_Right_brackets;
            break;
            
        case kVK_ANSI_Slash:
            keyCode = eKeyboardType_Question;
            break;
            
        case kVK_RightShift:
            keyCode = eKeyboardType_Right_Shift;
            break;
            
        case kVK_Function:
            keyCode = eKeyboardType_Fn;
            break;
            
        case kVK_Control:
            keyCode = eKeyboardType_Left_Ctrl;
            break;
            
        case kVK_Option:
            keyCode = eKeyboardType_Left_Alt;
            break;
            
        case kVK_Command:
            keyCode = eKeyboardType_Windows;
            break;
            
        case kVK_Space:
            keyCode = eKeyboardType_Space;
            break;
            
        case kVK_RightCommand:
            keyCode = eKeyboardType_Windows;
            break;
            
        case kVK_RightOption:
            keyCode = eKeyboardType_Right_Alt;
            break;
            
        case kVK_RightControl:
            keyCode = eKeyboardType_Right_Ctrl;
            break;
            
        case kVK_ANSI_A:
            keyCode = eKeyboardType_A;
            break;
            
        case kVK_ANSI_B:
            keyCode = eKeyboardType_B;
            break;
            
        case kVK_ANSI_C:
            keyCode = eKeyboardType_C;
            break;
            
        case kVK_ANSI_D:
            keyCode = eKeyboardType_D;
            break;
            
        case kVK_ANSI_E:
            keyCode = eKeyboardType_E;
            break;
            
        case kVK_ANSI_F:
            keyCode = eKeyboardType_F;
            break;
            
        case kVK_ANSI_G:
            keyCode = eKeyboardType_G;
            break;
            
        case kVK_ANSI_H:
            keyCode = eKeyboardType_H;
            break;
            
        case kVK_ANSI_I:
            keyCode = eKeyboardType_I;
            break;
            
        case kVK_ANSI_J:
            keyCode = eKeyboardType_J;
            break;
            
        case kVK_ANSI_K:
            keyCode = eKeyboardType_K;
            break;
            
        case kVK_ANSI_L:
            keyCode = eKeyboardType_L;
            break;
            
        case kVK_ANSI_M:
            keyCode = eKeyboardType_M;
            break;
            
        case kVK_ANSI_N:
            keyCode = eKeyboardType_N;
            break;
            
        case kVK_ANSI_O:
            keyCode = eKeyboardType_O;
            break;
            
        case kVK_ANSI_P:
            keyCode = eKeyboardType_P;
            break;
            
        case kVK_ANSI_Q:
            keyCode = eKeyboardType_Q;
            break;
            
        case kVK_ANSI_R:
            keyCode = eKeyboardType_R;
            break;
            
        case kVK_ANSI_S:
            keyCode = eKeyboardType_S;
            break;
            
        case kVK_ANSI_T:
            keyCode = eKeyboardType_T;
            break;
            
        case kVK_ANSI_U:
            keyCode = eKeyboardType_U;
            break;
            
        case kVK_ANSI_V:
            keyCode = eKeyboardType_V;
            break;
            
        case kVK_ANSI_W:
            keyCode = eKeyboardType_W;
            break;
            
        case kVK_ANSI_X:
            keyCode = eKeyboardType_X;
            break;
            
        case kVK_ANSI_Y:
            keyCode = eKeyboardType_Y;
            break;
            
        case kVK_ANSI_Z:
            keyCode = eKeyboardType_Z;
            break;
            
        case kVK_Help:
            keyCode = eKeyboardType_Insert;
            break;
            
        case kVK_ForwardDelete:
            keyCode = eKeyboardType_Delete;
            break;
            
        case kVK_Home:
            keyCode = eKeyboardType_Home;
            break;
            
        case kVK_End:
            keyCode = eKeyboardType_End;
            break;
            
        case kVK_PageUp:
            keyCode = eKeyboardType_PgUp;
            break;
            
        case kVK_PageDown:
            keyCode = eKeyboardType_PgDn;
            break;
            
        case kVK_LeftArrow:
            keyCode = eKeyboardType_Left_Direction;
            break;
            
        case kVK_UpArrow:
            keyCode = eKeyboardType_Up_Direction;
            break;
            
        case kVK_DownArrow:
            keyCode = eKeyboardType_Down_Direction;
            break;
            
        case kVK_RightArrow:
            keyCode = eKeyboardType_Right_Direction;
            break;
            
        default:
            break;
    }
    
    return keyCode;
}

@end
