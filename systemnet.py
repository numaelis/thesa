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
__version__ = "1.4" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

from PySide2.QtCore import QObject, QJsonArray, Slot, Signal, QDate, QDir, QByteArray, QIODevice, QFile
import os
import hashlib
import shutil

class SystemNet(QObject):
    def __init__(self, jsonnet, parent = None):
        QObject.__init__(self, parent)
        self.m_qjsonnetwork = jsonnet
        self.mDir=QDir.currentPath()
        
    signalRespuestaData = Signal(str, int, "QJsonObject")#QJsonObject = dict
    
    @Slot("QJsonObject", result=bool)    
    def rechargeNet(self, preferences):
        #[[],0,200,[],["checksum","filename"],{}])
#        data = self.m_qjsonnetwork.callDirect("version internal",
#                                       "model.thesamodule.config.search_read", 
#                                       [[],0,1,[],["internal_version"],preferences])
        
        sysdir = QDir(self.mDir + QDir.separator() + "systemnet")
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
        
