/**
 * Created by Florent Caetta on 30/07/2017.
 */
package db {
import breezedb.models.BreezeModel;
import breezedb.models.BreezeModelQueryBuilder;

public class DbORM  extends BreezeModel{
    // All public variables represent the respective columns in the table.

    public var id:int;
    public var nom:String;
    public var prenom:String;
    public var date:Date;
    public var progress:int;
    public var task1:Boolean;
    public var task2:Boolean;
    public var task3:Boolean;
    public var task4:Boolean;
    public var task5:Boolean;
    public var task6:Boolean;
    public var task7:Boolean;
    public var task8:Boolean;
    public var task9:Boolean;
    public var task10:Boolean;
    public var notes:String;

    public function DbORM() {
        super();
        _databaseName=dbShema.dbName;
        _tableName=dbShema.tableName;

    }
    public static function query():BreezeModelQueryBuilder
    {
        return new BreezeModelQueryBuilder(DbORM);
    }
}
}
