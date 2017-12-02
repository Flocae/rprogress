import breezedb.collections.Collection;

import com.caetta.utils.MyEvent;

import db.DbORM;
import db.StaticVars;

import flatspark.enums.BrandColorEnum;
import flatspark.enums.ButtonSizeEnum;
import flatspark.utils.AwesomeUtils;
import mx.events.CloseEvent;

import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import mx.controls.Alert;


private var _calendarPanel:CalendarPanel;
public var isNew:Boolean=true;

protected function thisCreationComplete(event:FlexEvent):void {
    PopUpManager.centerPopUp(this);
    this.y = 60;
    _calendarPanel = new CalendarPanel();
    _calendarPanel.title = "Date de la consultation";
    // Edit user if not new
    if (!isNew)
    {
        retrieveDataByID()
    }
    for (var i:int = 1; i <= 10; i++) {
        this["task"+i+"CB"].label=StaticVars["TASK" + i];
    }
}

// DATA FUNCTIONS
protected function save():void {
    if (isNew)
    {
        var dbOrm:DbORM = new DbORM();
        dbOrm.nom=lastNameTI.text;
        dbOrm.prenom = firstNameTI.text;
        dbOrm.date=StaticVars.DATE;
        dbOrm.progress=int(progressBar.currentProgress);
        for (var i:int=1;i<=10;i++)
        {
            dbOrm["task"+i]=this["task"+i+"CB"].selected;
        }
        dbOrm.notes=notesTextArea.text;

        dbOrm.save(function(error:Error, savedDbOrm:DbORM):void
        {
            // custom bubling event
            dispatchEvent(new MyEvent(MyEvent.GOT_RESULT,"updateDatagrid",false));
        });
    }
    else
    {
        updateID(StaticVars.ID)
    }
}
private function retrieveDataByID():void {
    // Retrieving Models by Primary Key
    DbORM.query()
            .select("*")
            .where("id", "=", StaticVars.ID)
            .fetch(function (error:Error, savedDbOrms:Collection):void {
                if (error == null) {
                    for each(var savedDbOrm:DbORM in savedDbOrms) {
                        lastNameTI.text=savedDbOrm.nom;
                        firstNameTI.text=savedDbOrm.prenom;
                        DateConsultTextInput.text=formatDate.format(savedDbOrm.date);
                        StaticVars.DATE=savedDbOrm.date;
                        progressBar.currentProgress = savedDbOrm.progress;

                        for (var i:int = 1; i <= 10; i++) {
                            setCheckedTask(i,savedDbOrm["task" + i]);
                        }
                        notesTextArea.text=savedDbOrm.notes;
                    }

                }
            })
}
private function updateID(id:int){
    DbORM.query().find(id, function(error:Error, dbOrm:DbORM):void
    {
        if(dbOrm == null)
        {
            return;
        }
        dbOrm.nom=lastNameTI.text;
        dbOrm.prenom = firstNameTI.text;
        dbOrm.date=StaticVars.DATE;
        dbOrm.progress=int(progressBar.currentProgress);
        for (var i:int=1;i<=10;i++)
        {
            dbOrm["task"+i]=isTaskSelected(i);// bug with -->this["task"+i+"CB"].selected;
        }
        dbOrm.notes=notesTextArea.text;
        dbOrm.save(function(error:Error, savedDbOrm:DbORM):void
        {
            if(error == null)
            {
                dispatchEvent(new MyEvent(MyEvent.GOT_RESULT,"updateDatagrid",false));
            }
        });
    });
}
// UI FUNCTIONS
private function validate(e:Event):void {
    save();
    PopUpManager.removePopUp(this);

}
private function cancel(e:Event):void {
    PopUpManager.removePopUp(this);
    //Alert.show("Aucune information ne sera sauvergardée ?", "Annuler ?", Alert.YES | Alert.NO, this, alertClickHandler); -->skin
}
private function checkAll(e:Event):void {

    for (var i:int=1;i<=10;i++)
    {
        this["task"+i+"CB"].selected=true;
    }
    setProgressBar();
}
private function uncheckAll(e:Event):void {

    for (var i:int=1;i<=10;i++)
    {
        this["task"+i+"CB"].selected=false;
    }
    setProgressBar();
}
private function setProgressBar():void{
    var progress:int=0;
    for (var i:int=1;i<=10;i++)
    {
        if(this["task"+i+"CB"].selected)
        {
            progress+=10;
        }
    }
    progressBar.currentProgress=progress;
}
private function alertClickHandler(event:CloseEvent):void {
    switch (event.detail) {
        case Alert.YES:
            PopUpManager.removePopUp(this);
            break;
        case Alert.NO:
            break;
    }
}
private function isTaskSelected(id:int):Boolean {
    return this["task"+id+"CB"].selected;
}
private function setCheckedTask(num:int,isChecked:Boolean)
{
    this["task"+num+"CB"].selected=isChecked;
}

protected function openCalendar(event:MouseEvent):void {
    PopUpManager.addPopUp(_calendarPanel, dateConsult, true);
}