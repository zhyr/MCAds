//
//  MCSplashDto.m
//  MCAds
//
//  Created by majiancheng on 2017/8/30.
//  Copyright © 2017年 poholo Inc. All rights reserved.
//

#import "MCSplashDto.h"

#import "MCLiveAdDto.h"
#import "MCAdConfig.h"
#import "MCAdvertisementDto.h"

@implementation MCSplashDto

- (instancetype)init {
    self = [super init];
    if (self) {
        self.resq = nil;
    }
    return self;
}

+ (MCSplashDto *)convertByAdConfig:(MCAdConfig *)adConfig {
    MCSplashDto *splashDto = [[MCSplashDto alloc] init];
    splashDto.source = adConfig.source;
    return splashDto;
}


- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"waquAdvert"]) {
        self.advertisementDto = [MCAdvertisementDto createDto:value];
    } else if ([key isEqualToString:@"imgUrl"]) {
        self.liveAdDto.picUrl = value;
    } else if ([key isEqualToString:@"adid"]) {
        self.liveAdDto.entityId = value;
    }
}

- (NSString *)entityId {
    return self.advertisementDto.entityId;
}

- (SplashType)splashType {
    if (self.liveAdDto.entityId) {
        return SplashTypeWaQuImage;
    } else if (self.advertisementDto.entityId) {
        return SplashTypeWaQuVideo;
    } else if ([self.source isEqualToString:@"baidu"]) {
        return SplashTypeBaidu;
    } else if ([self.source isEqualToString:@"gdt"]) {
        return SPlashTypeTencent;
    } else {
        return SPlashTypeTencent;
    }
}

- (MCLiveAdDto *)liveAdDto {
    if (!_liveAdDto) {
        _liveAdDto = [MCLiveAdDto new];
    }
    return _liveAdDto;
}

@end