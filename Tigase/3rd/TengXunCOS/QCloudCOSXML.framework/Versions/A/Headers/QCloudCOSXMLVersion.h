//
// QCloud Terminal Lab --- service for developers
//
#import <Foundation/Foundation.h>
#import <QCloudCore/QCloudCoreVersion.h>

#ifndef QCloudCOSXMLModuleVersion_h
#define QCloudCOSXMLModuleVersion_h
#define QCloudCOSXMLModuleVersionNumber 506002

//dependency
#if QCloudCoreModuleVersionNumber != 506002
    #error "库QCloudCOSXML依赖QCloudCore最小版本号为5.6.2，当前引入的QCloudCore版本号过低，请及时升级后使用"
#endif

//
FOUNDATION_EXTERN NSString * const QCloudCOSXMLModuleVersion;
FOUNDATION_EXTERN NSString * const QCloudCOSXMLModuleName;

#endif
