#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan  3 23:34:27 2020

"""
__author__ = "Numael Garay"
__copyright__ = "Copyright 2020"
__license__ = "GPL"
__version__ = "1.0" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"


#from qobjectlistmodel import QObjectListModel
from qjsonmodel import ProxyModelJson, ModelJson, DataJson
from qjsonnetwork import QJsonNetwork
from modelmanager import ModelManager
from tools import Tools
from systemnet import SystemNet

import sys

from PySide2.QtCore import Property, QUrl, QDir, QCoreApplication, Qt, QGenericArgument, QObject, QMetaObject, QJsonValue, QGenericReturnArgument, QSettings, QLocale
from PySide2 import QtCore
#from PySide2.QtGui import QGuiApplication
from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine#, QQuickStyle
from PySide2.QtWidgets import QMessageBox
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QMessageBox>
#include <QQuickStyle>
#ThesaModule = False
ThesaVersion = "1.0"
#TrytonVersion = "4"

engine_point=None
def qt_message_handler(mode, context, message):
    global engine_point
    if mode == QtCore.QtInfoMsg:
        mode = 'Info'
    elif mode == QtCore.QtWarningMsg:
        mode = 'Warning'
        if message.find(".qml")!=-1:
            root = engine_point.rootObjects()[0]
            QMetaObject.invokeMethod(root, "closeBusy")
            root.setProperty("argsFucntionLastCall",["warning:\n"+message])
            QMetaObject.invokeMethod(root, "_messageWarningPySide")
    elif mode == QtCore.QtCriticalMsg:
        mode = 'critical'
    elif mode == QtCore.QtFatalMsg:
        mode = 'fatal'
    else:
        mode = 'Debug'
    print("%s: %s (%s:%d, %s)" % (mode, message, context.file, context.line, context.file))
    
if __name__ == '__main__':
    
    QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
    QCoreApplication.setAttribute(Qt.AA_UseOpenGLES)
    #os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    sys_argv = sys.argv
    sys_argv += ['--style', 'material']
    app = QApplication(sys_argv)
    #app = QGuiApplication(sys_argv)
    
    app.setOrganizationName("MantrixSoft")
    app.setApplicationName("thesa")
    
    #QQuickStyle.setStyle("Material")
    engine = QQmlApplicationEngine()
    engine_point = engine
    QtCore.qInstallMessageHandler(qt_message_handler)
    
    jchc = QJsonNetwork(app)
    jchc.setEngine(engine)
    #jchc.setVersionTryton(TrytonVersion)
    
    systemnet = SystemNet(jchc)
    modelmanager = ModelManager(jchc, engine, app)
    
    mtools = Tools(app)
#    nameDays = mtools.calendarNamesDays()
#    nameMonths= mtools.calendarNamesMonths()
#
    mDir=QDir.currentPath()
    
    engine.rootContext().setContextProperty("QJsonNetworkQml", jchc)
    engine.rootContext().setContextProperty("ModelManagerQml", modelmanager)
    engine.rootContext().setContextProperty("SystemNet", systemnet)
    
    engine.rootContext().setContextProperty("ThesaVersion", ThesaVersion)
    
    engine.rootContext().setContextProperty("Tools", mtools)
#    engine.rootContext().setContextProperty("NameDays", nameDays)
#    engine.rootContext().setContextProperty("NameMonths", nameMonths)
    
    engine.rootContext().setContextProperty("DirParent", mDir)

    settings = QSettings()
    defaultLocale = settings.value("translate", "")
    if defaultLocale=="":
        defaultLocale = QLocale.system().name()
    mtools.selectCoreTranslation(defaultLocale, settings)
    
    #engine.load(QUrl(QStringLiteral("qrc:/main.qml")))
    engine.addImportPath(mDir + QDir.separator() + "tools")
    engine.load(QUrl.fromLocalFile('main.qml'))
    
    if not engine.rootObjects():
        msgBox = QMessageBox()
        msgBox.setText("Error rootObjects")
        msgBox.exec_()
        sys.exit(-1)
        
    sys.exit(app.exec_())