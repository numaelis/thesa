#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 17 23:31:52 2020
this file is part the thesa: tryton client based PySide2(qml2)
systemnet
"""

__author__ = "Numael Garay"
__copyright__ = "Copyright 2020"
__license__ = "GPL"
__version__ = "1.6" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

from PySide2.QtCore import QObject, QJsonArray, Slot, Signal, QDate, QDir, QByteArray, QIODevice, QFile
import os
import hashlib
import shutil

_dirSystem = 'systemnet'

class SystemNet(QObject):
    def __init__(self, jsonnet, parent = None):
        QObject.__init__(self, parent)
        self.m_qjsonnetwork = jsonnet
        self.mDir=QDir.currentPath()
        self.actionCache_="notDelete"#"deleteOnCompleted" version 1.1 up thesamodule
        
    signalRespuestaData = Signal(str, int, "QJsonObject")#QJsonObject = dict
    
    @Slot(result=bool)    
    def actionCacheOnCompleted(self):#version 1.1 up thesamodule
        boolAction=False
        if self.actionCache_ == "deleteOnCompleted":
            sysdir = QDir(self.mDir + QDir.separator() + _dirSystem)
            DIR_QML_SYS = sysdir.path()
            for the_file in os.listdir(DIR_QML_SYS):
               file_path = os.path.join(DIR_QML_SYS, the_file)
               try:
                   if os.path.isfile(file_path):
                       if ".qml" in file_path:
                           os.unlink(file_path)
                   elif os.path.isdir(file_path): shutil.rmtree(file_path)
                   boolAction=True
               except Exception as e:
                   boolAction=False
                   print(e)
        else:
            boolAction = True
        return boolAction
    
    @Slot("QJsonObject", result=bool)    
    def rechargeNet(self, preferences):
        #version 1.1 up thesamodule
        data = self.m_qjsonnetwork.callDirect("version internal",
                                       "model.thesamodule.config.search_read", 
                                       [[],0,1,[],["internal_version"],preferences])
        if not data["data"]=="error":
            if float(data["data"]["result"][0]["internal_version"]) > 1.0:
                data = self.m_qjsonnetwork.callDirect("cachedel",
                                       "model.thesamodule.config.search_read", 
                                       [[],0,1,[],["deletecache"],preferences])
                if not data["data"]=="error":
                    if data["data"]["result"][0]["deletecache"]==True:
                        self.actionCache_ = "deleteOnCompleted"
                    else:
                        self.actionCache_ = "notDelete"
        sysdir = QDir(self.mDir + QDir.separator() + _dirSystem)
        DIR_QML_SYS = sysdir.path()
        DIR_QML_SYS_LOST = DIR_QML_SYS + QDir.separator() +"lost"
        sysdirlost = QDir(DIR_QML_SYS_LOST)
         #revisar folder systemnet
        if sysdir.exists()==False:
            s=QDir(self.mDir)
            s.mkdir("systemnet")
        #revisar folder systemnet lost
        if sysdirlost.exists()==False:
            sl=QDir(DIR_QML_SYS)
            sl.mkdir("lost")
        #find all files en folder net
        listSysFiles = os.listdir(DIR_QML_SYS)
        if "lost" in listSysFiles:
            listSysFiles.remove("lost")
            
        data = self.m_qjsonnetwork.callDirect("rechargeNetStep1",
                                       "model.thesamodule.thesamodule.search_read", 
                                       [[],0,1000,[],["checksum","filename"],preferences])
        if not data["data"]=="error":
            resultnet = data["data"]["result"]
            mapnet={}
            mapids={}
            listNetFiles = []
            for file in resultnet:
                mapnet[file["filename"]] = file["checksum"]
                mapids[file["filename"]] = file["id"]
                listNetFiles.append(file["filename"])
            #buscar faltantes en system y los updates
            #buscar los que ya no deben estar
            mapsysnet={}
            listToUpdate=set()#new or update
            listToErase=[]
            for file in listSysFiles:
                try:
                    with open(DIR_QML_SYS+QDir.separator()+file, "rb") as binary_file:
                        data = binary_file.read()
                        chek = hashlib.md5(data).hexdigest()
                        mapsysnet[file] = chek
                except:
                    listToUpdate.add(file)
            
            for file in listNetFiles:
                if file in listSysFiles:
                    if mapnet[file]!= mapsysnet[file]:
                        listToUpdate.add(file) # update
                else:
                    listToUpdate.add(file) # new
            for file in listSysFiles:
                if not file in listNetFiles:
                    listToErase.append(file) # erase
                    
            listToUpdate = list(listToUpdate)
            ids=[]
            for file in listToUpdate:
                ids.append(mapids[file])
            
            data = self.m_qjsonnetwork.callDirect("rechargeNetStep2",
                                       "model.thesamodule.thesamodule.read", 
                                       [ids,["filebinary","filename",],preferences])
            errors=[]
            if not data["data"]=="error":
                resultnet = data["data"]["result"]
                for file in resultnet:
                    filename = DIR_QML_SYS+QDir.separator()+file["filename"]
                    qfile = QFile(filename)
                    if qfile.open(QIODevice.WriteOnly) == False:
                        errors.append(filename)
                        print("error",filename,qfile.errorString())
                    else:
                        print("update",file["filename"])
                        bafile= QByteArray.fromBase64(file["filebinary"]["base64"].encode())
                        qfile.write(bafile)
                        qfile.close()
            if len(errors)>0:
                self.m_qjsonnetwork.signalResponse.emit("systemnet",33,{"error":errors})  
                return False
            
            #erase
            for file in listToErase:
                print("moviendo", file)
                shutil.move(DIR_QML_SYS + QDir.separator() +file, DIR_QML_SYS_LOST + QDir.separator()+file)
            return True
        else:
            #erase all files, no conexion con thesa module
            for file in listSysFiles:
                print("moviendo", file)
                shutil.move(DIR_QML_SYS + QDir.separator() +file, DIR_QML_SYS_LOST + QDir.separator()+file)
            self.m_qjsonnetwork.signalResponse.emit("systemnet",34,{"error":""})    
            return False
        
