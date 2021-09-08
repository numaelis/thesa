#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan  3 23:34:27 2020
this file is part the thesa: tryton client based PySide2(qml2)
main
"""

__author__ = "Numael Garay"
__copyright__ = "Copyright 2020-2021"
__license__ = "GPL"
__version__ = "1.8" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"


from qjsonmodel import ProxyModelJson, ModelJson, DataJson
from qjsonnetwork import QJsonNetwork
from modelmanager import ModelManager
from tools import Tools
from systemnet import SystemNet

import sys

from PySide2.QtCore import Property, QUrl, QDir, QCoreApplication, Qt, QGenericArgument, QObject, QMetaObject, QJsonValue, QGenericReturnArgument, QSettings, QLocale, Slot, QJsonArray
from PySide2 import QtCore
from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine#, QQuickStyle
from PySide2.QtWidgets import QMessageBox

ThesaVersion = "1.8"

engine_point=None

class ObjectMessaje(QObject):
    def __init__(self, parent=None):
        QObject.__init__(self, parent)
        self.messages = []
    @Slot()
    def clearMessages(self):
        self.messages=[]
#    @Slot(QJsonArray)
#    def setMessage(self, msgs):
#        self.messages=msgs
    @Slot(str)
    def addMessage(self, msg):
        self.messages.append(msg)
    @Slot(result=QJsonArray)
    def getMessages(self):
        return self.messages
mObjMsg = ObjectMessaje()

def qt_message_handler(mode, context, message):
    global engine_point
    global mObjMsg
    if mode == QtCore.QtInfoMsg:
        mode = 'Info'
    elif mode == QtCore.QtWarningMsg:
        mode = 'Warning'
        if message.find(".qml")!=-1:
            root = engine_point.rootObjects()[0]
            QMetaObject.invokeMethod(root, "closeBusy")
            if not message in mObjMsg.getMessages():
                root.setProperty("argsFucntionLastCall",["warning:\n"+message])
                QMetaObject.invokeMethod(root, "_messageWarningPySide")
        mObjMsg.addMessage(message)
    elif mode == QtCore.QtCriticalMsg:
        mode = 'critical'
    elif mode == QtCore.QtFatalMsg:
        mode = 'fatal'
    else:
        mode = 'Debug'
    if mode=='Debug':
        print("%s: %s" % (mode, message))
    else:
        if mode == "critical" or "fatal":
            root = engine_point.rootObjects()[0]
            QMetaObject.invokeMethod(root, "_forceNotRun")
        print("%s: %s (%s:%d, %s)" % (mode, message, context.file, context.line, context.file))
    
if __name__ == '__main__':
    
    QCoreApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
    QCoreApplication.setAttribute(Qt.AA_UseOpenGLES)
    #os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    sys_argv = sys.argv
    sys_argv += ['--style', 'material']
    app = QApplication(sys_argv)
    
    app.setOrganizationName("MantrixSoft")
    app.setApplicationName("thesa")
    
    #QQuickStyle.setStyle("Material")
    engine = QQmlApplicationEngine()
    engine_point = engine
    QtCore.qInstallMessageHandler(qt_message_handler)
    
    jchc = QJsonNetwork(app)
    jchc.setEngine(engine)
    #jchc.selectRequestPython(False)
    
    systemnet = SystemNet(jchc)
    modelmanager = ModelManager(jchc, engine, app)
    
    mtools = Tools(app)

    mDir=QDir.currentPath()
    
    
    engine.rootContext().setContextProperty("QJsonNetworkQml", jchc)
    engine.rootContext().setContextProperty("ModelManagerQml", modelmanager)
    engine.rootContext().setContextProperty("SystemNet", systemnet)
    
    engine.rootContext().setContextProperty("ThesaVersion", ThesaVersion)
    
    engine.rootContext().setContextProperty("Tools", mtools)
    
    engine.rootContext().setContextProperty("DirParent", mDir)
    
    engine.rootContext().setContextProperty("ObjectMessageLast", mObjMsg)

    settings = QSettings()
    defaultLocale = settings.value("translate", "")
    if defaultLocale=="":
        defaultLocale = QLocale.system().name()
    mtools.selectCoreTranslation(defaultLocale, settings)
    
    engine.addImportPath(mDir + QDir.separator() + "tools")
	#engine.load(QUrl("qrc:/main.qml"))
    engine.load(QUrl.fromLocalFile('main.qml'))

    if not engine.rootObjects():
        msgBox = QMessageBox()
        msgBox.setText("Error rootObjects")
        msgBox.exec_()
        sys.exit(-1)
        
    sys.exit(app.exec_())
