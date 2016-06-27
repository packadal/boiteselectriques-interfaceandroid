TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11
SOURCES += main.cpp \
	Application.cpp

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

linux-g++ {
unix:!macx: LIBS += -L$$PWD/../../deps/linux/oscpack/ -loscpack

INCLUDEPATH += $$PWD/../../deps/src/oscpack
DEPENDPATH += $$PWD/../../deps/src/oscpack

unix:!macx: PRE_TARGETDEPS += $$PWD/../../deps/linux/oscpack/liboscpack.a
}

android-g++|android-clang {
unix:!macx: LIBS += -L$$PWD/../../deps/android/oscpack/ -loscpack

INCLUDEPATH += $$PWD/../../deps/src/oscpack
DEPENDPATH += $$PWD/../../deps/src/oscpack

unix:!macx: PRE_TARGETDEPS += $$PWD/../../deps/android/oscpack/liboscpack.a


ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

OTHER_FILES += \
	android/AndroidManifest.xml

}

OTHER_FILES += \
    images/logo_80.png
