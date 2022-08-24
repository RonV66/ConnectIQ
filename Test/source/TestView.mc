import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
//import Toybox.System;
//import Toybox.Math;
//import Toybox.Sensor;

class TestView extends WatchUi.DataField {

    var W;
	var H;
    var F;
    var FONT = Graphics.FONT_XTINY;
    var clockRads = 0;
    var hoek = 0;
    var radius = 0;
    var middelpuntX;
    var middelpuntY;
    var rad = new [4];
    var p = [[0,0],[0,0],[0,0],[0,0],[0,0]];

    function initialize() {
        DataField.initialize();
    }

    function onLayout(dc as Dc) as Void {
    	W = dc.getWidth();
    	H = dc.getHeight();
        F = dc.getFontHeight(FONT);
        middelpuntX = W/2;
        middelpuntY = H/2;

        rad[0] = Math.sqrt(Math.pow(0,2) + Math.pow(-35,2));
        rad[1] = Math.sqrt(Math.pow(30,2) + Math.pow(20,2));
        rad[2] = Math.sqrt(Math.pow(0,2) + Math.pow(5,2));
        rad[3] = Math.sqrt(Math.pow(-30,2) + Math.pow(20,2));

        ////////////////////////////////////

    }

    function compute(info as Activity.Info) as Void {
       hoek = Math.toDegrees(info.currentHeading);
    }

    function onUpdate(dc as Dc) as Void {

        ////////////////////////////////////

    	dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        dc.fillCircle(W / 2, H / 2, 56);

        ////////////////////////////////////

    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);

        var string = "WNOZNWNOZOZW";
        dc.drawText((W / 2) - 65, (H / 2) - (F / 2), FONT, string.substring(0, 1), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((W / 2), (H / 2) - 65 - (F / 2), FONT, string.substring(1, 2), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((W / 2) + 65, (H / 2) - (F / 2), FONT, string.substring(2, 3), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((W / 2), (H / 2) + 65 - (F / 2), FONT, string.substring(3, 4), Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText((W / 2) - 50, (H / 2) - 50 - (F / 2), FONT, string.substring(4, 6), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((W / 2) + 50, (H / 2) - 50 - (F / 2), FONT, string.substring(6, 8), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((W / 2) + 50, (H / 2) + 50 - (F / 2), FONT, string.substring(8, 10), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText((W / 2) - 50, (H / 2) + 50 - (F / 2), FONT, string.substring(10, 12), Graphics.TEXT_JUSTIFY_CENTER);

        ////////////////////////////////////

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        /////////////////////////////////////////////////////////
        clockRads = Math.toRadians(hoek);
        var cos = Math.cos(clockRads);
        var sin = Math.sin(clockRads);
        p[0][0] = middelpuntX + (rad[0] * sin);
        p[0][1] = middelpuntY - (rad[0] * cos);
        p[4][0] = p[0][0];
        p[4][1] = p[0][1];
        /////////////////////////////////////////////////////////
        clockRads = Math.toRadians(hoek + 120);
        cos = Math.cos(clockRads);
        sin = Math.sin(clockRads);
        p[1][0] = middelpuntX + (rad[1] * sin);
        p[1][1] = middelpuntY - (rad[1] * cos);
        /////////////////////////////////////////////////////////
        clockRads = Math.toRadians(hoek + 180);
        cos = Math.cos(clockRads);
        sin = Math.sin(clockRads);
        p[2][0] = middelpuntX + (rad[2] * sin);
        p[2][1] = middelpuntY - (rad[2] * cos);
        ////////////////////////////////////////////////////////
        clockRads = Math.toRadians(hoek + 240);
        cos = Math.cos(clockRads);
        sin = Math.sin(clockRads);
        p[3][0] = middelpuntX + (rad[3] * sin);
        p[3][1] = middelpuntY - (rad[3] * cos);
        ////////////////////////////////////////////////////////
        dc.fillPolygon(p);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W/2, 260, Graphics.FONT_LARGE, hoek.format("%.0f"), Graphics.TEXT_JUSTIFY_CENTER);

        // Call parent's onUpdate(dc) to redraw the layout
//        View.onUpdate(dc);

    }
}
