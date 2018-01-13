TEMPLATE = app

QT += qml quick widgets quickcontrols2

CONFIG += c++11
SOURCES += main.cpp \
	Application.cpp \
    track.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
	Application.h \
	osc/oscmessagegenerator.h \
	osc/oscreceiver.h \
	osc/oscsender.h

#### Libraries ####
  ##  Oscpack  ##

OSCPACK = $$PWD/../deps/oscpack

android-g++|android-clang {
	unix:!macx: LIBS += -L$$OSCPACK -loscpack

	INCLUDEPATH += $$OSCPACK
	DEPENDPATH += $$OSCPACK

	unix:!macx: PRE_TARGETDEPS += $$OSCPACK/liboscpack.a


	ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

	OTHER_FILES += \
		android/AndroidManifest.xml
		
}

OTHER_FILES += \
    images/logo_80.png
