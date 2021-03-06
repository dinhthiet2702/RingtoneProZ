//
//  LNPopupCloseButton+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 13/11/2016.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "LNPopupCloseButton.h"
#import "LNPopupContentView.h"

@interface LNPopupCloseButton ()

@property (nonatomic, weak) LNPopupContentView* popupContentView;

- (void)_setStyle:(LNPopupCloseButtonStyle)style;
- (void)_setButtonContainerStationary;
- (void)_setButtonContainerTransitioning;

@end
