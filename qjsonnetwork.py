#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jan  5 01:57:03 2020

this file is part the thesa: tryton client based PySide2(qml2)
qjsonnetwork is basic connector json-rpc async or sync

"""
__author__ = "Numael Garay"
__copyright__ = "Copyright 2020-2021"
__license__ = "GPL"
__version__ = "1.8" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

import requests
import json
import base64
import time

from PySide2.QtCore import QObject, QFile, Slot, Signal, QJsonArray, SIGNAL, SLOT, QJsonValue, QJsonParseError, QJsonDocument
from PySide2.QtCore import QEventLoop, QByteArray, QDateTime, QIODevice, QDir, QUrl, QGenericArgument, QMetaObject, QThread

import PySide2.QtNetwork
from PySide2.QtNetwork import QNetworkAccessManager, QNetworkRequest, QNetworkReply
from PySide2.QtGui import QDesktopServices

from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtWidgets import QMessageBox, QCheckBox, QInputDialog, QLineEdit

class templateResqError:
    text = "error"
    status_code = None
    reason = "Connection refused"
    content = ""
    
class WorkerRequests(QObject):
    finished = Signal(int)
    result = templateResqError()
    url = ""
    params = []
    headers = {}
    def url_data(self, url, params, headers):
        self.url = url
        self.params = params
        self.headers = headers
        
    def _run_(self):
        try:
            self.result = requests.post(self.url, data=self.params, headers=self.headers, timeout=30)
        except:
            pass
            # self.result = templateResqError()
        finally:
            self.finished.emit(0)
        self.finished.emit(0)
        
    def getResult(self):
        return self.result
    
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
        
        self.managerAccess = QNetworkAccessManager(self)
        self.managerAccess.finished[QNetworkReply].connect(self.replyFinishedOrder)
        
        self.requestPython = True # in PySide select library resquest python by default
        
    @Slot(str)
    def setVersionTryton(self, ver):
        self.versionct=ver
        
    def setEngine(self, engine):#QQmlApplicationEngine *engine=nullptr);
        self.m_engine = engine
    
    @Slot()
    def forceNotRun(self):
        self.boolRun=False
        
    def selectRequestPython(self, boolRP):
        self.requestPython = boolRP
    
    def clearMessagesWarning(self):
        root = self.m_engine.rootObjects()[0]
        QMetaObject.invokeMethod(root, "clearMessages")
        
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
                    if self.tempCallData.at(0).toBool()==True: #// call direct obsolete, better to use recursivecall
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
            #data = reply.readAll()
            self.processingData(reply)
           # reply.deleteLater()
            
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
        self.urlServerPython=url
    
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
        self.clearMessagesWarning()
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
        if self.boolRecursive == False:
            self.clearMessagesWarning()
        resultObject={}
        if self.boolRun==False:
            self.boolRun=True
            self.boolDirect=True
            self.mtypeCall="order"
            self.mpid=pid
            self.mmethod=method
            self.mparams=par
            
            if self.requestPython:
                response = self.data_request_python()
                resultObject = self.processingDataPython(response)
                return resultObject
            else:
                bparams = self.prepareParams()
                request = self.prepareRequest()
        
                reply = self.data_request(request, bparams)
                resultObject = self.processingData(reply)
                return resultObject
            
        else:
            resultObject["data"] = "error"
            if pid != self.mpid:
                self.signalResponse.emit("run@", 8, {})
            return resultObject
        
    def data_request_python(self):
        if self.mpid != "open@" and self.mpid != "desconect":
            auth = '{0}:{1}:{2}'.format(self.usuario, self.token[0], self.token[1])
            auth = b'Session '+ base64.b64encode(auth.encode())
            headers = {'content-type': 'application/json', 'authorization': auth}
        else:
            headers = {'content-type': 'application/json'}
        params=json.dumps({
                "method": self.mmethod,
                "params": self.mparams.toVariantList(),
                "id": self.getId()
                })
        obj_requests = WorkerRequests()
        obj_requests.url_data(self.urlServerPython, params, headers)
        thread = QThread()
        obj_requests.moveToThread(thread)
        thread.started.connect(obj_requests._run_)
        obj_requests.finished.connect(thread.quit)
        connection_loop = QEventLoop()
        thread.finished.connect(connection_loop.quit)
        thread.start()
        connection_loop.exec_()
        response = obj_requests.getResult()
        #del obj_requests
        return response
        
    def data_request(self, request, bparams):
        ## possible bug of QNetworkAccessManager in PySide 
        ## crash deallocating
        connection_loop = QEventLoop()
        QObject.connect(self.managerAccess, SIGNAL("finished( QNetworkReply* )"), connection_loop, SLOT( "quit()" ))
        reply = self.managerAccess.post(request, bparams)
        connection_loop.exec_()#sleep
        #reply->bytesAvailable();
        #reply.deleteLater()
        return reply
        
    def processingDataPython(self, response):
        data = response.text
        error = False
        errorString = ""
        statusCode = response.status_code
        reasonPhrase = response.reason
        if statusCode == 200:
            data = response.json()
        else:
            error = True
        
        resultObject = {
                "status": statusCode,
                "reasonPhrase": reasonPhrase,
                "errorString": errorString
                }
    
        if self.mpid=="open@":
            resultObject["credentials"]=False
        if error == False:
            if self.mpid=="open@":
                if data.__class__()=={} and data.__contains__("result"):
                    if data["result"].__class__()==[]:
                        self.token = data["result"]
                        self.boolConnect = True
                        self.intCountConnect+=1
                        resultObject["credentials"] = True
            resultObject["data"] = data
            if self.boolDirect==False:
                self.signalResponse.emit(self.mpid, 2, resultObject)#ok

            else:                                  
                if self.mpid=="open@" and data.__contains__("error")==False and self.boolRecursive == False:
                    resultObject["extra"] = "direct"
                    self.signalResponse.emit(self.mpid, 2, resultObject)
                elif data.__contains__("error")==True:
                    if self.boolRecursive==True:
                        if data["error"].__class__() == [] and data["error"].__contains__("UserWarning") == False and data["error"][0].__contains__("403") == False and data["error"][0].__contains__("401") == False:
                            self.signalResponse.emit(self.mpid, 2, resultObject)
                            if self.mpid != "open@":
                                resultObject["data"] = "error"
                    elif self.mpid!="desconect":
                        self.signalResponse.emit(self.mpid, 2, resultObject)
        else:
            # print(error, statusCode, errorString)
            if self.boolRecursive==True:
                if statusCode!=401 and statusCode!=403:
                    self.signalResponse.emit(self.mpid, 3, resultObject)#//error comunicacion
            else:
                if self.mpid!="desconect":
                    self.signalResponse.emit(self.mpid, 3, resultObject)#//error comunicacion
            # if self.boolDirect:
            if statusCode==401 or statusCode==403:
                resultObject["data"] = statusCode
            else:
                resultObject["data"] = "error"
        self.boolRun=False
        return resultObject
        
        
    def processingData(self, reply):
        parseError = QJsonParseError()
        error = reply.error()
        data = reply.readAll()
        errorString = reply.errorString()
        statusCode = reply.attribute(QNetworkRequest.HttpStatusCodeAttribute)
        reasonPhrase = reply.attribute(QNetworkRequest.HttpReasonPhraseAttribute)
        redirectUrl = QUrl(reply.attribute(QNetworkRequest.RedirectionTargetAttribute))
        redirectUrlFix = self.redirectUrlComp(redirectUrl, self.urlServer)
        resultObject = {
                "status": statusCode,
                "reasonPhrase": reasonPhrase,
                "errorString": errorString
                }
        result = "error"
    #    QJsonValue result=false; Bug QJsonValue(True)
        resultObject["data"] = "error"
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
                        self.signalResponse.emit(self.mpid, 4, resultObject)
                        result = "error"
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
                                    if self.mpid != "open@":
                                        resultObject["data"] = "error"
                            elif self.mpid!="desconect":
                                self.signalResponse.emit(self.mpid, 2, resultObject)
        else:
            print(error, statusCode, errorString)#, resultObject)
            if self.boolRecursive==True:
                if statusCode!=401 and statusCode!=403:
                    self.signalResponse.emit(self.mpid, 3, resultObject)#//error comunicacion
            else:
                if self.mpid!="desconect": 
                    self.signalResponse.emit(self.mpid, 3, resultObject)#//error comunicacion
            if statusCode==401 or statusCode==403:
                resultObject["data"] = statusCode
            else:
                resultObject["data"] = "error"
        self.boolRun=False
        reply.deleteLater()
        return resultObject
    
    @Slot(str, str, int, int)
    @Slot(str, str, int, int, "QJsonObject")
    def openReport(self, name, model, id, action_id, attributes={}):
        method = "report.%s.execute"%model
        attributes["model"] = model
        attributes["ids"] = [id]
        attributes["id"] = id
        attributes["action_id"] = action_id
        params = QJsonArray()
        qid = QJsonArray()
        qid.append(id)
        params.append(qid)
        params.append(attributes)
        params.append(self.preferences)
        # params = [[id], attributes, self.preferences]
        self.runReport(name, method, params)
            
    @Slot(str, str, QJsonArray)
    def runReport(self, pid, method, params):#recursive
        result = self.recursiveCall("runReport_"+pid, method ,params)
        data = result["data"]
        if data != "error" and data.__class__() == {}:
            if data.__contains__("result")==True and data["result"].__class__() == []:

                mid = params.toVariantList()[1].get("id",-1)
                namereport = "%s (%s).%s"%(pid,str(mid),data["result"][0])
                    
                mdir = QDir(self.mDir + QDir.separator() + "tempReports")
                if mdir.exists()==False:
                    s=QDir(self.mDir)
                    s.mkdir("tempReports")

                filename = self.mDir+ QDir.separator() +"tempReports"+ QDir.separator() + namereport
                file = QFile(filename)
                if file.open(QIODevice.WriteOnly) == False:
                    #error
                    self.signalResponse.emit(self.mpid,7,{})
                    print("error",filename,file.errorString())
                else:
                    bafile= QByteArray.fromBase64(data["result"][1]["base64"].encode())
                    file.write(bafile)
                    file.close()
                    QDesktopServices.openUrl(QUrl.fromLocalFile(filename))
            else:
                self.signalResponse.emit(self.mpid,7,{})
        else:
            self.signalResponse.emit(self.mpid,7,{})
        
           
    def prepareRequest(self):
        request = QNetworkRequest()
        request.setUrl(self.urlServer)
        request.setRawHeader(QByteArray(b"content-type"), QByteArray(b"application/json"))
        request.setRawHeader(QByteArray(b"charset"), QByteArray(b"utf-8") )
        if self.mpid != "open@" and self.mpid != "desconect":
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
        self.clearMessagesWarning()
        self.boolRecursive = True
        result = self.callDirect(pid, method, par)
        if result["data"].__class__()=={} and result["data"].__contains__("result"):
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
    
       
