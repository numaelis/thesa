#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 17 23:31:52 2020
this file is part the thesa: tryton client based PySide2(qml2)
tools functions help
"""

__author__ = "Numael Garay"
__copyright__ = "Copyright 2020-2021"
__license__ = "GPL"
__version__ = "1.8" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

from PySide2.QtCore import QObject, QJsonArray, Slot, Signal, QDate, QFileInfo, QDir, QIODevice, QFile, Qt, QSettings, QTranslator, QLocale, QUrl
from PySide2.QtWidgets import QFileDialog
from PySide2.QtGui import QImage, QImageWriter, QDesktopServices
from PySide2.QtNetwork import QSslSocket
import json

class Tools(QObject):
    def __init__(self, parent = None):
        QObject.__init__(self, parent)
        self.mpid=""
        self.mDir=QDir.currentPath()
        self.mApp=parent
        
    signalResponsePickerImage = Signal(str, int, str)
    
    @Slot(int, int, result=QJsonArray)
    def calendarMonth(self, anno, mes):
        lista = QJsonArray()
        mmap = {}
            
        dateFirtDay = QDate(anno,mes,1)
        daysMes = dateFirtDay.daysInMonth()
        dayWeekFirst  = dateFirtDay.dayOfWeek()
        if(dayWeekFirst==1):
            dayWeekFirst=8
        
        dateLast1 = dateFirtDay.addDays(-(dayWeekFirst-1))
        diaLast1 = dateLast1.day()
        mesLast = dateLast1.month()
        annoLast = dateLast1.year()
    
        dateNext1 = dateFirtDay.addDays(daysMes)
        mesNext = dateNext1.month()
        annoNext = dateNext1.year()
        
        for i in range(0, dayWeekFirst-1):
       # for(int i=0, len = dayWeekFirst-1; i<len;i++):
            mmap["dia"]=diaLast1+i
            mmap["mes"]=mesLast
            mmap["anno"]=annoLast
            mmap["type"]=-1
            lista.append(mmap)
            
        for i in range(1, daysMes+1):
        #for(int i=1, len = daysMes; i<=len;i++):
            mmap["dia"]=i
            mmap["mes"]=mes
            mmap["anno"]=anno
            mmap["type"]=0
            lista.append(mmap)
            
        for i in range(1,(42-daysMes-(dayWeekFirst-1))+1):
        #for(int i=1, len = (42-daysMes-(dayWeekFirst-1)); i<=len;i++):
            mmap["dia"]=i
            mmap["mes"]=mesNext
            mmap["anno"]=annoNext
            mmap["type"]=1
            lista.append(mmap)

        return lista
    
    @Slot(int, int, result=int)
    def calendarLastDay(self, anno, mes):
        dateFirtDay = QDate(anno,mes,1)
        return dateFirtDay.daysInMonth()
    
    @Slot(result=QJsonArray)
    @Slot(str, result=QJsonArray)
    def calendarShortNamesDays(self, language=""):
        if language=="":
            language = QLocale.system().name()
        myLocale = QLocale(language)
        lista = QJsonArray()
        for i in range(1,8):
            lista.append(myLocale.dayName(i,QLocale.ShortFormat))
        return lista
    
    @Slot(result=QJsonArray)
    @Slot(str, result=QJsonArray)
    def calendarShortNamesMonths(self, language=""):
        if language=="":
            language = QLocale.system().name()
        myLocale = QLocale(language)
        lista = QJsonArray()
        for i in range(1,13):
            lista.append(myLocale.monthName(i,QLocale.ShortFormat))
        return lista
    
    @Slot(result=QJsonArray)
    @Slot(str, result=QJsonArray)
    def calendarLongNamesDays(self, language=""):
        if language=="":
            language = QLocale.system().name()
        myLocale = QLocale(language)
        lista = QJsonArray()
        for i in range(1,8):
            lista.append(myLocale.dayName(i,QLocale.LongFormat))
        return lista
    
    @Slot(result=QJsonArray)
    @Slot(str, result=QJsonArray)
    def calendarLongNamesMonths(self, language=""):
        if language=="":
            language = QLocale.system().name()
        myLocale = QLocale(language)
        lista = QJsonArray()
        for i in range(1,13):
            lista.append(myLocale.monthName(i,QLocale.LongFormat))
        return lista
    
    @Slot(result="QJsonObject")
    @Slot(str,result="QJsonObject")
    def getImagePath(self, caption="find images"):
        return self.getFilePath(caption, "Images (*.png *.xpm *.jpg *.gif *.jpeg *.bmp *ppm)")
    
    @Slot(result="QJsonObject")
    @Slot(str,result="QJsonObject")
    @Slot(str, str, result="QJsonObject")
    def getFilePath(self, caption="find", filters=""):
        result={}
        result["error"]=True
        result["name"]=""
        result["fullname"]=""
        #"Buscar Imagen Nueva",
        #tr("Imagenes (*.png *.xpm *.jpg *.gif *.jpeg *.bmp *ppm)")
        namefile = QFileDialog.getOpenFileName(None, caption,
                                                     QDir.homePath(),
                                                     filters
                                                     )
        if namefile[0]!="":
            result["error"] = False
            result["name"] = QFileInfo(namefile[0]).fileName()
            result["fullname"] = namefile[0]
        return result
    
    @Slot(str, result=str)
    def getFileBase64(self, path):
        qfile = QFile(path)
        if not qfile.open(QIODevice.ReadOnly):
            return ""
        else:
            data = qfile.readAll()
            qfile.close()
            return str(data.toBase64().data().decode('utf-8'))
    
    @Slot(str)
    @Slot(str, str)
    def openImagePicker(self, pid, caption = "find images"):
        self.mpid=pid
        jobj = self.getImagePath(caption)
        self.signalResponsePickerImage.emit(self.mpid, 0, jobj["fullname"])
    
    @Slot(int, str, result=str)
    def scaleImage(self, pixels, path):
        dircache = QDir(self.mDir + QDir.separator() + "imagecache")
        if dircache.exists()==False:
            s=QDir(self.mDir)
            s.mkdir("imagecache")
   
        ima = QImage(path)
        wids=ima.width()
        heis=ima.height()
        if (wids > pixels or heis > pixels):
            imarescale = ima.scaledToWidth(pixels, Qt.SmoothTransformation) if (wids > heis) else  ima.scaledToHeight(pixels, Qt.SmoothTransformation)
    
            newImagePath = dircache.path() + QDir.separator() + "_temp_scaled_" + QFileInfo(path).fileName()
            imawriter = QImageWriter()
            imawriter.setFileName(newImagePath)
            #    imawriter.setFormat("png");
            if (imawriter.write(imarescale)):
                #qDebug()<<"si path"<<newImagePath
                return  newImagePath
            else:
                #qDebug()<<"no path"<<newImagePath;
                return path
            
        return path
    
    @Slot()
    def clearCache(self):
        self.clearCacheScaleImage()
        self.clearCacheReports()
        
    @Slot()
    def clearCacheScaleImage(self):
        dirci = QDir(self.mDir + QDir.separator() + "imagecache");
        if dirci.exists():
            listFiles = []
            listFiles = dirci.entryList(QDir.Files)
            for sdfile in listFiles:
                QDir().remove(dirci.path() + QDir.separator() + sdfile)
    
    @Slot()
    def clearCacheReports(self):
        dirci = QDir(self.mDir + QDir.separator() + "tempReports");
        if dirci.exists():
            listFiles = []
            listFiles = dirci.entryList(QDir.Files)
            for sdfile in listFiles:
                QDir().remove(dirci.path() + QDir.separator() + sdfile)
            
    @Slot(str, result=bool)
    def fileExists(self, path):
        return QFileInfo.exists(path)
    
    @Slot(str)
    def callPhone(self, number):
        QDesktopServices.openUrl("tel://"+number)
    
    @Slot(result=QJsonArray)
    def getListCoreTranslations(self):
        dircorelan = QDir(self.mDir + QDir.separator() + "corelocale");
        if dircorelan.exists():
           fileNames = dircorelan.entryList(["*.qm"])
           listLocale = QJsonArray()
           for i in range(len(fileNames)):
               locale = ""
               locale = fileNames[i]
               locale = locale.split('.')[0]
               listLocale.append(locale)
           listLocale.append("en")
           return listLocale
        return QJsonArray()
    
    @Slot(str, QSettings)
    def selectCoreTranslation(self, language, settings):
        settings.setValue("translate","en")
        dircorelan = QDir(self.mDir + QDir.separator() + "corelocale");
        if dircorelan.exists():
            if QFileInfo(dircorelan.path() + QDir.separator() + language+".qm").exists():
                settings.setValue("translate",language)
                translator = QTranslator(self)
                translator.load(dircorelan.path() + QDir.separator() + language)
                self.mApp.installTranslator(translator)
            else:
                language = language.split('_')[0]
                if len(language)==2:
                    if QFileInfo(dircorelan.path() + QDir.separator() + language+".qm").exists():
                        settings.setValue("translate",language)
                        translator = QTranslator(self)
                        translator.load(dircorelan.path() + QDir.separator() + language)
                        self.mApp.installTranslator(translator)
    
    @Slot(str, bool)
    def selectSystemTranslation(self, language, typemodule):
        dirsystem = "systemnet" if typemodule==True else "system"
        dirsyslan = QDir(self.mDir + QDir.separator() + dirsystem)
        if dirsyslan.exists():
            if QFileInfo(dirsyslan.path() + QDir.separator() + language+".qm").exists():
                translator = QTranslator(self)
                translator.load(dirsyslan.path() + QDir.separator() + language)
                self.mApp.installTranslator(translator)
            else:
                language = language.split('_')[0]
                if len(language)==2:
                    if QFileInfo(dirsyslan.path() + QDir.separator() + language+".qm").exists():
                        translator = QTranslator(self)
                        translator.load(dirsyslan.path() + QDir.separator() + language)
                        self.mApp.installTranslator(translator)
                    
        
    @Slot(str, str, bool, bool, result='QJsonObject')
    def executeQuerySqlite(self, dbname, query, iscommit, isselect):
        print(query)
        try:
            myresult = {'status':True, 'result': ''}
            import sqlite3
            con = sqlite3.connect(self.mDir + QDir.separator() + dbname)
            cur = con.cursor()
            cur.execute(query)
           # cur.execute('''CREATE TABLE stocks
           #    (date text, trans text, symbol text, qty real, price real)''')
            #CREATE TABLE IF NOT EXISTS some_table (id INTEGER PRIMARY KEY AUTOINCREMENT, ...);
            #cur.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")
            
            if iscommit:
                con.commit()
            
            if isselect:
                myresult['result']=json.loads(json.dumps(cur.fetchall()))
                print(myresult)
            con.close()
            return myresult
        except:
            return {'status':False, 'result': ''}
    
    @Slot(result=bool)
    def supportsSsl(self):
        return QSslSocket.supportsSsl()
