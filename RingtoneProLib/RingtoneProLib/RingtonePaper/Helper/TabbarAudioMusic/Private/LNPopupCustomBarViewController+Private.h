//
//  LNPopupItem+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import "LNPopupItem.h"
#import "LNPopupCustomBarViewController.h"
#import "LNPopupController.h"

@interface LNPopupCustomBarViewController ()

@property (nonatomic, weak, readwrite) LNPopupBar* containingPopupBar;
@property (nonatomic, weak) LNPopupController* popupController;

@end
