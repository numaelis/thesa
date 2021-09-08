#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 17 23:31:52 2020
this file is part the thesa: tryton client based PySide2(qml2)
tools functions help
"""

__author__ = "Numael Garay"
__copyright__ = "Copyright 2020"
__license__ = "GPL"
__version__ = "1.6" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

from PySide2.QtCore import QObject, Slot, QJsonArray
#from PySide2.QtQml import QQmlApplicationEngine
from qjsonmodel import ProxyModelJson, ModelJson
#from qjsonnetwork import QJsonNetwork

class ModelManager(QObject):
    def __init__(self, network, engine, parent = None):
        QObject.__init__(self, parent)
        self.m_network = network #QJsonNetwork
        self.m_engine = engine #QQmlApplicationEngine 
        
        self.m_listModel=[] #QList<ModeloJson *> 
        self.m_listProxy=[] #QList<ProxyModelJson *> 
        self.m_listModelLast=[]
        self.m_listProxyLast=[]
        self.m_listProperty=[] #QStringList 
        
    @Slot(str, str, result="QVariantMap")    
    def addModel(self, model, proxy):
        modeljson = ModelJson(model.lower(),self.parent())
        proxyjson = ProxyModelJson(self.parent())
        modeljson.setProxy(proxyjson)
        modeljson.setJsonConnect(self.m_network)
        modeljson.initProxy()
        modeljson.setEngine(self.m_engine)
    
        self.m_engine.rootContext().setContextProperty(model, modeljson)
        self.m_engine.rootContext().setContextProperty(proxy, proxyjson)
        self.m_listModel.append(modeljson)
        self.m_listProxy.append(proxyjson)
        self.m_listProperty.append(model)
        self.m_listProperty.append(proxy)    
        
        i=0
        idel=-1
        for obj in self.m_listProxyLast:
            if obj.sourceModel().objectName()==model.lower():
                idel=i
                break
            i+=1
            
        if idel!=-1:
            obj = self.m_listProxyLast[idel]
            self.m_listProxyLast.pop(idel)
            del obj
            
        i=0
        idel=-1
        for obj in self.m_listModelLast:
            #obj.deleteLater()
            if obj.objectName()==model.lower():
                idel=i
                break
            i+=1
        if idel!=-1:
            obj = self.m_listModelLast[idel]
            obj.setObjectName("cero")
            self.m_listModelLast.pop(idel)
            del obj

        print("init model...")
        return {"model":modeljson, "proxy":proxyjson}
    
    @Slot()    
    def deleteModels(self):
        for obj in self.m_listModel:
            obj.prepareDeletion();
            self.m_listModelLast.append(obj)
        
        for obj in self.m_listProxy:
            self.m_listProxyLast.append(obj)
        
        self.m_listModel=[]
        self.m_listProxy=[]
    
    @Slot()    
    def clearComponentCache(self):
        self.m_engine.clearComponentCache()
        
