import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
using Toybox.Time.Gregorian as Datum;
//using Toybox.System as Sys;
//using Toybox.ActivityMonitor as Mon;

class WatchFaceView extends WatchUi.WatchFace {
    hidden var width;
    hidden var height;

    var lowPower = false;
	var offScreenBuffer;
    var is24 = System.getDeviceSettings().is24Hour;
	var isDistanceMetric = true;
    var clip;
	var partialUpdates = false;
	var showTicks;
	var mainFont;
	var bigFont;
	var iconFont;
	var bigIconFont;
	var needsProtection = true;
	var lowMemDevice = true;
	var RBD = 0;
	var version;
	var showBoxes = true;
	var background_color; // = Graphics.COLOR_BLACK;
	var background_image;
	var use_background_image;
	var foreground_color; // = Graphics.COLOR_WHITE;
	var box_color; // = Graphics.COLOR_WHITE;
	var second_hand_color = Graphics.COLOR_RED;
	var hour_min_hand_color = Graphics.COLOR_WHITE;
	var text_color;
	var tick_style;
	var show_min_ticks = true;
	var show_sec_hand = true;
	var ssloc = [100, 100];
	var xmult = 1.2;
	var ymult = 1.1;
	
    //relative to width percentage
	var relative_tick_stroke = .01;
    var relative_hour_tick_length = .04;
    var relative_min_tick_length = .04;
    var relative_hour_tick_stroke = .02;
    var relative_min_tick_stroke = .003;
	var relative_min_circle_tick_size = .01;
	var relative_hour_circle_tick_size = .02;
	var relative_hour_triangle_tick_size = .04;
	var relative_min_triangle_tick_size = .02;
    
    var relative_hour_hand_length = .30;
    var relative_min_hand_length = .38;
    var relative_sec_hand_length = .42;
    var relative_hour_hand_stroke = .013;
    var relative_min_hand_stroke = .013;
    var relative_sec_hand_stroke = .01;

	var relative_padding = .03;
    var relative_padding2 = .01;
    
    var relative_center_radius = .025;

	var box_padding = 2;
	var date_size_x = 80;
	var date_size_y = 30;
	var circle_rad = 45;

	var text_padding = [1, 2];
	var dow_size = [44, 19];
	var time_size = [48, 19];
	var floors_size = [40, 19];
	var battery_size = [32, 19];
	var status_box_size = [94, 19];

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        width = dc.getWidth();
        height = dc.getHeight();

		mainFont = WatchUi.loadResource(Rez.Fonts.MainFont);
		bigFont = WatchUi.loadResource(Rez.Fonts.BigFont);
		bigIconFont = WatchUi.loadResource(Rez.Fonts.BigIconFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.IconFont);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
		background_color = Application.Properties.getValue("BackgroundColor");
        foreground_color = Application.Properties.getValue("ForegroundColor");
		text_color = Application.Properties.getValue("TextColor");
		box_color = Application.Properties.getValue("BoxColor");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
		if (!lowPower) {
			// Get System Time
			var clockTime = System.getClockTime();
			var hours = clockTime.hour;
			var minutes = clockTime.min;
			var seconds = clockTime.sec;

			// Set minute and hour circle
			setAchterGrondDisplay(dc);

			drawDate(dc, width*2/3, height/2);
			drawStepBox(dc, width/2, height/4);
			drawHeartRateBox(dc, width/4, height/2);

			//Set hour and minute hand
			dc.setColor(hour_min_hand_color, Graphics.COLOR_TRANSPARENT);
			drawHandMinuut(dc, 60, minutes, relative_min_hand_length*width, hour_min_hand_color);
			drawHandUur(dc, 12, hours, minutes, relative_hour_hand_length*width, hour_min_hand_color );
			if(show_sec_hand) {
				drawSecondHandClip(dc, 60, seconds, relative_sec_hand_length*width);
			}

			//setDateDisplay();
			//setBatteryDisplay();
			//setStepCountDisplay();
			//setStepGoalDisplay();
			////setNotificationCountDisplay();
			//setHeartrateDisplay();
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
		lowPower = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
		lowPower = true;
    }

    private function setAchterGrondDisplay(dc as Dc) as Void {
    	dc.setColor(background_color, background_color);
    	dc.clear();

		dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
		if(show_min_ticks) {
			drawTicksMinuten(dc, relative_min_tick_length*width, relative_min_tick_stroke*width, 60);
		}
		drawTicksUren(dc, 0.91*width, 12);
		drawTicksUren1(dc, relative_hour_tick_length*width, 4);
		drawTicksUren2(dc, relative_hour_tick_length*width, 12);
    }

    function drawTicksMinuten(dc, length, stroke, num) {
		dc.setPenWidth(stroke);
    	var tickAngle = 360/num;
    	var center = width/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
    		var x1 = center + Math.round(Math.cos(angle) * (center-length));
    		var y1 = center + Math.round(Math.sin(angle) * (center-length));
    		var x2 = center + Math.round(Math.cos(angle) * (center));
    		var y2 = center + Math.round(Math.sin(angle) * (center));
    		dc.drawLine(x1, y1, x2, y2);
    	}
    }

	function drawTicksUren(dc, length, num) {
    	var tickAngle = 360/num;
    	var center = width/2;
		var getal = 1;
    	for(var i = 4; i < num+4; i++) {
			var angle = Math.toRadians(tickAngle * i);
			var x1 = center + Math.round(Math.cos(angle) * (center - length));
			var y1 = center + Math.round(Math.sin(angle) * (center - length));
			dc.drawText(
				x1,
				y1,
				bigFont,
				getal.toString(),
				Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
			);
			getal+=1;
    	}
    }

	function drawTicksUren1(dc, length, num) {
    	var tickAngle = 360/num;
    	var center = width/2;
    	for(var i = 0; i < num; i++) {
			var angle = Math.toRadians(tickAngle * i);
			var offset = Math.toRadians(2);
			var x1 = center + Math.round(Math.cos(angle) * (center - length));
			var y1 = center + Math.round(Math.sin(angle) * (center - length));
			var x2 = center + Math.round(Math.cos(angle - offset) * (center - (length/2)));
			var y2 = center + Math.round(Math.sin(angle - offset) * (center - (length/2)));
			var x3 = center + Math.round(Math.cos(angle - offset) * (center));
			var y3 = center + Math.round(Math.sin(angle - offset) * (center));
			var x4 = center + Math.round(Math.cos(angle + offset) * (center));
			var y4 = center + Math.round(Math.sin(angle + offset) * (center));
			var x5 = center + Math.round(Math.cos(angle + offset) * (center - (length/2)));
			var y5 = center + Math.round(Math.sin(angle + offset) * (center - (length/2)));
			dc.fillPolygon([[x1, y1], [x2, y2], [x3, y3], [x4, y4], [x5, y5]]);
    	}
    }

	function drawTicksUren2(dc, length, num) {
    	var tickAngle = 360/num;
    	var center = width/2;
    	for(var i = 0; i < num; i++) {
			if ((i != 0) and (i != 3) and (i != 6) and (i != 9)) {
				var angle = Math.toRadians(tickAngle * i);
				var offset = Math.toRadians(1);
				var x2 = center + Math.round(Math.cos(angle - offset) * (center - length));
				var y2 = center + Math.round(Math.sin(angle - offset) * (center - length));
				var x3 = center + Math.round(Math.cos(angle - offset) * (center));
				var y3 = center + Math.round(Math.sin(angle - offset) * (center));
				var x4 = center + Math.round(Math.cos(angle + offset) * (center));
				var y4 = center + Math.round(Math.sin(angle + offset) * (center));
				var x5 = center + Math.round(Math.cos(angle + offset) * (center - length));
				var y5 = center + Math.round(Math.sin(angle + offset) * (center - length));
				dc.fillPolygon([[x2, y2], [x3, y3], [x4, y4], [x5, y5]]);
			}
    	}
    }

    function drawHandMinuut(dc, num, time, length, kleur) {
    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
    	var center = width/2;

		var offset = Math.toRadians(3.0);
    	var x = center + Math.round(Math.cos(angle) * (length + 6));
    	var y = center + Math.round(Math.sin(angle) * (length + 6));
    	var x1 = center + Math.round(Math.cos(angle - offset) * length);
    	var y1 = center + Math.round(Math.sin(angle - offset) * length);
    	var x2 = center + Math.round(Math.cos(angle + offset) * length);
    	var y2 = center + Math.round(Math.sin(angle + offset) * length);
		var x3 = center + x - x1;
		var y3 = center + y - y1;
		var x4 = center + x - x2;
		var y4 = center + y - y2;
	   	dc.setColor(kleur, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon([[x1,y1],[x,y],[x2,y2],[x3,y3],[x4,y4]]);

		dc.setPenWidth(2);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.drawLine(x1, y1, x, y);
		dc.drawLine(x, y, x2, y2);
		dc.drawLine(x2, y2, x3, y3);
		dc.drawLine(x4, y4, x1, y1);

		if (num == 60) {
			dc.setColor(kleur, Graphics.COLOR_TRANSPARENT);
			dc.fillCircle(center, center, 16);

			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			dc.drawCircle(center, center, 16);
		}
    }

    function drawHandUur(dc, num, time, offsetTime, length, kleur) {
		var center = width/2;

    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
		var section = 360.00/12/60;
		angle += Math.toRadians(section * offsetTime);

		var offset = Math.toRadians(3.0);
    	var x = center + Math.round(Math.cos(angle) * (length + 6));
    	var y = center + Math.round(Math.sin(angle) * (length + 6));
    	var x1 = center + Math.round(Math.cos(angle - offset) * length);
    	var y1 = center + Math.round(Math.sin(angle - offset) * length);
    	var x2 = center + Math.round(Math.cos(angle + offset) * length);
    	var y2 = center + Math.round(Math.sin(angle + offset) * length);
		var x3 = center + x - x1;
		var y3 = center + y - y1;
		var x4 = center + x - x2;
		var y4 = center + y - y2;
	   	dc.setColor(kleur, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon([[x1,y1],[x,y],[x2,y2],[x3,y3],[x4,y4]]);

		dc.setPenWidth(2);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.drawLine(x1, y1, x, y);
		dc.drawLine(x, y, x2, y2);
		dc.drawLine(x2, y2, x3, y3);
		dc.drawLine(x4, y4, x1, y1);

		if (num == 60) {
			dc.setColor(kleur, Graphics.COLOR_TRANSPARENT);
			dc.fillCircle(center, center, 16);

			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			dc.drawCircle(center, center, 16);
		}
    }

    function drawSecondHandClip(dc, num, time, length) {
    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
		var center = width/2;

		var offset = Math.toRadians(1.0);
	  	var x = center + Math.round(Math.cos(angle) * length);
    	var y = center + Math.round(Math.sin(angle) * length);
    	var x1 = center + Math.round(Math.cos(angle - offset) * length);
    	var y1 = center + Math.round(Math.sin(angle - offset) * length);
    	var x2 = center + Math.round(Math.cos(angle + offset) * length);
    	var y2 = center + Math.round(Math.sin(angle + offset) * length);
	  	var xx = center - Math.round(Math.cos(angle) * (length/4));
    	var yy = center - Math.round(Math.sin(angle) * (length/4));

		var x3 = xx + x - x1;
		var y3 = yy + y - y1;
		var x4 = xx + x - x2;
		var y4 = yy + y - y2;

		dc.setPenWidth(2);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLUE);
		dc.drawCircle(center, center, 8);

		dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon([[x1,y1],[x2,y2],[x3,y3],[x4,y4]]);

		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.setPenWidth(1);
		dc.drawLine(x1, y1, x2, y2);
		dc.drawLine(x2, y2, x3, y3);
		dc.drawLine(x3, y3, x4, y4);
		dc.drawLine(x4, y4, x1, y1);

		dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(center, center, 8);
    }

	function drawDate(dc, x, y) {
        var now = Time.now();
	    var date = Datum.info(now, Time.FORMAT_LONG);
	    var dateString = Lang.format("$1$ $2$", [date.day_of_week, date.day]);

		drawTextBoxBigFont(dc, dateString, x, y - (date_size_y/2), date_size_x, date_size_y);
    }

	function drawStepBox(dc, x, y) {
		var text = Rez.Strings.Steps;

		var steps = ActivityMonitor.getInfo().steps;
		var stepString = steps.format("%d");

		var stepsGoal = ActivityMonitor.getInfo().stepGoal;
		var soFar = (steps > stepsGoal) ? 280 : (280 * steps / stepsGoal);

		drawTextCircleBigFont(dc, text, stepString, soFar, x, y, circle_rad, Graphics.COLOR_GREEN);
	}

	function drawHeartRateBox(dc, x, y) {
		var text = Rez.Strings.HeartRate;

		var heartRateZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
		var minimum = heartRateZones[0];
		var maximum = heartRateZones[5];

		var circleColor = text_color;
		var soFar = 0;
		var heartRate = 0;
		var heartRateString = "--";
		if(ActivityMonitor has :INVALID_HR_SAMPLE) {
			var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
    		heartRate = heartrateIterator.next().heartRate;
    		if (heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
    			heartRateString = heartRate.format("%d");
				soFar = 280 * (heartRate-minimum) / (maximum-minimum);
				if (soFar < 0) { soFar = 0; }
				else if (soFar > 280) { soFar = 280; }
                if ((heartRate >= heartRateZones[0]) and (heartRate < heartRateZones[1])) {circleColor = Graphics.COLOR_LT_GRAY;}
                else if ((heartRate >= heartRateZones[1]) and (heartRate < heartRateZones[2])) {circleColor = Graphics.COLOR_BLUE;}
                else if ((heartRate >= heartRateZones[2]) and (heartRate < heartRateZones[3])) {circleColor = Graphics.COLOR_DK_GREEN;}
                else if ((heartRate >= heartRateZones[3]) and (heartRate < heartRateZones[4])) {circleColor = 0xFAA918;}  //Graphics.COLOR_ORANGE
                else if (heartRate >= heartRateZones[4]) {circleColor = Graphics.COLOR_RED;}
			}
		}

		drawTextCircleBigFont(dc, text, heartRateString, soFar, x, y, circle_rad, circleColor);
	}


/*
    function drawStatusBox(dc, x, y) {
		var status_string = "";
		var settings = System.getDeviceSettings();
		var status = System.getSystemStats();

		if(settings.phoneConnected) {
			status_string += "K";
		}

		if(settings.alarmCount > 0) {
			status_string += "H";
		}

		if (settings has :doNotDisturb) {
			if(settings.doNotDisturb) {
				status_string += "I";
			}
		}

		if(settings.notificationCount > 0) {
			status_string += "J";
		}

		if(status has :charging && status.charging) {
			status_string += "A";
		} else if(status.battery > 86) {
			status_string += "G";
		} else if(status.battery > 72) {
			status_string += "F";
		} else if(status.battery > 56) {
			status_string += "E";
		} else if(status.battery > 40) {
			status_string += "D";
		} else if(status.battery > 24) {
			status_string += "C";
		} else {
			status_string += "B";
		}

		dc.setPenWidth(2);
    	dc.setColor(box_color, Graphics.COLOR_WHITE);
		if(showBoxes) {
   			// dc.drawRoundedRectangle(x - status_box_size[0]/2, y, status_box_size[0], status_box_size[1], box_padding);
		}
    	
		var boxText = new WatchUi.Text({
            :text=>status_string,
            :color=>text_color,
            :font=>iconFont,
            :locX =>x + text_padding[0],
            :locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_CENTER
        });

		boxText.draw(dc);
    }
*/


	function drawTextBoxMainFont(dc, text, x, y, width, height) {
		dc.setPenWidth(2);
    	dc.setColor(box_color, Graphics.COLOR_TRANSPARENT);
		if(showBoxes) {
   			dc.drawRoundedRectangle(x, y, width, height, box_padding);
		}
    	
		var boxText = new WatchUi.Text({
            :text=>text,
            :color=>text_color,
            :font=>mainFont,
            :locX =>x + (width/2),
            :locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_CENTER
        });

		boxText.draw(dc);
	}

	function drawTextBoxBigFont(dc, text, x, y, width, height) {
		dc.setPenWidth(2);
    	dc.setColor(box_color, Graphics.COLOR_TRANSPARENT);
		if(showBoxes) {
   			dc.drawRoundedRectangle(x, y, width, height, box_padding);
		}
    	
		var boxText = new WatchUi.Text({
            :text=>text,
            :color=>text_color,
            :font=>bigFont,
            :locX =>x + (width/2),
            :locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_CENTER
        });

		boxText.draw(dc);
	}

	function drawTextCircleBigFont(dc, text, waarde, soFar, x, y, radian, honderdpercent) {
		soFar = 230 - soFar;
		soFar = ((soFar < 0) ? (soFar + 360) : soFar);

		dc.setPenWidth(1);
    	dc.setColor(box_color, Graphics.COLOR_TRANSPARENT);
		if(showBoxes) {
			dc.drawArc(x,y,radian, dc.ARC_CLOCKWISE, 230, 310);
			dc.setPenWidth(3);
			dc.setColor(honderdpercent, Graphics.COLOR_TRANSPARENT);
			if (soFar != 230) {
				dc.drawArc(x,y,radian,dc.ARC_CLOCKWISE, 230, soFar);
			}
		}

		var h = dc.getFontHeight(bigFont) / 2;
		var boxText = new WatchUi.Text({
            :text => waarde,
            :color => text_color,
            :font => bigFont,
            :locX => x,
            :locY => y - h,
			:justification => Graphics.TEXT_JUSTIFY_CENTER
        });
		boxText.draw(dc);
		boxText = new WatchUi.Text({
            :text => text,
            :color => text_color,
            :font => mainFont,
            :locX => x,
            :locY => y + radian/2,
			:justification => Graphics.TEXT_JUSTIFY_CENTER
        });
		boxText.draw(dc);
	}


/////////////////////////////////////////////////////////////////////////////////////

/*
	function drawFloorsBox(dc, x, y) {
		var floors;
		var floorString;

		if(ActivityMonitor.getInfo() has :floorsClimbed) {
			floors = ActivityMonitor.getInfo().floorsClimbed;

			if(floors > 999) {
				floorString = "999+";
			} else {
				floorString = floors.toString();
			}
		} else {
			floorString = "NA";
		}

		drawTextBox(dc, floorString, x, y, floors_size[0], floors_size[1]);
	}
*/
/*
	function drawCaloriesBox(dc, x, y) {
//		var width = dc.getWidth();
		var calories;
		calories = ActivityMonitor.getInfo().calories;

		var calorieString;
		if(calories > 99999) {
			calorieString = "99+k";
		} else {
			calorieString = (calories.toDouble()/1000).format("%0.1f") + "k";
		}

		// System.out.println(steps);

		drawTextBox(dc, calorieString, x, y, time_size[0], time_size[1]);
	}
*/
/*
	function drawDistanceBox(dc, x, y) {
//		var width = dc.getWidth();
		var distance;
		distance = ActivityMonitor.getInfo().distance/1000000;
		System.println(distance);
		if(!isDistanceMetric) {
			distance *= .621371;
		} 
		var distanceString;
		if(distance > 999) {
			distanceString = "999+";
		} else {
			distanceString = (distance).format("%.1f");
		}

		drawTextBox(dc, distanceString, x, y, time_size[0], time_size[1]);
	}
*/
/*
	function drawBatteryBox(dc, x, y) {
//		var width = dc.getWidth();
		var battery = System.getSystemStats().battery;

		var batteryString = battery.format("%.0f");

		drawTextBox(dc, batteryString, x, y, battery_size[0], battery_size[1]);
	}
*/




/*    private function setClockDisplay() {
        var clockTime = System.getClockTime();
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);

        // Update the view
        var timeDisplay = View.findDrawableById("TimeDisplay") as Text;
        timeDisplay.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        timeDisplay.setText(timeString);
    }
*/
/*
    private function setDateDisplay() {        
        var now = Time.now();
	    var date = Datum.info(now, Time.FORMAT_LONG);
	    var dateString = Lang.format("$1$ $2$, $3$", [date.month, date.day, date.year]);

	    var dateDisplay = View.findDrawableById("DateDisplay") as Text;
        dateDisplay.setColor(Application.Properties.getValue("ForegroundColor") as Number);
	    dateDisplay.setText(dateString);	    	
    }

    private function setBatteryDisplay() {
    	var battery = System.getSystemStats().battery;				
	    var batteryDisplay = View.findDrawableById("BatteryDisplay") as Text;

	    batteryDisplay.setText(battery.format("%d")+"%");
    }
    
    private function setStepCountDisplay() {
    	var stepCount = ActivityMonitor.getInfo().steps.toString();		
    	var stepCountDisplay = View.findDrawableById("StepCountDisplay") as Text;

	    stepCountDisplay.setText(stepCount);		
    }
    
    private function setStepGoalDisplay() {
    	var stepGoalPercent = ((ActivityMonitor.getInfo().steps).toFloat() / (ActivityMonitor.getInfo().stepGoal).toFloat() * 100f);
	    var stepGoalDisplay = View.findDrawableById("StepGoalDisplay") as Text;

	    stepGoalDisplay.setText(stepGoalPercent.format( "%d" ) + "%");	
    }
    
    private function setNotificationCountDisplay() {
    	var notificationAmount = System.getDeviceSettings().notificationCount;
    	var formattedNotificationAmount = "";

	    if(notificationAmount > 10)	{
		    formattedNotificationAmount = "10+";
	    }
	    else {
		    formattedNotificationAmount = notificationAmount.format("%d");
	    }
	    var notificationCountDisplay = View.findDrawableById("NotificationCountDisplay") as Text;

    	notificationCountDisplay.setText(formattedNotificationAmount);
    }
*/    

}
