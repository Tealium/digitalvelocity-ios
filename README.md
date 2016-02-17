Tealium Digital Velocity App
============================

###Brief###
Application for partners and clients attending DV Conferences.

###Table of Contents###

- [Requirements](#requirements)
- [Dependencies](#dependencies)
- [Removing CocoaPods](#removing-cocoapods)

###Requirements###

- [XCode (6.0+ recommended)](https://developer.apple.com/xcode/downloads/)
- Minimum target iOS Version 7.0+

###Dependencies###
This application uses a number of 3rd party libaries, including Tealium's own AudienceStream SDK:

- [Cocoapods](#cocoapods)
- [AsyncDisplayKit](#asyndisplaykit)
- [Crashyltics](#crashyltics)
- [Parse](#parse)


####Cocoapods
Dependency Manager
Link: http://cocoapods.org


####AsyncDisplayKit
UI Performance Library
Link: http://asyncdisplaykit.org

####Crashyltics
Crash Reporting
Link: https://try.crashlytics.com

####Parse
Data Content Management + Push services
Link: https://parse.com


####Removing Cocoapods
NOTE editing some of these things if done incorrectly could break your main project. I strongly encourage you to check your projects into source control just in case. Also these instructions are for CocoaPods version 0.28.0, they could change with new versions.

1. Delete the standalone files (Podfile Podfile.lock and your Pods directory)
2. Delete the generated xcworkspace
3. Open your xcodeproj file, delete the references to Pods.xcconfig and libPods.a (in the Frameworks group)
4. Under your Build Phases delete the Copy Pods Resources and Check Pods Manifest.lock phases.
5. This may seem obvious but you'll need to integrate the 3rd party libraries some other way or remove references to them from your code.
6. After those steps you should be set with a single xcodeproj that existed before you integrated CocoaPods. If I missed anything let me know and I will edit this.

