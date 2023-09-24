//
//  WH_JXUserObject+jsonModel.m
//  Tigase
//
//  Created by 齐科 on 2019/9/23.
//  Copyright © 2019 Reese. All rights reserved.
//

#import "WH_JXUserObject+jsonModel.h"

@implementation WH_JXUserObject (jsonModel)
- (void)objectFromDocumentDictionary:(NSDictionary *)userInfo {
    [self objectFromServerDictionary:userInfo];
    
    //服务器数据中不含password
    self.password = userInfo[@"password"] ?: @"";
}
- (void)objectFromServerDictionary:(NSDictionary *)userInfo {
    NSString *temp = [NSString stringWithFormat:@"%@", userInfo[@"userId"] ?: @""];
    self.userId = temp;
    self.account = userInfo[@"account"] ?: @"";
    self.active = userInfo[@"active"] ?: @"";
    self.anonymous = userInfo[@"anonymous"] ?: @"";
    self.areaCode = userInfo[@"areaCode"] ?: @"";
    self.areaId = userInfo[@"areaId"] ?: @"";
    self.attCount = userInfo[@"attCount"] ?: @"";
    NSString *birthdayStr = userInfo[@"birthday"] ?: @"";
    self.birthday = birthdayStr ? [NSDate dateWithTimeIntervalSince1970:[birthdayStr longLongValue]] : [NSDate date];
    self.carrier = userInfo[@"carrier"] ?: @"";
    self.cityId = userInfo[@"cityId"] ?: @"";
    self.countryId = userInfo[@"countryId"] ?: @"";
    self.timeCreate = userInfo[@"createTime"] ?: @"";
    self.describe = userInfo[@"description"] ?: @"";
    self.fansCount = userInfo[@"fansCount"] ?: @"";
    self.friendCount = userInfo[@"friendsCount"] ?: @"";
    self.idCard = userInfo[@"idcard"] ?: @"";
    self.idCardUrl = userInfo[@"idcardUrl"] ?: @"";
    self.isAddFirend = userInfo[@"isAddFirend"] ?: @"";
    self.isAuth = userInfo[@"isAuth"] ? [userInfo[@"isAuth"] boolValue]: NO;
    self.isCreateRoom = userInfo[@"isCreateRoom"] ?: @"";
    self.isPasuse = userInfo[@"isPasuse"] ?: @"";
    self.level = userInfo[@"level"] ?: @(0);
    self.longitude = userInfo[@"loc"][@"lng"] ?: @"";
    self.latitude = userInfo[@"loc"][@"lat"] ?: @"";
    self.loginIp = userInfo[@"loginIp"] ?: @"";
    self.modifyTime = userInfo[@"modifyTime"] ?: @"";
    self.msgsNew = userInfo[@"msgNum"] ?: @"";
    self.myInviteCode = userInfo[@"myInviteCode"] ?: @"";
    self.name = userInfo[@"name"] ?: @"";
    
//   self.remarkName = userInfo[@""] ?: @"";
    self.userNickname = userInfo[@"nickname"] ?: Localized(@"JX_NickName");
    self.userDescription = userInfo[@"desc"] ?: Localized(@"JX_GiftText");
    self.num = userInfo[@"num"] ?: @(0);
    self.offlineNoPushMsg = userInfo[@"offlineNoPushMsg"] ?: @"";
    self.onlinestate = userInfo[@"onlinestate"] ?: @(0);
    self.payPassword = userInfo[@"payPassword"] ?: @"";
    self.phone = userInfo[@"phone"] ?: @"";
    self.phoneToLocation = userInfo[@"phoneToLocation"] ?: @"";
    self.provinceId = userInfo[@"provinceId"] ?: @"";
    self.regInviteCode = userInfo[@"regInviteCode"] ?: @"";
    self.role = userInfo[@"role"] ?: @[];
    self.serInviteCode = userInfo[@"serInviteCode"] ?: @"";
    self.setAccountCount = userInfo[@"setAccountCount"] ?: @"";

    /*-----Friend Begin------*/
    self.isBeenBlack = userInfo[@"friends"][@"blacklist"];
    self.remarkName = userInfo[@"friends"][@"remarkName"];
    /*-----Friend End------*/
    
     /*------------Settings  Begin-----------*/
    self.allowAtt = userInfo[@"settings"][@"allowAtt"] ?: @"";
    self.allowGreet = userInfo[@"settings"][@"allowGreet"] ?: @"";
    if (IS_ChatMsgSyncForever_Open) {
        self.chatSyncTimeLen = userInfo[@"settings"][@"chatSyncTimeLen"] ?: @"";
    }
    
    self.chatRecordTimeOut = userInfo[@"settings"][@"chatRecordTimeOut"] ?: @"";
    self.closeTelephoneFind = userInfo[@"settings"][@"closeTelephoneFind"] ?: @"";
    self.friendFromList = userInfo[@"settings"][@"friendFromList"] ?: @"";
    self.friendsVerify = userInfo[@"settings"][@"friendsVerify"] ?: @"";
    self.isEncrypt = userInfo[@"settings"][@"isEncrypt"] ?: @"";
    self.isKeepalive = userInfo[@"settings"][@"isKeepalive"] ? [userInfo[@"settings"][@"isKeepalive"] boolValue] : NO;
    self.isTyping = userInfo[@"settings"][@"isTyping"] ?: @"";
    self.isUseGoogleMap = userInfo[@"settings"][@"isUseGoogleMap"] ?: @"";
    self.isVibration = userInfo[@"settings"][@"isVibration"] ?: @"";
    self.multipleDevices = userInfo[@"settings"][@"multipleDevices"] ?: @"";
    self.nameSearch = userInfo[@"settings"][@"nameSearch"] ?: @"";
    self.openService = userInfo[@"settings"][@"openService"] ? [userInfo[@"settings"][@"openService"] boolValue] : NO;
    self.phoneSearch = userInfo[@"settings"][@"phoneSearch"] ?: @"";
    self.showLastLoginTime = userInfo[@"settings"][@"showLastLoginTime"] ? [userInfo[@"settings"][@"showLastLoginTime"] boolValue]: NO;
    self.showTelephone = userInfo[@"settings"][@"showTelephone"] ? [userInfo[@"settings"][@"showTelephone"] boolValue] : NO;
    /*------------Settings  End-------------*/
    
    self.sex = userInfo[@"sex"] ?: @"";
    self.lastLoginTime = userInfo[@"showLastLoginTime"] ?: @"";
    self.status = userInfo[@"status"] ?: @"";
    self.telephone = userInfo[@"telephone"] ?: @"";
    self.totalConsume = userInfo[@"totalConsume"] ?: @"";
    self.totalRecharge = userInfo[@"totalRecharge"] ?: @"";
    self.userKey = userInfo[@"userKey"] ?: @"";
    self.userType = userInfo[@"userType"] ?: @"";
    self.vip = userInfo[@"vip"] ?: @"";
    self.questions  = userInfo[@"questions"] ?: @[];
    self.redPacketVip = userInfo[@"redPacketVip"] ?: @(0);
}
- (NSDictionary *)objectToDictionary {
    NSMutableDictionary *mutDic = [NSMutableDictionary new];
    [mutDic setObject:self.userId ?: @"" forKey:@"userId"];
    [mutDic setObject:self.password ?: @"" forKey:@"password"];
    [mutDic setObject:self.account ?: @"" forKey:@"account"];
    [mutDic setObject:self.active ?: @"" forKey:@"active"];
    [mutDic setObject:self.anonymous ?: @"" forKey:@"anonymous"];
    [mutDic setObject:self.areaCode ?: @"" forKey:@"areaCode"];
    [mutDic setObject:self.areaId ?: @"" forKey:@"areaId"];
    [mutDic setObject:self.attCount ?: @"" forKey:@"attCount"];
    NSTimeInterval interval = [self.birthday ?: [NSDate date] timeIntervalSince1970];
    NSString *timeStamp = [NSString stringWithFormat:@"%i", (int)interval];
    [mutDic setObject:timeStamp forKey:@"birthday"];
    [mutDic setObject:self.carrier ?: @"" forKey:@"carrier"];
    [mutDic setObject:self.cityId ?: @"" forKey:@"cityId"];
    [mutDic setObject:self.countryId ?: @"" forKey:@"countryId"];
    [mutDic setObject:self.timeCreate ?: @"" forKey:@"timeCreate"];
    [mutDic setObject:self.describe ?: @"" forKey:@"describe"];
    [mutDic setObject:self.fansCount ?: @"" forKey:@"fansCount"];
    [mutDic setObject:self.friendCount ?: @"" forKey:@"friendCount"];
    [mutDic setObject:self.idCard ?: @"" forKey:@"idCard"];
    [mutDic setObject:self.idCardUrl ?: @"" forKey:@"idCardUrl"];
    [mutDic setObject:self.isAddFirend ?: @"" forKey:@"isAddFirend"];
    [mutDic setObject:[NSNumber numberWithBool:self.isAuth] forKey:@"isAuth"];
    [mutDic setObject:self.isCreateRoom ?: @"" forKey:@"isCreateRoom"];
    [mutDic setObject:self.isPasuse ?: @"" forKey:@"isPasuse"];
    
    /*-----------Location Begin------*/
    NSDictionary *loc = @{@"lat":self.latitude?:@"", @"lng":self.longitude?:@""};
    [mutDic setObject:loc forKey:@"loc"];
    /* ---------Location End------------*/
    
    
    /*-----Friend Begin------*/
    NSDictionary *friendsDic = @{@"blacklist":self.isBeenBlack?:@(0), @"remarkName": self.remarkName?:@""};
    [mutDic setObject:friendsDic forKey:@"friends"];
    /*-----Friend End------*/
    
    
    [mutDic setObject:self.loginIp ?: @"" forKey:@"loginIp"];
    [mutDic setObject:self.modifyTime ?: @"" forKey:@"modifyTime"];
    [mutDic setObject:self.msgsNew ?: @"" forKey:@"msgNum"];
    [mutDic setObject:self.myInviteCode ?: @"" forKey:@"myInviteCode"];
    [mutDic setObject:self.name ?: @"" forKey:@"name"];
    
    [mutDic setObject:self.userNickname ?: @"" forKey:@"nickname"];
    [mutDic setObject:self.userDescription forKey:@"desc"];
    [mutDic setObject:self.num ?: @"" forKey:@"num"];
    [mutDic setObject:self.offlineNoPushMsg ?: @"" forKey:@"offlineNoPushMsg"];
    [mutDic setObject:self.onlinestate ?: @"" forKey:@"onlinestate"];
    [mutDic setObject:self.payPassword ?: @"" forKey:@"payPassword"];
    [mutDic setObject:self.phone ?: @"" forKey:@"phone"];
    [mutDic setObject:self.phoneToLocation ?: @"" forKey:@"phoneToLocation"];
    [mutDic setObject:self.provinceId ?: @"" forKey:@"provinceId"];
    [mutDic setObject:self.regInviteCode ?: @"" forKey:@"regInviteCode"];
    [mutDic setObject:self.role ?: @[] forKey:@"role"];
    [mutDic setObject:self.serInviteCode ?: @"" forKey:@"serInviteCode"];
    [mutDic setObject:self.setAccountCount ?: @"" forKey:@"setAccountCount"];
    
    /*------------Settings-------------*/
    NSDictionary *settingsDic = @{@"allowAtt":self.allowAtt ?: @"", @"allowGreet":self.allowGreet ?: @"", @"chatSyncTimeLen":self.chatSyncTimeLen ?: @"", @"chatRecordTimeOut":self.chatRecordTimeOut ?: @"", @"closeTelephoneFind":self.closeTelephoneFind ?: @"", @"friendFromList":self.friendFromList ?: @"", @"friendsVerify":self.friendsVerify ?: @"", @"isEncrypt":self.isEncrypt ?: @"", @"isKeepalive":[NSNumber numberWithBool:self.isKeepalive ?: NO], @"isTyping":self.isTyping ?: @"", @"isUseGoogleMap":self.isUseGoogleMap ?: @"", @"isVibration":self.isVibration ?: @"", @"multipleDevices":self.multipleDevices ?: @"", @"nameSearch":self.nameSearch ?: @"", @"openService":[NSNumber numberWithBool:self.openService  ?: NO], @"phoneSearch":self.phoneSearch ?: @"", @"showLastLoginTime":[NSNumber numberWithBool:self.showLastLoginTime ?: NO], @"showTelephone":[NSNumber numberWithBool:self.showTelephone ?: NO]};
    [mutDic setObject:settingsDic forKey:@"settings"];
    /*-------------Settings   End------------------*/
    
    [mutDic setObject:self.sex ?: @(0) forKey:@"sex"];
    [mutDic setObject:[NSNumber numberWithBool:self.showLastLoginTime ?: NO] forKey:@"showLastLoginTime"];
    [mutDic setObject:self.status ?: @(0) forKey:@"status"];
    [mutDic setObject:self.telephone ?: @"" forKey:@"telephone"];
    [mutDic setObject:self.totalConsume ?: @"" forKey:@"totalConsume"];
    [mutDic setObject:self.totalRecharge ?: @"" forKey:@"totalRecharge"];
    [mutDic setObject:self.userKey ?: @"" forKey:@"userKey"];
    [mutDic setObject:self.userType ?: @(0) forKey:@"userType"];
    [mutDic setObject:self.vip ?: @(0) forKey:@"vip"];
    
    [mutDic setObject:self.questions ?: @[] forKey:@"questions"];
    [mutDic setObject:self.redPacketVip ?: @(0) forKey:@"redPacketVip"];
    return mutDic;
}
@end
