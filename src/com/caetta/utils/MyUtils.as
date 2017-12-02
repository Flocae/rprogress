/**
 * Created by florent on 26/11/2017.
 */
package com.caetta.utils {
import flash.desktop.NativeApplication;

public class MyUtils {

    /*Read app descriptor file and return app version */
    public static function getAppVersion():String {
        var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
        var ns:Namespace = appXml.namespace();
        var appVersion:String = appXml.ns::versionNumber[0];
        return appVersion;
    }

}
}
