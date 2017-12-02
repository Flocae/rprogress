
import breezedb.BreezeDb;
import breezedb.collections.Collection;

import com.caetta.utils.MyEvent;

import breezedb.events.BreezeDatabaseEvent;

import com.caetta.utils.MyUtils;

import db.DbORM;

import db.StaticVars;

import db.dbShema;

import flash.net.SharedObject;

import flatspark.enums.BrandColorEnum;
import flatspark.enums.ButtonSizeEnum;
import flatspark.utils.AwesomeUtils;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.Alert;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.CloseEvent;
import mx.events.CollectionEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;
import mx.managers.SystemManager;

import views.About;

import views.ListParameters;

import views.UserFormView;
import views.Utils;

[Bindable]
private var _nRemain:int;
[Bindable]
private var _globalProgress:int;
[Bindable]
private var _toComeUp:int;
[Bindable]
private var _total:int;
private var _userName:String;
// Feed the Datagrid
[Bindable]
public var _datagridAC:ArrayCollection;
// App data
private var _appData:SharedObject;
// pop up
private var _userForm:UserFormView;
private var _params:ListParameters;

protected function thisCreationComplete(event:FlexEvent):void {
    // Status text
    this.statusText.text = "v " + MyUtils.getAppVersion();
    // appData /local Store
    setAppData();
    // VARIABLES
    _nRemain = 0;
    nRemaining.text = "CR restant(s) : " + _nRemain.toString();
    _globalProgress = 0;
    globalProgress.text = "Avancement moyen : " + _globalProgress.toString() + " %";
    _toComeUp = 0;
    toComeUpLabel.text = "A venir : " + _toComeUp.toString();
    _total = 0;
    total.text = "Total : " + _total.toString();
    //temps Variables
    _userName = " Prénom Nom";
    userName.text = _userName;
    // EventListener
    // DB CREATION
    BreezeDb.storageDirectory = File.documentsDirectory;// db inside user's doc
    dbShema.createDB();
    // trace("DB created successfully; Name : " + dbShema.dbName + " ; Table Name: " + dbShema.tableName + "\n");
    dbShema.customDb.addEventListener(BreezeDatabaseEvent.SETUP_SUCCESS, onDatabaseSetup);


}
// Datagrid
protected function onSelectionChanged(e:Event) {
    editButton.enabled = true;
    deleteButton.enabled = true;
    StaticVars.ID = int(dataGrid.selectedItem.ID);
    // Retrieving Models by Primary Key
    DbORM.query()
            .select("*")
            .where("id", "=", StaticVars.ID)
            .fetch(function (error:Error, savedDbOrms:Collection):void {
                if (error == null) {
                    for each(var savedDbOrm:DbORM in savedDbOrms) {
                        userName.text = savedDbOrm.prenom + " " + savedDbOrm.nom;
                        progressBar.currentProgress = savedDbOrm.progress;
                        for (var i:int = 1; i <= 10; i++) {
                            if (savedDbOrm["task" + i])
                                setTaskAlpha(i, 0.3);
                            else
                                setTaskAlpha(i, 1);
                        }
                        textAreaNotes.text = savedDbOrm.notes;
                        // BUG -->exception, information=TypeError: Error #1010: A term is undefined and has no properties
                        /*for (var i:int = 1; i <= 10; i++) {
                            if (savedDbOrm["task" + i])
                                this["t" + i].text = "ll";
                            else
                                this["t" + i].text = "ljhkjhkj";

                            this["t" + i].text =
                        }*/
                        // set ToDoList text

                    }

                }
            })

}

// db Function
protected function onDatabaseSetup(e:BreezeDatabaseEvent):void {
    dbShema.customDb.removeEventListener(BreezeDatabaseEvent.SETUP_SUCCESS, onDatabaseSetup);
    // Datagrid
    updateDatagrid();
}

protected function deleteModel(ID:int):void {
    DbORM.query().removeByKey(ID, function (error:Error):void {
        updateDatagrid();
    });

}

// UI functions
private function createNew(e:Event):void {
    _userForm = new UserFormView();
    _userForm.title = "Nouveau";
    StaticVars.DATE = new Date();
    _userForm.addEventListener(MyEvent.GOT_RESULT, myEventFunction);
    PopUpManager.addPopUp(_userForm, this, true);
}

private function edit(e:MouseEvent):void {
    _userForm = new UserFormView();
    _userForm.isNew = false;
    _userForm.title = "NOM";
    _userForm.addEventListener(MyEvent.GOT_RESULT, myEventFunction);
    PopUpManager.addPopUp(_userForm, this, true);
}

private function openParams(e:Event):void {

    _params = new ListParameters();
    _params.addEventListener(MyEvent.GOT_RESULT, myEventFunction);
    PopUpManager.addPopUp(_params, this, true);
}
private function deleteFunct(e:Event):void {
    Alert.show("Supprimer " + dataGrid.selectedItem.lastName + " " + dataGrid.selectedItem.firstName, "Suppression ?", Alert.YES | Alert.NO, this, alertClickHandler);

}
private function about(e:MouseEvent):void {
    var about:About = new About();
    PopUpManager.addPopUp(about, this, true);
}
private function utils(e:MouseEvent):void {
    var util:Utils = new Utils();
    PopUpManager.addPopUp(util, this, true);
}


private function importXML(e:Event):void {
    readXMLData();
}


private function alertClickHandler(event:CloseEvent):void {
    switch (event.detail) {
        case Alert.YES:
            deleteModel(StaticVars.ID);
            break;
        case Alert.NO:
            break;
    }
}


// set Alpha TODOLIST
private function setTaskAlpha(num:int, alpha:Number) {
    this["t" + num].alpha = alpha;
}
// Event
protected function myEventFunction(event:MyEvent):void {
    switch (event.result) {
        case "updateTODOLIST": {
            _params.removeEventListener(MyEvent.GOT_RESULT, myEventFunction);
            setTotoList();
            break;
        }
        case "updateDatagrid": {
            _userForm.removeEventListener(MyEvent.GOT_RESULT, myEventFunction);
            updateDatagrid();
            editButton.enabled = false;
            deleteButton.enabled = false;
            break;
        }
        default: {
            trace("N0 DATA");
            break
        }
    }
}
// Datagrid
protected function updateDatagrid():void {
    var numRemaining:int = 0;
    var sumProgressBelow100:int = 0;
    var today:Date = new Date();
    var toComeUp:int = 0;
    DbORM.query()
            .select("*")
            .fetch(function (error:Error, savedDbOrms:Collection):void {
                if (error == null) {
                    _datagridAC = new ArrayCollection();
                    for each(var savedDbOrm:DbORM in savedDbOrms) {
                        if (savedDbOrm.progress < 100 && today.getTime() > savedDbOrm.date.getTime()) {
                            numRemaining++;
                            sumProgressBelow100 += savedDbOrm.progress;
                        }
                        if (today.getTime() < savedDbOrm.date.getTime())
                            toComeUp++;
                        _datagridAC.addItem({
                            "lastName": savedDbOrm.nom,
                            "firstName": savedDbOrm.prenom,
                            "date": savedDbOrm.date,
                            "progress": savedDbOrm.progress,
                            "ID": savedDbOrm.id
                        });
                    }
                    nRemaining.text="CR restant(s) : " + numRemaining.toString();
                    total.text = "Total : " + _datagridAC.length.toString();
                    globalProgress.text = "Avancement moyen : " + int((sumProgressBelow100 / numRemaining)).toString() + " %";
                    toComeUpLabel.text = "A venir : " + toComeUp.toString();
                    DefaultSort();
                }


            })
}

/* private function selectOnProgress(advancedDataGridC:AdvancedDataGrid, rowIndex:int, color:uint):uint
 {
     var rColor:uint;
     var item:Object = advancedDataGridC.dataProvider.getItemAt(rowIndex);
     var value:int = item["progress"];
     if (value <100) { rColor = 0xFF00FF; }
     return rColor;
 }*/
/* private function changeSort(e:Event):void {

 }*/

// MISC functions


private function setAppData():void {

    _appData = SharedObject.getLocal("appData");
    // first creation
    if (_appData.size == 0) {
        _appData.data.firstLaunch = new Date().time;
        // Defaults Tasks
        _appData.data.task1 = "Questionnaires";
        _appData.data.task2 = "Anamnèse";
        _appData.data.task3 = "Comportement";
        _appData.data.task4 = "Cotation";
        _appData.data.task5 = "De WISC à TEACH";
        _appData.data.task6 = "De TEACH à Rey";
        _appData.data.task7 = "Conclusion";
        _appData.data.task8 = "Conseils";
        _appData.data.task9 = "Facture";
        _appData.data.task10 = "Envoi du CR";

        _appData.flush(); // Save AppData
    }
    setStaticVars();
}

private function setStaticVars() {
    // Assign tasks string values
    for (var i:int = 1; i <= 10; i++) {
        StaticVars["TASK" + i] = _appData.data["task" + i];
    }
    setTotoList();
}

private function setTotoList():void {
    // set ToDoList text
    for (var i:int = 1; i <= 10; i++) {
        this["t" + i].text = ". " + StaticVars["TASK" + i];
    }
}

//Formatter Functions
public function formatDate(item:Object, column:AdvancedDataGridColumn):String {
    return formDate.format(item[column.dataField]);
}
// DG color function : set datgrid style with confitional
public function DatagridStyleFunction(data:Object, col:AdvancedDataGridColumn):Object {
    var now:Date = new Date();
    var after:Boolean=(data["date"].getTime() > now.getTime());

    //
    if (data["progress"] < 100 && !after)
        return {color:0xb30059};
    else if (after)
        return {color:0x666699};
    return null;
}
private function DefaultSort():void {
    var sort:Sort = new Sort();
    var sortField:SortField = new SortField("progress");
    sort.fields =[sortField];
    dataGrid.dataProvider.sort=sort;
    _datagridAC.refresh();
}

//Special Function :Import xml Data
private function readXMLData():void {
    var xmlloader:URLLoader = new URLLoader();
    xmlloader.addEventListener(Event.COMPLETE, parsexml);//Wait for the xml file to complete load then run the parsexml function
    xmlloader.load(new URLRequest("db/EtatABP.xml"));
}
private function parsexml(e:Event) {
    var myXML:XML = new XML(e.target.data);
    var parsedDate:Date = new Date();
    for each (var patient:XML in myXML.Patient) {
        //
        var dbOrm:DbORM = new DbORM();
        dbOrm.nom = patient.Nom;
        dbOrm.prenom = patient.Prenom;
        var xmlDate:String = patient.DateConsult;
        parsedDate = new Date(int(xmlDate.substr(0, 4)), int(xmlDate.substr(5, 2)) - 1, int(xmlDate.substr(8, 2)));
        trace(xmlDate + " - parsed date-> " + parsedDate);
        dbOrm.date = parsedDate;
        dbOrm.progress = int(patient.PercentAvancement);

        dbOrm.task1 = patient.QuestionnairesOK == "true";
        dbOrm.task2 = patient.AnamneseOK == "true";
        dbOrm.task3 = patient.ComportementOK == "true";
        dbOrm.task4 = patient.CotationOK == "true";
        dbOrm.task5 = patient.WISCaTeachOK == "true";
        dbOrm.task6 = patient.TEACHaReyOK == "true";
        dbOrm.task7 = patient.CclConseilsOK == "true";
        dbOrm.task8 = patient.AmenagementsOK == "true";
        dbOrm.task9 = patient.CRparentsOK == "true";
        dbOrm.task10 = patient.CRproOK == "true";

        dbOrm.notes = patient.Notes;

        dbOrm.save(function (error:Error, savedDbOrm:DbORM):void {
            trace("Importation ok")
        });
    }
    updateDatagrid();
}