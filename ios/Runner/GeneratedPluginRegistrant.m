//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <barcode_scan/BarcodeScanPlugin.h>
#import <firebase_core/FirebaseCorePlugin.h>
#import <firebase_database/FirebaseDatabasePlugin.h>
#import <path_provider/PathProviderPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [BarcodeScanPlugin registerWithRegistrar:[registry registrarForPlugin:@"BarcodeScanPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTFirebaseDatabasePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseDatabasePlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
}

@end
