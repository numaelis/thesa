#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Jan  4 13:41:14 2020

this file is part the thesa: tryton client based PySide2(qml2)

qjsonmodel, basic model data list connect json-rpc

"""
__author__ = "Numael Garay"
__copyright__ = "Copyright 2020"
__license__ = "GPL"
__version__ = "1.0" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

from PySide2.QtCore import QObject, QJsonValue, Signal, Slot, Property, QLocale, QJsonArray, QJsonDocument, Qt, QDateTime, QDate, QTime
from PySide2.QtCore import QSortFilterProxyModel, QModelIndex, QRegularExpression, QRegExp, QMetaObject
from qobjectlistmodel import QObjectListModel
from qjsonnetwork import QJsonNetwork

class DataJson(QObject):
    def __init__(self, mid, order, mjson, metadata, parent = None):
        QObject.__init__(self, parent)
        self.setObjectName(str(mid))
        self.m_id = mid
        self.m_order = order
        self.m_json = QJsonValue(mjson)# or  self.m_json = mjson #
        self.m_metadata = metadata
    
    @Signal
    def idChanged(self):
        pass
    
    @Signal
    def orderChanged(self):
        pass
    
    @Signal
    def jsonChanged(self):
        pass
    
    @Signal
    def metadataChanged(self):
        pass
    
    def _id(self):
        return self.m_id
    
    def _order(self):
        return self.m_order
    
    def _json(self):
        return self.m_json.toObject() #warning only with self.m_json is QJsonValue()
    
    def _metadata(self):
        return self.m_metadata
   
#    def setId(self, mid):
#        if mid!= self.m_id:
#            self.m_id=mid
#            self.idChanged.emit()
            
    def setOrder(self, order):
        if order!= self.m_order:
            self.m_order=order
            self.orderChanged.emit()
            
    def setJson(self, mjson):
        if mjson.toObject()!= self.m_json.toObject():
            self.m_json=QJsonValue(mjson)
            self.jsonChanged.emit()
            
    def setMetadata(self, metadata):
        if metadata!= self.m_metadata:
            self.metadata=metadata
            self.metadataChanged.emit()
        
    id = Property(int, _id, notify= idChanged)
    order = Property(str, _order, setOrder, notify= orderChanged) #only order internal for proxy, default false
    json = Property(QJsonValue, _json, setJson, notify= jsonChanged)
    metadata = Property(str, _metadata, setMetadata, notify= metadataChanged)# search proxy memory, defaul false
    
class ModelJson(QObjectListModel):
    def __init__(self, objname, parent = None):
        QObjectListModel.__init__(self, parent)
        self.setObjectName(str(objname))
        self.m_locale = QLocale("es")#temp, auto changue when login
        #self.m_proxy = ProxyModelJson()
        self.m_order=""
        self.boolMetadata=False
        self.m_fields=QJsonArray()#[]#QJsonArray
        self.m_fieldsPoint=[]#5.2up
        self.m_maxLimit=100
        self.m_domain=QJsonArray()#[]#QJsonArray
        self.m_orderTryton=QJsonArray()#[]#QJsonArray
        self.m_preferences={}
        self.m_qjsonnetwork = QJsonNetwork()
        self.m_fieldsFormatDecimal=[]#QJsonArray
        self.m_fieldsFormatDateTime=[]#QJsonArray
        self.m_model_method_search=""
        self.m_hasIndexOfId={}
        self.m_engine=None#QQmlApplicationEngine()
        self.autoBusy=True
        self.boolSynchro=True# add synchronous call (calldirect), best performance!
        
    def prepareDeletion(self):
        if self.boolSynchro == False:
            self.m_qjsonnetwork.signalResponse.disconnect(self.slotJsonConnect)
        self.setFields(QJsonArray())
        self.clear()
        
    @Slot(int, result=int)
    def indexisOfId(self,mid):#el index del record en el modelo, no en el proxy
        return self.m_hasIndexOfId.get(mid,-1)
    
    @Slot(bool)
    def activateMetadata(self, meta):
        self.boolMetadata=meta
        
    @Slot("QJsonObject")
    def setPreferences(self, preferences):
        self.m_preferences=preferences
        
    @Slot(str)
    def setOrderInternal(self, order):# only proxy, defaul false, no es necesario con order tryton
        self.m_order = order
        if self.m_order!="":
            self.m_proxy.setSortData("order")
            self.m_proxy.setSortLocaleAware(True)
            self.m_proxy.sort(0, Qt.AscendingOrder)
            self.m_proxy.setSortRole(self.ObjectRole)

    @Slot(str, QJsonArray, int, QJsonArray, QJsonArray)
    def setSearch(self, model_method_search, domain, maxlimit, ordertryton, fields):
        self.m_maxLimit = maxlimit
        self.m_domain=domain#.toVariantList()
        self.m_orderTryton=ordertryton#.toVariantList()
        self.setFields(fields)
        self.m_model_method_search=model_method_search
        
    @Slot(str)  
    def setModelMethod(self, model_method_search):
        self.m_model_method_search=model_method_search
        
    @Slot(QJsonArray)  
    def setDomain(self, domain):
        self.m_domain=domain
        
    @Slot(int)  
    def setMaxLimit(self, maxlimit):
        self.m_maxLimit = maxlimit
        
    @Slot(QJsonArray)  
    def setOrder(self, ordertryton):
        self.m_orderTryton=ordertryton
        
    @Slot(QJsonArray)  
    def setFields(self, fields):# si es [], son todos
        self.m_fields=fields
        self.m_fieldsPoint=[]
        for f in self.m_fields.toVariantList():
            if f.find(".")!=-1:
                self.m_fieldsPoint.append(f)
        
    @Slot(str)
    def setLanguage(self, language):
        self.m_locale = QLocale(language)
    
    @Slot()
    @Slot(QJsonArray)
    @Slot(QJsonArray, int)
    def find(self, domain=QJsonArray(), maxlimit=-1):# metodo asincronico
#        if domain!=QJsonArray():
        self.m_domain=domain#.toVariantList()
        self.initSearch(maxlimit)

    @Slot()
    @Slot(int)
    def initSearch(self, maxlimit=-1):# metodo asincronico
        self.clear()
        self.m_hasIndexOfId={}
        self.nextSearch(maxlimit)
    
    def addResult(self, result, update=False):#QJsonArray
        jsonobj = {}
        mis = self._count()
        for res in result:
            mid = int(res["id"])
            mapJsonDoc = res
            jsonobj = {}
            order = "" if self.m_order=="" else mapJsonDoc[self.m_order].strip()
            metadata=""
            jsonobj=mapJsonDoc
            if self.boolMetadata:
                doct = QJsonDocument(mapJsonDoc)
                metadata = doct.toJson(QJsonDocument.Compact).data().decode("utf-8")
#            if self.m_fields!= QJsonArray():
            if len(self.m_fieldsPoint)>0:
                fieldsdoc = list(mapJsonDoc)
                for fp in self.m_fieldsPoint:
                    if fp not in fieldsdoc:
                        lfp = fp.split(".")
                        for li in range(len(lfp)-1):
                            lfp[li]=lfp[li]+"."
                        temp=jsonobj[lfp[0]]
                        for c in lfp[1:]:
                           temp = temp[c]
                        jsonobj[fp] = temp
                
            for vp in self.m_fieldsFormatDecimal:
                v = vp[0]
                if jsonobj.__contains__(v):
                    if jsonobj[v]!= None:
                        if jsonobj[v].__contains__("decimal"):
                            jsonobj[v+"_format"] = self.m_locale.toString(float(jsonobj[v]["decimal"]),'f',vp[1])#add suport
                        else:
                            jsonobj[v+"_format"] = ""
                    else:
                        jsonobj[v+"_format"] = ""
            for v in self.m_fieldsFormatDateTime:
                mfield = v[0]
                mformat = v[1]
                if jsonobj.__contains__(mfield):
                    mdateTime = QDateTime()
                    if jsonobj[mfield] != None:
                        if jsonobj[mfield].__contains__("__class__"):
                            if jsonobj[mfield]["__class__"]=="date":
                                mdateTime = QDateTime(QDate(jsonobj[mfield]["year"],
                                                            jsonobj[mfield]["month"],
                                                            jsonobj[mfield]["day"]),
                                                      QTime())
                            if jsonobj[mfield]["__class__"]=="datetime":
                                mdateTime = QDateTime(QDate(jsonobj[mfield]["year"],
                                                            jsonobj[mfield]["month"],
                                                            jsonobj[mfield]["day"]),
                                                      QTime(jsonobj[mfield]["hour"],
                                                            jsonobj[mfield]["minute"],
                                                            jsonobj[mfield]["second"]))
            
                            jsonobj[mfield+"_format"] =  mdateTime.toString(mformat)
                        else:
                            jsonobj[mfield+"_format"] = ""
                    else:
                        jsonobj[mfield+"_format"] = ""
            
            if update==False:
                dataJson = DataJson(mid, order, jsonobj, metadata, self)
                self.append(dataJson)
        
                self.m_hasIndexOfId[mid] = mis
                mis+=1
            else:
                index = self.indexisOfId(mid)
                if index!=-1:
                    self.at(index).setProperty("order",order)
                    self.at(index).setProperty("json",jsonobj)
                    self.at(index).setProperty("metadata",metadata)        

    @Slot()
    @Slot(int)
    def nextSearch(self, maxlimit=-1):# metodo asincronico
        self.openBusy()
        limit = self.m_maxLimit
        if maxlimit !=-1:
            limit = maxlimit
        params = QJsonArray()
        params.append(self.m_domain)
        params.append(self._count())
        params.append(limit)
        params.append(self.m_orderTryton)
        params.append(self.m_fields)
        params.append(self.m_preferences)
        if self.boolSynchro:
            result = self.m_qjsonnetwork.callDirect("nextSearch"+self.objectName(), self.m_model_method_search+".search_read" ,params)
            reValue = result["data"]
            if reValue.__class__() == {}:
               if reValue.__contains__("result"):
                   if reValue["result"].__class__() == []:
                       self.addResult(reValue["result"])
                       self.closeBusy()
            
        else:
            self.m_qjsonnetwork.call("nextSearch"+self.objectName(), self.m_model_method_search+".search_read" ,params)
    
    @Slot(QJsonArray)# metodo asincronico
    def updateRecords(self, ids):#update record with tryton, 
        self.openBusy()
        params = QJsonArray()
        params.append(ids)
        params.append(self.m_fields)
        params.append(self.m_preferences)
        if self.boolSynchro:
            result = self.m_qjsonnetwork.callDirect("updateRecords"+self.objectName(), self.m_model_method_search+".read" ,params)
            reValue = result["data"]
            if reValue.__class__() == {}:
               if reValue.__contains__("result"):
                   if reValue["result"].__class__() == []:
                       self.addResult(reValue["result"], True)
                       self.closeBusy()
            
        else:
            self.m_qjsonnetwork.call("updateRecords"+self.objectName(), self.m_model_method_search+".read" ,params)
    
    @Slot(int)
    def removeItem(self, mid):# elimina solo en memory, no afecta a base datos
        index = self.indexisOfId(mid)
        if index!=-1:
            self.m_hasIndexOfId.pop(mid)
            self.removeAt(index)
    
    @Slot(QJsonArray)
    def addFieldFormatDecimal(self, fields):
        #ModelArticulo.addFieldFormatDecimal(['total_amount']);
        self.m_fieldsFormatDecimal = []
        for v in fields.toVariantList():
            if v.__class__() == '':
                self.m_fieldsFormatDecimal.append([v,2])
            elif v.__class__() == []:
                if v.__len__()==2:
                    if v[0].__class__() == '' and v[1].__class__() == 0:
                        self.m_fieldsFormatDecimal.append(v)

    @Slot(QJsonArray)
    def addFieldFormatDateTime(self, fields):
        #ModelArticulo.addFieldFormatDateTime([['invoice_date','dd/MM/yy'],['create_date','dd/MM/yy hh:mm:ss']]);
        self.m_fieldsFormatDateTime = []
        for v in fields.toVariantList():
            if v.__class__() == []:
                if v.__len__()==2:
                    if v[0].__class__() == '' and v[1].__class__() == '':
                        self.m_fieldsFormatDateTime.append(v)
    
    signalResponse = Signal(str, int)
    signalResponseData = Signal(str, int, "QJsonObject")#QJsonObject = dict

    
    @Slot(str, int, dict)# obsoleto mejor usar calldirect!
    def slotJsonConnect(self, pid, option, data):#cath datos de call, 
        if pid=="nextSearch"+self.objectName():
            if option==2:#result
                dataObject = data["data"]
                if dataObject.__contains__("result"):
                    if dataObject["result"].__class__() ==[]:
                        self.addResult(dataObject["result"])
                        self.signalResponseData.emit("nextSearch", option, {})# ok envio emit de confirmacion
                else:
                    #print("la data",data)
                    self.signalResponseData.emit("nextSearch", 5, data)#puede ser un error 403 timeout
            else:
                self.signalResponseData.emit("nextSearch", option, data)#dejo cruzar los datos
        if pid=="updateRecords"+self.objectName():
            if option==2:#result
                dataObject = data["data"]
                if dataObject.__contains__("result"):
                    if dataObject["result"].__class__() ==[]:
                        self.addResult(dataObject["result"], True)
                        self.signalResponseData.emit("updateRecords", option, {})# ok envio emit de confirmacion
                else:
                    #print("la data",data)
                    self.signalResponseData.emit("updateRecords", 5, data)#puede ser un error 403 timeout
            else:
                self.signalResponseData.emit("nextSearch", option, data)#dejo cruzar los datos
                
    def setProxy(self, proxp):
        self.m_proxy = proxp
        
    def setJsonConnect(self, jchac):#=None):#(QJsonNetwork *jchac=nullptr);
        self.m_qjsonnetwork = jchac;
        self.connectSlotJC()
            
    def connectSlotJC(self):
        if self.boolSynchro==False:
            self.m_qjsonnetwork.signalResponse.connect(self.slotJsonConnect)
#        self.connect(self.m_qjsonnetwork, SIGNAL(signalResponse(QString,int,QJsonObject)),
#                     self, SLOT(slotJsonConnect(QString,int,QJsonObject)));
    
    def setEngine(self, engine):
        self.m_engine=engine
    
    def openBusy(self):
        if self.autoBusy:
            if self.m_engine!=None:
                root = self.m_engine.rootObjects()[0]
                QMetaObject.invokeMethod(root, "openBusy")
    
    def closeBusy(self):
        if self.autoBusy:
            if self.m_engine!=None:
                root = self.m_engine.rootObjects()[0]
                QMetaObject.invokeMethod(root, "closeBusy")
    
    @Slot(bool)
    def setAutoBusy(self, busy):
        self.autoBusy=busy
    
    @Slot(bool)
    def setSynchro(self, syn):
        self.boolSynchro=syn
        self.connectSlotJC()
        
    def initProxy(self):
        if self.m_order!="":
            self.m_proxy.setSortData("order")
            self.m_proxy.setSortLocaleAware(True)
            self.m_proxy.sort(0, Qt.AscendingOrder)
            self.m_proxy.setSortRole(self.ObjectRole)
        
        self.m_proxy.setFilterRoles("metadata")
        self.m_proxy.setFilterRole(self.ObjectRole)
        self.m_proxy.setDynamicSortFilter(True)
        self.m_proxy.setSourceModel(self)
        
    def isJsonObject(self, mtextdoc):
        pass
#        QJsonParseError parseError;
#        QJsonDocument docLast;
#        docLast = QJsonDocument::fromJson(doc.toUtf8(), &parseError);
#        if (parseError.error || (!docLast.isObject())) {
#            return false;
#        }
#        return true;



class ProxyModelJson(QSortFilterProxyModel):
    def __init__(self, parent = None):
        QSortFilterProxyModel.__init__(self, parent)
#        char* m_filterRoles;
        self.m_filterRoles=""
#        char* m_sortData;
        self.m_sortData = ""
        self.m_typeSort=0
        self.m_boolSignalReset= False
        self.m_reguexp = QRegularExpression()
        self.m_strexp=""
        self.m_boolstrexp=True
        self.m_boolVacio=True
   
    def setFilterRoles(self,filterRoles):
        if self.m_filterRoles == filterRoles:
            return
        self.m_filterRoles = filterRoles
       # self.filterChanged()
        
    def setSortData(self, sortData):
        pass
    def setTypeSort(self, typeSort):
        if self.m_typeSort == typeSort:
            return
        self.m_typeSort = typeSort
        self.sortOrder()

    def reNumaelis(self, text):
        if text == "":
            return text
        lista = text.split(QRegularExpression("\\s+"))
        tem2=""
        for item in lista:
            tem2+= "(?=.*"+item.strip()+")"
        return tem2
    
    @Slot(bool)
    def setAscendingOrder(self, bao):
        if self.sortOrder()==Qt.AscendingOrder and bao==False:
            self.sort(0,Qt.DescendingOrder)
        
        if self.sortOrder()==Qt.DescendingOrder and bao==True:
            self.sort(0,Qt.AscendingOrder)
    
    @Slot(bool)
    def setEmitSignalReset(self, bes):
#        if(m_boolSignalReset!=bes){
#            m_boolSignalReset=bes;
#        }
        pass

    def lessThan(self, left, right):
        rolis = self.sortRole()
        l = left.model().data(left, rolis) if left.model() == True  else None
        r = right.model().data(right, rolis) if right.model() == True  else None
        if l.__class__() == None:
            return None
        #return (r.type() != QVariant::Invalid);
        #if l.__class__() == '':
#        if self.isSortLocaleAware():
        return (l.property(self.m_sortData) < (r.property(self.m_sortData))) < 0

    def filterAcceptsRow(self, source_row, source_parent):
        if self.m_boolVacio:
            return True;
        filteris = self.filterRole()
    
        source_index = self.sourceModel().index(source_row, 0, source_parent)
        if source_index.isValid() == False:
            return True
    
        key = self.sourceModel().data(source_index, filteris).property(self.m_filterRoles)
       
        if self.m_boolstrexp:
            return key.__contains__(self.m_strexp)#;//, Qt::CaseInsensitive); el metadata esta en minuscula
        else:
            return self.m_reguexp.match(key).hasMatch()
            #return QString!!!key.contains(self.m_reguexp)
    
    @Slot(int, result=int)
    def getIndexParent(self, index):
        if index!=-1:
            return (self.mapToSource(self.index(index,0,QModelIndex()))).row()
        return -1
    
    @Slot(int, result=int)
    def getIndexProxy(self, index):
        if index!=-1:
            return (self.mapFromSource(self.sourceModel().index(index,0,QModelIndex()))).row()
        return -1;
    
    @Slot(str)
    def findElis(self, text):
        textt = text.strip().lower()
        if textt == "":
            self.m_boolVacio=True
        else:
            self.m_boolVacio=False
        if textt.__contains__(" "):
            self.m_boolstrexp=False
            self.m_reguexp.setPattern(self.reNumaelis(textt))
        else:
            self.m_boolstrexp=True
            self.m_strexp  = textt
    #//setFilter no es usado al filtra, solo se invoca para que comienze a hacerlo
        self.setFilterRegExp(QRegExp( text ))
    
    @Signal
    def signalReset(self):
        pass
    
    @Slot()
    def endFilterOrder(self):
#        if(m_boolSignalReset){
#            //qDebug()<<"termino Filtering";
#            m_boolSignalReset=false;
#            emit signalReset();
#        }
        pass
   
