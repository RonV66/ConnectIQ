import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TestView extends WatchUi.DataField {

    //hidden var mValue as String;
    hidden var breedte;
    hidden var hoogte;
    hidden var x = 0;
    hidden var valueView;
    hidden var labelView;

    var customFont = null;

    function initialize() {
        DataField.initialize();
        //mValue = "1966";
    }

    function onLayout(dc as Dc) as Void {

        customFont = WatchUi.loadResource(Rez.Fonts.roboto_bold_120);
        System.println(dc.getFontHeight(customFont));

        View.setLayout(Rez.Layouts.MainLayout(dc));

        labelView = View.findDrawableById("label");
        valueView = View.findDrawableById("value");

        labelView.setText(Rez.Strings.label);
    }

    function compute(info as Activity.Info) as Void {
    }

    function onUpdate(dc as Dc) as Void {
        
        valueView.setFont(customFont);
        valueView.locX = dc.getWidth() / 2;
        valueView.locY = (dc.getHeight() / 2) - (dc.getFontHeight(customFont) / 2);
        valueView.setText(Rez.Strings.value);

        View.onUpdate(dc);
    }

}
