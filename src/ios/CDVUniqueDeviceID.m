//
//  CDVUniqueDeviceID.m
//
//
//
#import "CDVUniqueDeviceID.h"
#import "UICKeyChainStore.h"


@implementation CDVUniqueDeviceID
static NSString *serviceName = @"es.selae.eloterias.data.uuid";
static NSString *uuidName = @"uuid";


-(void)get:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        Boolean isUUIDStored = false;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //Testar si tenemos un uuid almacenado previamente
        NSString *uuidFromStore = [defaults objectForKey:serviceName];
        if(uuidFromStore)
            isUUIDStored = true;
        
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uuidUserDefaults = [defaults objectForKey:uuidName];
        NSString *uuid = [UICKeyChainStore stringForKey:uuidName];

        if(isUUIDStored){
            //Return the stored one
            uuid = uuidFromStore;
        }else{
            if (uuid && !uuidUserDefaults) {
                [defaults setObject:uuid forKey:uuidName];
                
                [defaults synchronize];
            }  else if (!uuid && !uuidUserDefaults) {
                NSString *uuidString = [[NSUUID UUID] UUIDString];
                [UICKeyChainStore setString:uuidString forKey:uuidName];
                [defaults setObject:uuidString forKey:uuidName];
                [defaults synchronize];
                
                uuid = [UICKeyChainStore stringForKey:uuidName];
            } else if (![uuid isEqualToString:uuidUserDefaults]) {
                [UICKeyChainStore setString:uuidUserDefaults forKey:uuidName];
                
                uuid = [UICKeyChainStore stringForKey:uuidName];
            }
            
            if(!uuid)
                uuid = [[NSUUID UUID] UUIDString];
        }
        
        
        //Save if the current uuid was not stored.
        if(!isUUIDStored){
            [defaults setObject:uuid forKey:serviceName];
            [defaults synchronize];
            //NSLog(@"UUID data stored for SELAE.");
        }

        //Return data to plugin listener.
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:uuid];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

@end

