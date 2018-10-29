//
//  MainViewController.m
//  AgoraRemoteAssistant
//
//  Created by suleyu on 2018/9/10.
//  Copyright © 2018 Agora. All rights reserved.
//

#import "MainViewController.h"
#import "AgoraRemoteAssistantCenter.h"

@interface MainViewController() <NSTableViewDataSource>
{
    id remoteUserListUpdatedObserver;
}
@property (weak) IBOutlet NSTextField *channelTextField;
@property (weak) IBOutlet NSTextField *uidTextField;
@property (weak) IBOutlet NSButton *joinButton;
@property (weak) IBOutlet NSTableView *remoteUsersTableView;
@property (weak) IBOutlet NSButton *remoteAssistantButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.channelTextField.stringValue = [AgoraRemoteAssistantCenter sharedInstance].channel ? [AgoraRemoteAssistantCenter sharedInstance].channel : @"";
    if ([AgoraRemoteAssistantCenter sharedInstance].localUid == 0) {
        self.uidTextField.stringValue = @"";
    }
    else {
        self.uidTextField.stringValue = [NSString stringWithFormat:@"%ld", [AgoraRemoteAssistantCenter sharedInstance].localUid];
    }
    if ([AgoraRemoteAssistantCenter sharedInstance].joined) {
        self.channelTextField.enabled = NO;
        self.uidTextField.enabled = NO;
        self.joinButton.title = @"Leave";
        self.remoteAssistantButton.enabled = [AgoraRemoteAssistantCenter sharedInstance].remoteUsers.count > 0;
    }
    else {
        self.channelTextField.enabled = YES;
        self.uidTextField.enabled = YES;
        self.joinButton.title = @"Join";
        self.remoteAssistantButton.enabled = NO;
    }
    
    [self.remoteUsersTableView reloadData];
    
    if ([AgoraRemoteAssistantCenter sharedInstance].selectedRemoteUser) {
        NSUInteger selectedRow = [[AgoraRemoteAssistantCenter sharedInstance].remoteUsers indexOfObject:@([AgoraRemoteAssistantCenter sharedInstance].selectedRemoteUser)];
        if (selectedRow != NSNotFound) {
            [self.remoteUsersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
        }
    }
    
    remoteUserListUpdatedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationRemoteUserListUpdated
                                                                                      object:nil
                                                                                       queue:[NSOperationQueue mainQueue]
                                                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                                                      [self.remoteUsersTableView reloadData];
                                                                                      self.remoteAssistantButton.enabled = [AgoraRemoteAssistantCenter sharedInstance].remoteUsers.count > 0;
                                                                                  }];
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    [[NSNotificationCenter defaultCenter] removeObserver:remoteUserListUpdatedObserver];
    remoteUserListUpdatedObserver = nil;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"startRemoteAssistant"]) {
        NSUInteger selectedRow = self.remoteUsersTableView.selectedRow;
        if (selectedRow == NSUIntegerMax) {
            [AgoraRemoteAssistantCenter sharedInstance].selectedRemoteUser = [[AgoraRemoteAssistantCenter sharedInstance].remoteUsers.firstObject integerValue];
        }
        else {
            [AgoraRemoteAssistantCenter sharedInstance].selectedRemoteUser = [[AgoraRemoteAssistantCenter sharedInstance].remoteUsers[selectedRow] integerValue];
        }
    }
}

- (IBAction)joinButtonClicked:(NSButton *)sender {
    if ([AgoraRemoteAssistantCenter sharedInstance].joined) {
        [[AgoraRemoteAssistantCenter sharedInstance] leave];
        
        self.channelTextField.enabled = YES;
        self.uidTextField.enabled = YES;
        self.joinButton.title = @"Join";
        self.remoteAssistantButton.enabled = NO;
        [self.remoteUsersTableView reloadData];
    }
    else {
        [AgoraRemoteAssistantCenter sharedInstance].channel = self.channelTextField.stringValue;
        [AgoraRemoteAssistantCenter sharedInstance].localUid = [self.uidTextField.stringValue integerValue];
        if ([[AgoraRemoteAssistantCenter sharedInstance] join]) {
            self.channelTextField.enabled = NO;
            self.uidTextField.enabled = NO;
            self.joinButton.title = @"Leave";
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [AgoraRemoteAssistantCenter sharedInstance].remoteUsers.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= [AgoraRemoteAssistantCenter sharedInstance].remoteUsers.count) {
        return nil;
    }
    NSNumber *remoteUser = [AgoraRemoteAssistantCenter sharedInstance].remoteUsers[row];
    return [NSString stringWithFormat:@"%ld", [remoteUser integerValue]];
}

@end
