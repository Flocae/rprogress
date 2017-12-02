/**
 * Created by Florent Caetta on 30/07/2017.
 */
package db {
import breezedb.BreezeDb;
import breezedb.IBreezeDatabase;
import breezedb.schemas.TableBlueprint;

import flash.filesystem.File;

public class dbShema {
    private static var _dbName:String="rprogressDatabase";
    private static var _tableName:String="rprogress";
    private static var _customDb:IBreezeDatabase;
    public static function createDB():void{
        // create db if not exist
        BreezeDb.storageDirectory=File.documentsDirectory;//Save db - user's documents
        _customDb=BreezeDb.getDb(_dbName);
        _customDb.setup(function(error:Error):void
        {
            if(error == null)
            {
                trace("The database has been set up");
                setTable();
            }
        });
    }
    private static function setTable():void
    {
        //customDb=BreezeDb.getDb(DB_NAME);
        _customDb.schema.createTable(_tableName, function(table:TableBlueprint):void
                {
                    table.increments("id");
                    table.string("nom");
                    table.string("prenom");
                    table.date("date");
                    table.integer("progress");
                    table.boolean("task1");
                    table.boolean("task2");
                    table.boolean("task3");
                    table.boolean("task4");
                    table.boolean("task5");
                    table.boolean("task6");
                    table.boolean("task7");
                    table.boolean("task8");
                    table.boolean("task9");
                    table.boolean("task10");
                    table.string("notes");

                },
                function(error:Error):void
                {
                    if(error == null)
                    {
                        trace("table was created successfully");
                    }
                });
    }

    public static function get dbName():String {
        return _dbName;
    }

    public static function get tableName():String {
        return _tableName;
    }

    public static function get customDb():IBreezeDatabase {
        return _customDb;
    }
}
}
