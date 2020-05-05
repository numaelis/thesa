thesa documentation 1.2

properties created in native code and can be called from qml:

    QJsonNetworkQml:
        is the connection manager property (json-rpc)
  
        function callDirect(string pid, string method, Array parameters): -> object
            the result is a variable type object, of type {data: <tryton json-rpc> {id:, result:}}, if there was an error {data: "error"}
            
        function runReport(self, string pid, string method, Array parameters): -> could open the downloaded document
            request a report from tryton and open it


    ModelManagerQml:
        is the manager property to create data models.
        
        function addModel(string model, string proxy): 
            create the optimized qt data model to call tryton classmethod ModelStorage.search_read
            
        
        The created qt object model (QObjectListModel) has these properties:

            function setSearch(string model_method_search, array domain, int maxlimit, array ordertryton, array fields):
                general configuration of the model
            
            function setModelMethod(string model_method_search):
                configuration method of the model without adding search_read
            
            function setDomain(array domain):
                domain configuration. <see tryton reference>
                
            function setOrder(array ordertryton):
                configuration order. <see tryton reference>
                
            function setMaxLimit(int maxlimit):
                maximum limit setting for each search
            
            function setFields(array fields):
                field settings of the model you want to load
            
            function setLanguage(string language):
                configure model locale, just write like this: <created model>.setLanguage(planguage);
                the "planguage" variable is generated at login
            
            function addFieldFormatDecimal(array fields):
                add fields in decimal format. Then from the view delegate call it <the field> _format.

            function addFieldFormatDateTime(array fields):
                add fields in date or datetime format.
                example: <created model>.addFieldFormatDateTime([['invoice_date','dd/MM/yy'],['create_date','dd/MM/yy hh:mm:ss']]);

            function setPreferences(object preferences):
                configure tryton server preferences, just write like this: <created model> .setPreferences(preferences);
                the "preferences" variable is generated at login
            
            function find( array domain=[], int maxlimit=-1):
                restart search in tryton and depending on domain
            
            function nextSearch(int maxlimit=-1):
                start next search. This function adds the following items from the tryton model

            function updateRecords(array ids):
                search the [ids] in tryton and updates the items in the model.

            function removeItem(int id):
                remove item from model, only in memory, make no changes to tryton.
                
            function setAutoBusy(bool busy): active or desactive busy
        
        
    Tools:
        functions and calls to the native interface
        
            function calendarShortNamesDays(string language=""): -> []
                return array short name days
                
            function calendarShortNamesMonths(string language=""): -> []
                return array short name months
            
            function calendarLongNamesDays(string language=""): -> []
                return array long name days
                
            function calendarLongNamesMonths(string language=""): -> []
                return array long name months
            
            function getImagePath(string caption="find images"): -> {}
                open system dialog window to find file
                return object { error: bool, name: "", fullname: ""}
                name is the file name, fullname is the full path

            function getFilePath(string caption="find", string filters=""): -> {}
                open system dialog window to find file
                return object { error: bool, name: "", fullname: ""}
                name is the file name, fullname is the full path
            
            function getFileBase64(string path): -> string
                return string base64
                
            function openImagePicker(string pid, string caption = "find images"): asynchronous,
                open system picker image dialog window to find file
                requires connection to a slot of type (pid, option, path) as arguments.
            
            function scaleImage(int pixels, string path): -> string
                create a temporary reduced image and return path of this
            
            function callPhone(string number):
                open call direct phone
        


javascript functions and variables:

    function formatDecimal(value): -> string format locale
    
    function formatNumeric(value): -> string format locale
    
    function formatCentUp(value): -> string format locale

    bool boolShortWidth135 -> true if the width of the screen is less than 13.5 cms
    
    bool boolShortWidth -> true if the width of the screen is less than 9 cms
    
    object preferences -> user preferences tryton
    
    object preferencesAll -> user preferences tryton
    
    string planguage user -> user language tryton
    
    string thousands_sep -> user thousands_sep tryton
    
    string decimal_point -> user decimal_point tryton
    

thesatools:
    thesa has added some custom widgets (qt quick controls 2).  Are imported with: import thesatools 1.0
    some are buttons, inputs, calendar, messages, etc.
    <...>
    
