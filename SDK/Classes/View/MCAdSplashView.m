//
// Created by majiancheng on 2017/5/26.
// Copyright (c) 2017 poholo Inc. All rights reserved.
//

#import "MCAdSplashView.h"

#import <SDWebImage/SDImageCache.h>
#import <GDTAd/GDTAd.h>
#import <BaiduMobAdSDK/BaiduMobAdSplashDelegate.h>
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>

#import "MCSplashDto.h"
#import "MCAdPlayerView.h"
#import "MCAdsManager.h"
#import "MCAdConfig.h"
#import "UIImageView+WebCache.h"
#import "MCAdvertisementDto.h"
#import "MCColor.h"
#import "UIView+AdCorner.h"
#import "MCFont.h"
#import "MCAdUtils.h"

@interface MCAdSplashView () <BaiduMobAdSplashDelegate, GDTSplashAdDelegate>

@property(nonatomic, strong) UIButton *jumpBtn;

@property(nonatomic, strong) UIImageView *imageView;

@property(nonatomic, strong) UIImageView *adContainer;

@property(nonatomic, strong) MCAdPlayerView *adPlayerView;

@property(nonatomic, strong) BaiduMobAdSplash *baiduMobAdSplash;

@property(nonatomic, strong) GDTSplashAd *tencentMobAdSplash;

@property(nonatomic, strong) MCSplashDto *dto;

@end

@implementation MCAdSplashView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.adContainer];
        [self addSubview:self.adPlayerView];
        [self addSubview:self.jumpBtn];

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)]];
    }
    return self;
}

- (void)loadData:(MCSplashDto *)dto {
    self.dto = dto;
    self.jumpBtn.hidden = NO;
    switch (dto.splashType) {
        case MCSplashTypeBaidu : {
            self.baiduMobAdSplash.delegate = self;
//            [LogService createRequestAD:[[[LogParam createWithRefer:@"plaunch_splash"] advertisment:_baiduMobAdSplash.AdUnitTag] num:@"1"]];
            [self.baiduMobAdSplash loadAndDisplayUsingContainerView:self.adContainer];
            self.jumpBtn.hidden = YES;
        }
            break;
        case MCSplashTypeCustomImage: {
//            [LogService createShowAD:[[[LogParam createWithRefer:@"plaunch_wqlive"] advertisment:dto.entityId] time:[NSString stringWithFormat:@"%@", dto.resq]]];

            [self.adContainer sd_setImageWithURL:[NSURL URLWithString:dto.advertisementDto.imageUrl] placeholderImage:nil];
//                [LogService createShowAD:[[[[LogParam createWithRefer:@"plaunch_wqlive"] advertisment:dto.entityId] time:[NSString stringWithFormat:@"%@", dto.resq]] ctag:dto.liveAdDto.liveInfo.ctag]];
        }
            break;
        case MCSplashTypeCustomVideo: {
//            [LogService createShowAD:[[[LogParam createWithRefer:@"plaunch_vad"] advertisment:dto.entityId] time:[NSString stringWithFormat:@"%@", dto.resq]]];

            if (dto.advertisementDto.imageUrl) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:dto.advertisementDto.imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error) {
                        MCLog(@"error :::::%@", error);
                    }
                }];
            }

            if ([self.delegate respondsToSelector:@selector(adSplashViewShowUsingPlayerKit:)]) {
                [self.delegate adSplashViewShowUsingPlayerKit:self.dto];
            }
        }
            break;
        case MCSplashTypeTencent: {
            self.tencentMobAdSplash.fetchDelay = 3;
            self.tencentMobAdSplash.delegate = self;
            if ([self.delegate respondsToSelector:@selector(adSplashViewShowUsingWindow:)]) {
                [self.delegate adSplashViewShowUsingWindow:self.dto];
            }
        }
            break;
        default: {
        }
            break;
    }
}

- (void)updateJumpBtnInfo:(NSString *)jumpBtnInfo {
    [self.jumpBtn setTitle:jumpBtnInfo forState:UIControlStateNormal];
}


#pragma mark - SPlashBaidu Delegate

- (NSString *)publisherId {
    return [MCAdsManager share].splashConfig.appId;
}

//百度广告代理
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    MCLog(@"splashlFailPresentScreen success");
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashSuccessPresentScreen:)]) {
            [strongSelf.delegate adSplashSuccessPresentScreen:self.dto];
        }
    }];
}

/**
 *  广告展示失败
 */
- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    MCLog(@"splashlFailPresentScreen withError:%d", reason);
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewJumpResonError:)]) {
            [strongSelf.delegate adSplashViewJumpResonError:self.dto];
        }
    }];

}

/**
 *  广告展示结束
 */
- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    MCLog(@"splashDidDismissScreen");
    //自定义开屏移除
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewJumpResonEnd:)]) {
            [strongSelf.delegate adSplashViewJumpResonEnd:self.dto];
        }
    }];

}

/**
 *  广告点击
 */
- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    MCLog(@"splashDidClicked");
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewJumpContent:)]) {
            [strongSelf.delegate adSplashViewJumpContent:self.dto];
        }
    }];

}

- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
    MCLog(@"splashDidDismissLp");
}

#pragma mark - SplashTencent Delegate

- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    MCLog(@"[TencentAd]splashAdSuccessPresentScreen");
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashSuccessPresentScreen:)]) {
            [strongSelf.delegate adSplashSuccessPresentScreen:self.dto];
        }
    }];

}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    MCLog(@"[TencentAd]splashlFailPresentScreen withError:%@", error);
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewJumpResonError:)]) {
            [strongSelf.delegate adSplashViewJumpResonError:self.dto];
        }
    }];


}

- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd {
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewEnterbackGroundEnd:)]) {
            [strongSelf.delegate adSplashViewEnterbackGroundEnd:self.dto];
        }
    }];
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewJumpContent:)]) {
            [strongSelf.delegate adSplashViewJumpContent:self.dto];
        }
    }];

}

- (void)splashAdWillClosed:(GDTSplashAd *)splashAd {
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewJumpResonEnd:)]) {
            [strongSelf.delegate adSplashViewJumpResonEnd:self.dto];
        }
    }];
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd {

}

- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd {

}

- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd {

}

- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd {

}

- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd {
    __weak typeof(self) weakSelf = self;
    [MCAdUtils mainExecute:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(adSplashViewJumpResonEnd:)]) {
            [strongSelf.delegate adSplashViewJumpResonEnd:self.dto];
        }
    }];

}

- (void)splashAdLifeTime:(NSUInteger)time {

}

#pragma mark -action

- (void)tapClick {
    if ([self.delegate respondsToSelector:@selector(adSplashViewJumpContent:)]) {
        [self.delegate adSplashViewJumpContent:self.dto];
    }
}

- (void)jumpBtnClick {
    if ([self.delegate respondsToSelector:@selector(adSplashViewJumpSplash:)]) {
        [self.delegate adSplashViewJumpSplash:self.dto];
    }
}

- (UIButton *)jumpBtn {
    if (!_jumpBtn) {
        _jumpBtn = ({
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 120, 30, 100, 30)];
            btn.backgroundColor = [MCColor colorII];
            btn.alpha = .6f;
            btn.titleLabel.font = [MCFont fontII];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn addCorner:15];
            [btn addTarget:self action:@selector(jumpBtnClick) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
    }
    return _jumpBtn;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            imageView;
        });
    }
    return _imageView;
}

- (UIImageView *)adContainer {
    if (!_adContainer) {
        _adContainer = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            imageView;
        });
    }
    return _adContainer;
}

- (MCAdPlayerView *)adPlayerView {
    if (!_adPlayerView) {
        _adPlayerView = [[MCAdPlayerView alloc] initWithFrame:self.bounds];
    }
    return _adPlayerView;
}

- (BaiduMobAdSplash *)baiduMobAdSplash {
    if (!_baiduMobAdSplash) {
        _baiduMobAdSplash = [[BaiduMobAdSplash alloc] init];
        if ([MCAdsManager share].splashConfig.entityId) {
            _baiduMobAdSplash.AdUnitTag = [MCAdsManager share].splashConfig.entityId;
        }
        _baiduMobAdSplash.canSplashClick = YES;
        _baiduMobAdSplash.delegate = self;
    }
    return _baiduMobAdSplash;
}

- (GDTSplashAd *)tencentMobAdSplash {
    if (!_tencentMobAdSplash) {
        _tencentMobAdSplash = [[GDTSplashAd alloc] initWithAppkey:[MCAdsManager share].splashConfig.appId placementId:[MCAdsManager share].splashConfig.entityId];
        _tencentMobAdSplash.backgroundColor = [MCColor randomImageColor];
    }
    return _tencentMobAdSplash;
}

@end
