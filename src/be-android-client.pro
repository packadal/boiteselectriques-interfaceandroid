TEMPLATE = app

QT += qml quick widgets quickcontrols2
android: QT += androidextras

CONFIG += c++11
SOURCES += main.cpp \
	Application.cpp \
    track.cpp \
    instrumentimageprovider.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
	Application.h \
    track.h \
    instrumentimageprovider.h \
    transmitter.hpp

android-g++|android-clang {
	ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
	OTHER_FILES += \
		android/AndroidManifest.xml
}

OTHER_FILES += \
    images/logo_80.png
