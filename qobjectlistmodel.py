#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan  2 11:31:14 2020
@author(c++): railwaycoder QObjectListModel https://railwaycoder@bitbucket.org/railwaycoder/qobjectlistmodelqmltesting.git
"performing for qml listmodel"

<<traslate to python3 PySide2: Numael Garay>>

"""
__author__ = "Numael Garay"
__license__ = "BSD"
__version__ = "1.0.0" 
__maintainer__ = "Numael Garay" 
__email__ = "mantrixsoft@gmail.com"

from PySide2.QtCore import Qt, QObject, Signal, Slot, Property, QAbstractListModel, QModelIndex, SIGNAL, QByteArray

class QObjectListModel(QAbstractListModel):    
    ObjectRole = Qt.UserRole + 1
    def __init__(self, parent = None):
        QAbstractListModel.__init__(self, parent)

        self.m_objects = []
        
    def roleNames(self):
        roles={}
        roles[QObjectListModel.ObjectRole] = QByteArray(b"object")
        return roles

    def _count(self):
        return len(self.m_objects)
    
    def size(self):
        return len(self.m_objects)
    
    @Signal
    def countChanged(self):
        pass
    
    count = Property(int, _count, notify= countChanged)
    
    def rowCount(self,index):
        return self._count()
   
        
    def data(self, index, role):
#         if (index.row() < 0 || index.row() >= m_objects.size())
#        return QVariant();
#
#    if (role == ObjectRole)
#        //qDebug()<< m_objects.at(index.row())->property("metadata");
#        return QVariant::fromValue(m_objects.at(index.row()));
#
#    return QVariant();
        
        if index.row() < 0 or index.row() >= len(self.m_objects):
            return None
        if role == QObjectListModel.ObjectRole:
            return self.m_objects[index.row()]
        return None
    
    def objectList(self):
        return self.m_objects
    
    def setObjectList(self, objects):
#        int oldCount = m_objects.count();
#        beginResetModel();
#        m_objects = objects;
#        endResetModel();
#        emit dataChanged(index(0), index(m_objects.count()));
#        if (m_objects.count() != oldCount)
#            emit countChanged();
        
        oldCount = len(self.m_objects)
        self.beginResetModel()
        self.m_objects = objects
        self.endResetModel()
        QObject.emit(self, 
                     SIGNAL("dataChanged(const QModelIndex&, const QModelIndex &)"), 
                     self.index(0), self.index(len(self.m_objects)))
        if(len(self.m_objects) != oldCount):
            QObject.emit(self, SIGNAL("countChanged()"))
        
    def append(self, mobject):
#         beginInsertRows(QModelIndex(), m_objects.count(), m_objects.count());
#         m_objects.append(object);
#         endInsertRows();
#         emit countChanged();
        self.beginInsertRows(QModelIndex(), len(self.m_objects), len(self.m_objects))
        self.m_objects.append(mobject)
        self.endInsertRows()
        QObject.emit(self, SIGNAL("countChanged()"))
    
    def append_objects(self, objects):
        self.beginInsertRows(QModelIndex(), len(self.m_objects), len(self.m_objects)+len(self.objects)-1)
        self.m_objects = self.m_objects + objects
        self.endInsertRows()
        QObject.emit(self, SIGNAL("countChanged()"))
        
    def insert(self, i, mobject):
        self.beginInsertRows(QModelIndex(),i, i)
        self.m_objects.append(mobject)
        self.endInsertRows()
        QObject.emit(self, SIGNAL("countChanged()"))
    
    def insert_objects(self, i, objects):
#        if (objects.isEmpty())
#            return;
#
#        beginInsertRows(QModelIndex(), i, i+objects.count()-1);
#        for (int j = objects.count() - 1; j > -1; --j)
#            m_objects.insert(i, objects.at(j));
#        endInsertRows();
#        emit countChanged();
        if len(objects)>0:
            self.beginInsertRows(QModelIndex(),i, i+len(self.objects)-1)
            self.m_objects[i:i] = objects
            self.endInsertRows()
            QObject.emit(self, SIGNAL("countChanged()"))
            
    def replace(self, i, mobject):
#        m_objects.replace(i, object);
#        emit dataChanged(index(i), index(i));
        self.m_objects[i]=mobject
        QObject.emit(self, 
                     SIGNAL("dataChanged(const QModelIndex&, const QModelIndex &)"), 
                     self.index(i), self.index(i))
    
    def move(self, _from, _to):
        destr=_to
        if _to > _from:
            destr=_to+1
        if self.beginMoveRows(QModelIndex(), _from, _from, QModelIndex(), destr)==True:
            if _from < len(self.m_objects):
                self.m_objects.insert(_to, self.m_objects.pop(_from))
            self.endMoveRows()
#        if (!beginMoveRows(QModelIndex(), from, from, QModelIndex(), to > from ? to+1 : to))
#            return; //should only be triggered for our simple case if from == to.
#        m_objects.move(from, to);
#        endMoveRows();
    
    def removeAt(self,i, count = 1):
#        beginRemoveRows(QModelIndex(), i, i + count - 1);
#        for (int j = 0; j < count; ++j)
#            m_objects.removeAt(i);
#        endRemoveRows();
#        emit countChanged();
        self.beginRemoveRows(QModelIndex(), i, i + count - 1)
        for j in range(count):
            self.m_objects.pop(i)
        self.endRemoveRows()
        QObject.emit(self, SIGNAL("countChanged()"))
    
    def takeAt(self,i):
#        beginRemoveRows(QModelIndex(), i, i);
#        QObject *obj = m_objects.takeAt(i);
#        endRemoveRows();
#        emit countChanged();
#        return obj;
        self.beginRemoveRows(QModelIndex(), i, i)
        obj = self.m_objects.pop(i)
        self.endRemoveRows()
        QObject.emit(self, SIGNAL("countChanged()"))
        return obj
    
    def clear(self):
#         if (m_objects.isEmpty())
#            return;
#    
#        beginRemoveRows(QModelIndex(), 0, m_objects.count() - 1);
#        m_objects.clear();
#        endRemoveRows();
#        emit countChanged();
        if self.m_objects != []:
            self.beginRemoveRows(QModelIndex(), 0, self.m_objects.__len__() - 1)
            self.m_objects.clear()
            self.endRemoveRows()
            QObject.emit(self, SIGNAL("countChanged()"))
    
    def at(self,i):
        return self.m_objects[i]
    
    @Slot(int, result=QObject)#for qml use
    def get(self,i):
        return self.m_objects[i]
    
    def contains(self, mobject):
        return self.m_objects.count(mobject) > 0
    
    def indexOf(self, mobject,  _from=0):
        if self.m_objects[_from:].count(mobject) > 0:
            return _from + self.m_objects[_from:].index(mobject)
        return -1
    
    def lastIndexOf(self, mobject):#, _from=-1):
        _from=0
        founds = self.m_objects[_from:].count(mobject)
        if founds == 1:
            return _from + self.m_objects[_from:].index(mobject)
        if founds > 1:
            return len(self.m_objects)-1-self.m_objects[::-1].index(mobject)
        return -1
    
    def isEmpty(self):
        if self.m_objects==[]:
            return True
        return False
#    inline bool contains(QObject *object) const { return m_objects.contains(object); }
#    inline int indexOf (QObject *object, int from = 0) const { return m_objects.indexOf(object, from); }
#    inline int lastIndexOf (QObject *object, int from = -1) const { return m_objects.lastIndexOf(object, from); }
#
#    inline int count() const { return m_objects.count(); }
#    inline int size() const { return m_objects.size(); }
#    inline bool isEmpty() const { return m_objects.isEmpty(); }