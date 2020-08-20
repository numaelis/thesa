#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jan  5 01:57:03 2020

this file is part the thesa: tryton client based PySide2(qml2)
qjsonnetwork is basic connector json-rpc async or sync

"""
__author__ = "Numael Garay"
__copyright__ = "Copyright 2020"
__license__ = "GPL"
__version__ = "1.4" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

from PySide2.QtCore import QObject, QFile, Slot, Signal, QJsonArray, SIGNAL, SLOT, QJsonValue, QJsonParseError, QJsonDocument
from PySide2.QtCore import QEventLoop, QByteArray, QDateTime, QIODevice, QDir, QUrl, QGenericArgument, QMetaObject

import PySide2.QtNetwork
from PySide2.QtNetwork import QNetworkAccessManager, QNetworkRequest, QNetworkReply
from PySide2.QtGui import QDesktopServices

from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtWidgets import QMessageBox, QCheckBox, QInputDialog, QLineEdit

class QJsonNetwork(QObject):
    def __init__(self, parent = None):
        QObject.__init__(self, parent)
        self.parent = parent
        self.usuario=""
        self.password=""
        self.token=[]
        self.mmethod=""
        self.mpid = ""
        self.mparams = []
        self.mid=0
        self.boolConnect=False
        self.intCountConnect=0
        self.intReply=0
        self.intReplyMax=2
        self.urlServer = QUrl()
        self.versionct = "4" #trytond
        self.mhost=""
        self.mdbase=""
        self.mport=""
        self.preferences = {}
        self.boolRun=False
        self.boolDirect=False
        self.boolRecursive = False
        self.mtypeCall="order"
        self.mDir=QDir.currentPath()
        
        self.tempCallData = QJsonArray()
        self.tempCallFunctionArgs = QJsonArray()
        
        self.m_engine = QQmlApplicationEngine()
        
#        connect(managerAccess, SIGNAL(finished(QNetworkReply*)),
#            this, SLOT(replyFinishedOrder(QNetworkReply*)));
        self.managerAccess = QNetworkAccessManager(self)
        self.managerAccess.finished[QNetworkReply].connect(self.replyFinishedOrder)
#        self.connect(self.managerAccess, SIGNAL("finished(QNetworkReply*)"),
#                     self, self.replyFinishedOrder)
        ##ifndef QT_NO_SSL
#        self.connect(self.managerAccess, SIGNAL("sslErrors(QNetworkReply *, const QList<QSslError> &)"),
#                     self, self.slotSslError)
    @Slot(str)
    def setVersionTryton(self, ver):
        self.versionct=ver
        
    def setEngine(self, engine):#QQmlApplicationEngine *engine=nullptr);
        self.m_engine = engine
        
    @Slot()
    def saveLastCall(self):
        self.tempCallData.append(self.boolDirect)
        self.tempCallData.append(self.mtypeCall)
        self.tempCallData.append(self.mpid)
        self.tempCallData.append(self.mmethod)
        self.tempCallData.append(self.mparams)
    
    @Slot()
    def runLastCall(self):
        if not self.tempCallData.isEmpty():
            if self.tempCallData.count()==5:
                if str(self.tempCallData.at(1).toString())=="order":
                    if self.tempCallData.at(0).toBool()==True: #// call direct obsolete, betterbetter to use recursivecall
                        if not self.tempCallFunctionArgs.isEmpty():
                            nameObject = self.tempCallFunctionArgs.at(0).toString()
                            nameFunction = self.tempCallFunctionArgs.at(1).toString()
                            root =  self.m_engine.rootObjects()[0]
                            object_qml = root.findChild(QObject, nameObject)
                            if self.tempCallFunctionArgs.at(2).isArray():
                                args = self.tempCallFunctionArgs.at(2).toArray()#.toVariantList()
                                if args.count()==0:
                                    QMetaObject.invokeMethod(object_qml, nameFunction)
                                else:
                                    root.setProperty("argsFucntionLastCall",args)
                                    QMetaObject.invokeMethod(object_qml, nameFunction)
#                                    https://bugreports.qt.io/browse/PYSIDE-1262
#                                    Q_ARG missing, invokeMethod doesn't work currently with arguments in PySide2.
#                                if args.count()==1:
#                                    print("\nnnn",args.at(0),"\nnnnn")
#                                    QMetaObject.invokeMethod(object_qml, nameFunction,
#                                                              QGenericArgument(QByteArray(b'QVariant'), 69))
#                                
#                                if args.count()==2:
#                                    QMetaObject.invokeMethod(object_qml, nameFunction,
#                                                              QGenericArgument('QVariant', args.at(0)),
#                                                              QGenericArgument('QVariant', args.at(1)))
#                                
#                                if args.count()==3:
#                                    QMetaObject.invokeMethod(object_qml, nameFunction,
#                                                              QGenericArgument('QVariant', args.at(0)),
#                                                              QGenericArgument('QVariant', args.at(1)),
#                                                              QGenericArgument('QVariant', args.at(2)))
#                                
#                                if args.count()==4:
#                                    QMetaObject.invokeMethod(object_qml, nameFunction,
#                                                              QGenericArgument('QVariant', args.at(0)),
#                                                              QGenericArgument('QVariant', args.at(1)),
#                                                              QGenericArgument('QVariant', args.at(2)),
#                                                              QGenericArgument('QVariant', args.at(3)))
#                        
                    else:
                        self.call(self.tempCallData.at(2).toString(),
                                self.tempCallData.at(3).toString(),
                                self.tempCallData.at(4).toArray()
                                )
                    
                
                if self.tempCallData.at(1).toString()=="report":
                    self.runReport(self.tempCallData.at(2).toString(),
                                self.tempCallData.at(3).toString(),
                                self.tempCallData.at(4).toArray()
                            )
                
        self.tempCallData = QJsonArray()
        self.tempCallFunctionArgs = QJsonArray()
    
    @Slot("QNetworkReply*")
    def replyFinishedOrder(self, reply):
        if self.boolDirect==False:
            data = reply.readAll()
            self.processingData(data, reply)
            reply.deleteLater()
            
    @Slot("QNetworkReply*", "const QList<QSslError> &")        
    def slotSslError(self, reply, errors):
        for error in errors:
            print("ssl error", error.errorString())
#        foreach (const QSslError &error, errors)
#            fprintf(stderr, "SSL error: %s\n", qPrintable(error.errorString()));

    signalResponse = Signal(str, int, "QJsonObject")
    
    def getId(self):
        self.mid+=1
        return  self.mid
    
    #QUrl redirectUrlComp(const QUrl& possibleRedirectUrl,const QUrl& oldRedirectUrl) const;
    def redirectUrlComp(self, possibleRedirectUrl, oldRedirectUrl):
        redirectUrl = QUrl()
        if possibleRedirectUrl.isEmpty()==False and possibleRedirectUrl != oldRedirectUrl:
            redirectUrl = possibleRedirectUrl
        return redirectUrl
    
    @Slot(result = bool)    
    def isRunning(self):
        if self.boolRecursive==True:
            return True
        return self.boolRun
    
    @Slot(str, str, str, str, str)
    @Slot(str, str, str, str, str, bool)
    def openConect(self, usu, passw, host, port, dbase, direct  = False):
        self.usuario=usu
        self.password=passw
        self.mhost=host
        self.mdbase=dbase
        self.mport=port
        url = host+":"+port+"/"+dbase+"/"
        self.urlServer=QUrl(url)
    
        self.token.clear()
        self.boolConnect=False
        marray = QJsonArray()
        if self.versionct == "4":
            marray.append(self.usuario)
            marray.append(self.password)
            if direct:
                return self.callDirect("open@","common.db.login", marray)
            else:
                self.call("open@","common.db.login", marray)
        else:
            marray.append(self.usuario)
            marray.append({"password":self.password})
#            mapass = QJsonValue({"password",self.password})
#            marray.append(mapass.toObject())
            if direct:
                return self.callDirect("open@","common.db.login", marray)
            else:
                self.call("open@","common.db.login", marray)
    
    @Slot(str, str, QJsonArray)
    def call(self, pid, method, par):
        if self.boolRun==False:
            self.boolRun=True
            self.boolDirect=False
            self.mtypeCall="order"
            self.mpid=pid
            self.mmethod=method
            self.mparams=par
            self.initOrderConnect()
        else:
            if pid != self.mpid:
                self.signalResponse.emit("run@", 8, {})

    @Slot()
    def initOrderConnect(self):
        bparams = self.prepareParams()
        request = self.prepareRequest()
        self.managerAccess.post(request, bparams)
#        reply.readyRead.connect(self.slotReadyRead)
#        reply.error[QNetworkReply.NetworkError].connect(self..slotError)
#        reply.sslErrors.connect(self.slotSslErrors)

    @Slot(QJsonArray)
    def saveFunction(self, by403):
        if by403.count()==3:#objectqml functon args
            self.tempCallFunctionArgs = by403        
        else:
            self.tempCallFunctionArgs = QJsonArray()
                
    @Slot(str, str, QJsonArray, result = "QJsonObject")    
    def callDirect(self, pid, method, par):
        resultObject={}
        if self.boolRun==False:
            self.boolRun=True
            self.boolDirect=True
            self.mtypeCall="order"
            self.mpid=pid
            self.mmethod=method
            self.mparams=par
        
            bparams = self.prepareParams()
            request = self.prepareRequest()
    
            reply = self.data_request(request, bparams)
            data = reply.readAll()##        QByteArray 
            parseError = QJsonParseError()
            
            resultObject["data"] = "error"
            document = QJsonDocument.fromJson(data, parseError)
            
            error = reply.error()
            statusCode = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
            if QNetworkReply.NoError==error:
                if parseError.error==True:
                    resultObject["data"] = "error"
                else:
                    if document.isObject():
                        jv=document.object()
                        if jv.__contains__("result"):
                            resultObject["data"] = jv
                        else:
                            if self.boolRecursive:
                                if jv.__contains__("error"):
                                    if jv["error"].__class__() == []:
                                        if jv["error"].__contains__("UserWarning") or jv["error"][0].__contains__("403") or jv["error"][0].__contains__("401"):
                                            resultObject["data"] = jv
                                        elif self.mpid == "open@":
                                            resultObject["data"] = jv                                                
                    else:
                        if document.isArray()==True:
                            resultObject["data"] = document.array()
                        else:
                            resultObject["data"] = "error"
            else:
                if statusCode==401 or statusCode==403:
                    resultObject["data"] = statusCode
                
            self.processingData(data, reply)# cath 
            return resultObject
        else:
            resultObject["data"] = "error"
            if pid != self.mpid:
                self.signalResponse.emit("run@", 8, {})
            return resultObject
        
    def data_request(self, request, bparams):
        connection_loop = QEventLoop()
        QObject.connect(self.managerAccess, SIGNAL("finished( QNetworkReply* )"), connection_loop, SLOT( "quit()" ))
        reply = self.managerAccess.post(request, bparams)
        connection_loop.exec_()#sleep
        #reply->bytesAvailable();
        reply.deleteLater()
        return reply
    
    def processingData(self, data, reply):
        parseError = QJsonParseError()
        error = reply.error()
        
        errorString = reply.errorString()
        statusCode = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
        fraseStatusCode = reply.attribute(QNetworkRequest.HttpReasonPhraseAttribute)
        redirectUrl = QUrl(reply.attribute(QNetworkRequest.RedirectionTargetAttribute))
        redirectUrlFix = self.redirectUrlComp(redirectUrl, self.urlServer)
#        print(errorString, statusCode)
        resultObject = {
                "status": statusCode,
                "fraseStatus": fraseStatusCode,
                "errorString": errorString
                }
        result = False
    #    QJsonValue result=false; Bug QJsonValue(True)
        if self.mpid=="open@":
            resultObject["credentials"]=False
        if QNetworkReply.NoError==error:
                if redirectUrlFix.isEmpty() == False:
                    if self.boolDirect==False:
                        print("se redireciona",redirectUrl)
                        self.urlServer = redirectUrl
                        self.initOrderConnect()
                        self.signalResponse.emit(self.mpid, 1,resultObject)
                else:
                    document = QJsonDocument.fromJson(data, parseError)
                    if parseError.error==True:
                        resultObject["data"] = data.__str__()
                        self.signalResponse.emit(self.mpid, 4, resultObject)#redireccion
                    else:
                        if document.isArray()==True:
                            result = document.array()
                        else:#supuestamente es un object json
                            if self.mpid=="open@":
                                if document.object().__contains__("result")==True:
                                    if document.object()["result"].__class__()==[]:
                                        if document.object()["result"].__len__()==2:
                                            self.token = document.object()["result"]
                                            self.boolConnect = True
                                            self.intCountConnect+=1
                                            resultObject["credentials"] = True
                            result = document.object()
                    resultObject["data"] = result
                    if self.boolDirect==False:
                        self.signalResponse.emit(self.mpid, 2, resultObject)#ok

                    else:
                        #and report                                    
                        if self.mpid=="open@" and result.__contains__("error")==False and self.boolRecursive == False:
                            resultObject["extra"] = "direct"
                            self.signalResponse.emit(self.mpid, 2, resultObject)
#                        elif self.mpid=="open@" and result.__contains__("error")==False and resultObject["credentials"] == False and self.boolRecursive == True:
#                            self.signalResponse.emit(self.mpid, 2, resultObject)
                        elif result.__contains__("error")==True:
                            if self.boolRecursive==True:
                                if result["error"].__class__() == [] and result["error"].__contains__("UserWarning") == False and result["error"][0].__contains__("403") == False and result["error"][0].__contains__("401") == False:
                                    self.signalResponse.emit(self.mpid, 2, resultObject)
                            elif document.isObject():
                                self.signalResponse.emit(self.mpid, 2, resultObject)
        else:
            print(error, statusCode, errorString)#, resultObject)
            if self.boolRecursive==True:
                if resultObject['status']!=401 and resultObject['status']!=403:
                    self.signalResponse.emit(self.mpid, 3, resultObject)#//error comunicacion
            else:
                self.signalResponse.emit(self.mpid, 3, resultObject)#//error comunicacion
        
        self.boolRun=False
#    void processingData(const QByteArray &data, QNetworkReply *reply);
            
    @Slot(str, str, QJsonArray)
    def runReport(self, pid, method, par):
        self.boolDirect = True
        self.mtypeCall ="report"
        self.mpid = pid
        self.mmethod = method
        self.mparams = par
#    
        bparams = self.prepareParams()
        request = self.prepareRequest()
#    
        reply = self.data_request(request, bparams)
        data = reply.readAll()
        parseError = QJsonParseError()
        resultObject={}
        resultObject["data"] = "error"
        document = QJsonDocument.fromJson(data, parseError)
        if parseError.error==True:
            resultObject["data"] = "error"
        else:
            if document.isObject():
                jv=document.object()
                if jv.__contains__("result")==True and jv["result"].__class__() == []:
                    #tryton 4.0
                    #'result': ['pdf', {'base64':wwwwww, '__class__':'bytes'}, False,'Printis']
                    jre = jv["result"]
                    namesecs = "tryton_"+self.mpid+ str(QDateTime.currentMSecsSinceEpoch())+"."+jre[0]
                    
    
                    mdir = QDir(self.mDir + QDir.separator() + "tempReports")
                    if mdir.exists()==False:
                        s=QDir(self.mDir)
                        s.mkdir("tempReports")

                    filename = self.mDir+ QDir.separator() +"tempReports"+ QDir.separator() + namesecs
                    file = QFile(filename)
                    if file.open(QIODevice.WriteOnly) == False:
                        #error
                        self.signalResponse.emit(self.mpid,7,{})
                        print("error",filename,file.errorString())
                    else:
                        bafile= QByteArray.fromBase64(jre[1]["base64"].encode())
                        file.write(bafile)
                        file.close()
                        QDesktopServices.openUrl(QUrl(filename))
            else:
                if document.isArray()==True:
                    self.signalResponse.emit(self.mpid,7,{})
        self.processingData(data, reply)
        
    def prepareRequest(self):
        request = QNetworkRequest()
        request.setUrl(self.urlServer)
        request.setRawHeader(QByteArray(b"content-type"), QByteArray(b"application/json"))
        request.setRawHeader(QByteArray(b"charset"), QByteArray(b"utf-8") )
        if self.mpid != "open@":
            tokenStr = self.usuario+":"+ str(int(self.token[0]))+":"+ str(self.token[1]) if self.token != [] else ""
            tokenByte = QByteArray(tokenStr.encode())
            tokenByteComplete = QByteArray(b"Session ") + tokenByte.toBase64()
            request.setRawHeader(QByteArray(b"authorization"), tokenByteComplete)

        return  request
        
    def prepareParams(self):
        objParams={
                "method": self.mmethod,
                "params": self.mparams,
                "id": self.getId()
                }
    
        return QJsonDocument(objParams).toJson(QJsonDocument.Compact)
    
    @Slot("QJsonObject")
    def setPreferences(self, preferences):
        self.preferences = preferences
    
    @Slot(str, str, QJsonArray, result = "QJsonObject")   
    def recursiveCall(self, pid, method, par):
        self.boolRecursive = True
        result = self.callDirect(pid, method, par)
        if result["data"].__contains__("result"):
            if self.mpid != "open@":
                self.boolRecursive = False    
                return result
        not_complete = True
        while not_complete:
            reValue = result["data"]
            if reValue.__class__()==0 and (reValue==401 or reValue==403):
                mok = False
                textinput = self.tr("Re-enter Password:")
                inputPass, mok = QInputDialog.getText(None, "Password", textinput, QLineEdit.Password)
                if mok:
                    result = self.openConect(self.usuario, inputPass, self.mhost, self.mport, self.mdbase, True)
                else:
                    not_complete = False
                    result['data']='error'
                    self.boolRecursive = False    
                    root = self.m_engine.rootObjects()[0]
                    QMetaObject.invokeMethod(root, "backLogin")
            elif reValue.__class__() == {}:
                if reValue.__contains__("result"):
                    if self.mpid != "open@":
                        not_complete = False
                    else:
                        if self.boolConnect:
                            result = self.callDirect(pid, method, par)
                        else:
                            mok = False
                            textinput = self.tr("Incorrect, Re-enter Password:")
                            inputPass, mok = QInputDialog.getText(None, "Incorrect Password", textinput, QLineEdit.Password)
                            if mok:
                                result = self.openConect(self.usuario, inputPass, self.mhost, self.mport, self.mdbase, True)
                            else:
                                not_complete = False
                                self.boolRecursive = False    
                                result['data']='error'
                                root = self.m_engine.rootObjects()[0]
                                QMetaObject.invokeMethod(root, "backLogin")
                elif reValue.__contains__("error"):
                    if reValue["error"].__class__() == []:
                        if 'UserWarning' in reValue["error"]:
                            cb = QCheckBox("Always ignore this warning.")
                            msgBox = QMessageBox()
                            msgBox.setText(reValue["error"][1][0])
                            msgBox.setInformativeText(reValue["error"][1][1])
                            msgBox.setStandardButtons(QMessageBox.No | QMessageBox.Yes)
                            msgBox.setDefaultButton(QMessageBox.Yes)
                            msgBox.setCheckBox(cb)
                            rbox = msgBox.exec_()
                            if rbox == QMessageBox.Yes:
                                result = self.callDirect(pid, 'model.res.user.warning.create', [
                                        [{'always': cb.isChecked(), 'user': self.token[0], 'name': reValue["error"][1][0]}], self.preferences
                                        ])
                                if result["data"].__contains__("result"):
                                    result = self.callDirect(pid, method, par)
                            else:
                                not_complete = False
                                result['data']='error'
                        elif reValue["error"][0].__contains__("403") or reValue["error"][0].__contains__("401"):
                            mok = False
                            textinput = self.tr("Re-enter Password:")
                            if reValue["error"][0].__contains__("401"):
                                textinput = "Authorization Required \n"+textinput
                            inputPass, mok = QInputDialog.getText(None, "Password", textinput, QLineEdit.Password)
                            if mok:
                                result = self.openConect(self.usuario, inputPass, self.mhost, self.mport, self.mdbase, True)
                            else:
                                not_complete = False
                                result['data']='error'
                                self.boolRecursive = False    
                                root = self.m_engine.rootObjects()[0]
                                QMetaObject.invokeMethod(root, "backLogin")
                        else:
                            not_complete = False
                    
                    else:
                        not_complete = False
            else:
                not_complete = False
        self.boolRecursive = False    
        return result
    
       