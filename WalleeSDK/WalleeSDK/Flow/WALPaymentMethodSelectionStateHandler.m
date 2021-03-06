//
//  WALPaymentMethodSelectionHandler.m
//  WalleeSDK
//
//  Created by Daniel Schmid on 04.09.17.
//  Copyright © 2017 smoca AG. All rights reserved.
//

#import "WALPaymentMethodSelectionStateHandler.h"
#import "WALPaymentMethodConfiguration.h"
#import "WALLoadedPaymentMethods.h"

#import "WALSimpleFlowStateHandler+Private.h"
#import "WALFlowCoordinator+StateDelegate.h"

#import "WALFlowConfiguration.h"
#import "WALPaymentFlowDelegate.h"
#import "WALViewControllerFactory.h"

#import "WALPaymentErrorHelper.h"
#import "WALErrorDomain.h"

#import "WALApiClient.h"

@interface WALPaymentMethodSelectionStateHandler ()
@property (nonatomic, copy) WALLoadedPaymentMethods *loadedPaymentMethods;
@end

@implementation WALPaymentMethodSelectionStateHandler

+ (instancetype)stateWithParameters:(NSDictionary *)parameters {
    return [self stateWithPaymentMethods:parameters[WALFlowPaymentMethodsParameter]];
}

+ (instancetype)stateWithPaymentMethods:(WALLoadedPaymentMethods *)loadedPaymentMethods {
    if (loadedPaymentMethods.paymentMethodConfigurations.count <= 0) {
        return nil;
    }
    return [[self alloc] initWithPaymentMethods:loadedPaymentMethods];
}

- (instancetype)initWithPaymentMethods:(WALLoadedPaymentMethods *)loadedPaymentMethods {
    if (self = [super initInternal]) {
        _loadedPaymentMethods = loadedPaymentMethods;
    }
    return self;
}

- (BOOL)dryTriggerAction:(WALFlowAction)flowAction {
    return flowAction == WALFlowActionGoBack;
}

- (BOOL)triggerAction:(WALFlowAction)flowAction WithCoordinator:(WALFlowCoordinator *)coordinator {
    if (![WALSimpleFlowStateHandler isStateValid:self WithCoordinator:coordinator]) {
        return NO;
    }
    if ([self dryTriggerAction:flowAction]) {
        [coordinator changeStateTo:WALFlowStateTokenLoading parameters:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void)performWithCoordinator:(WALFlowCoordinator *)coordinator {
    [super performWithCoordinator:coordinator];
    if ([coordinator.configuration.delegate respondsToSelector:@selector(flowCoordinatorWillDisplayPaymentMethodSelection:)]) {
        [coordinator.configuration.delegate flowCoordinatorWillDisplayPaymentMethodSelection:coordinator];
    }
    [coordinator ready];
}

- (UIViewController *)viewControllerForCoordinator:(WALFlowCoordinator *)coordinator {
    __weak WALPaymentMethodSelectionStateHandler *weakSelf = self;
    __weak WALFlowCoordinator *weakCoordinator = coordinator;
    WALPaymentMethodSelected onSelectionBlock = ^(WALPaymentMethodConfiguration * _Nonnull paymentMethod) {
        if (![WALSimpleFlowStateHandler isStateValid:weakSelf WithCoordinator:weakCoordinator]) {
            return;
        }
        NSDictionary *parameter = @{WALFlowPaymentMethodsParameter: @(paymentMethod.objectId)};
        [weakCoordinator changeStateTo:WALFlowStatePaymentForm parameters:parameter];
    };
    
    UIViewController *controller = [coordinator.configuration.viewControllerFactory
                                    buildPaymentMethodListViewWith:self.loadedPaymentMethods
                                    onSelection:onSelectionBlock
                                    onBack:^{
                                        [weakSelf triggerAction:WALFlowActionGoBack WithCoordinator:weakCoordinator];
                                    }];
    return controller;
}

@end
