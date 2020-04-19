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
__version__ = "1.0" 
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
        
    @Slot(str, str)    
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
    
        for obj in self.m_listProxyLast:
            del obj
        
        for obj in self.m_listModelLast:
            del obj
        
        self.m_listProxyLast=[]
        self.m_listModelLast=[]
        print("iniciando model...")
    
    @Slot()    
    def deleteModels(self):
        for obj in self.m_listModel:
            obj.clear()
            obj.setFields(QJsonArray())
            self.m_listModelLast.append(obj)
        
        for bj in self.m_listProxy:
            self.m_listProxyLast.append(obj)
        
        self.m_listModel=[]
        self.m_listProxy=[]
        
        self.m_engine.clearComponentCache()
