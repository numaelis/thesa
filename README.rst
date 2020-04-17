Thesa

It is a Platform to connect to tryton (json-rpc) and is based on qt/qml libraries.

Requires designing the interface of each Tab without having to touch the core.

Tabs are created with qml files and can be loaded locally from a folder or from trytond using thesamodule (https://github.com/numaelis/thesamodule).

Thesa's goal is to be able to combine tryton with Qt / Qml, for special cases such as using the opengl performance of qml2

Requirements:
  pyside2 5.12 or higher: https://download.qt.io/official_releases/QtForPython/pyside2/
  
Run:
 python3 main.py
 
Development:

    how to use: <see system folder>
        It is mandatory to define the file Desktop.qml and MenuModel.qml. The first is where the sections are defined with their respective tabs and the second is for the side menu, both must match. Here also the tabs are added and we create them through qml files.
        The menu and tabs are dynamically loaded at the moment of starting the session. they are destroyed at the time of closing session
        if you need to translate into several languages you can use the lupdate, linguist and lrelease tools. and after generating the .qm files they are placed in the same folder (system). In order for you to use a certain language in the tabs you must have already generated one in the corelocale folder

        If using qtcreator(qt framework) to edit or create the .qml, it is recommended to create a link to thesatools folder and copy this link into the qt framework qml libraries example: /Qt5.12.3/5.12.3/gcc_64/qml/
        
    icons:
        tesha uses font awesome for icons in interface, see cheatsheet: https://fontawesome.com/cheatsheet/free/solid


    thesatools:
        has added some custom widgets (qt quick controls 2).  Are imported with: import thesatools 1.0
    
    properties created in native code and can be called from qml:
    <see reference...>
    
        QJsonNetworkQml:
            is the connection manager property (json-rpc)
            
        ModelManagerQml:
            is the manager property to create data models.
            The data models are based on QObjectListModel written by railwaycoder https: //railwaycoder@bitbucket.org/railwaycoder/qobjectlistmodelqmltesting.git
        
        Tools:
            functions and calls to the native interface
    
    javascript functions and variables:
        
        formatDecimal(value)
        formatNumeric(value)
        formatCentUp(value)
        
        boolShortWidth135
        boolShortWidth
        preferences
        preferencesAll
        planguage
        thousands_sep
        decimal_point

        
Support thesa

some binaries:

https://sourceforge.net/projects/thesa/




