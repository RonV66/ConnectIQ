import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
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
	var iconFont;
	var needsProtection = true;
	var lowMemDevice = true;
	var RBD = 0;
	var version;
	var showBoxes;
	var background_color_1;
	var background_color_2;
	var background_image;
	var use_background_image;
	var foreground_color;
	var box_color;
	var second_hand_color;
	var hour_min_hand_color;
	var text_color;
	var tick_style;
	var show_min_ticks;
	var ssloc = [100, 100];
	var xmult = 1.2;
	var ymult = 1.1;
	
    //relative to width percentage
	var relative_tick_stroke = .01;
    var relative_hour_tick_length = .08;
    var relative_min_tick_length = .04;
    var relative_hour_tick_stroke = .04;
    var relative_min_tick_stroke = .04;
	var relative_min_circle_tick_size = .01;
	var relative_hour_circle_tick_size = .02;
	var relative_hour_triangle_tick_size = .04;
	var relative_min_triangle_tick_size = .02;
    
    var relative_hour_hand_length = .20;
    var relative_min_hand_length = .40;
    var relative_sec_hand_length = .42;
    var relative_hour_hand_stroke = .013;
    var relative_min_hand_stroke = .013;
    var relative_sec_hand_stroke = .01;

	var relative_padding = .03;
    var relative_padding2 = .01;
    
    var relative_center_radius = .025;

	var text_padding = [1, 2];
	var box_padding = 2;
	var dow_size = [44, 19];
	var date_size = [24, 19];
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

//        System.println(breedte + "-" + hoogte);

//		mainFont = WatchUi.loadResource(Rez.Fonts.BigFont);
//		iconFont = WatchUi.loadResource(Rez.Fonts.BigIconFont);
		dow_size = [44 * 1.5, 19* 1.5];
		date_size = [24* 1.5, 19* 1.5];
		time_size = [48* 1.5, 19* 1.5];
		floors_size = [48* 1.5, 19* 1.5];
		battery_size = [32*1.5, 19*1.5];
		status_box_size = [94*1.5, 19*1.5];

		//updateValues(dc.getWidth());
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        setAchterGrondDisplay(dc);

        setClockDisplay();

        //setDateDisplay();
        //setBatteryDisplay();
        //setStepCountDisplay();
        //setStepGoalDisplay();
        ////setNotificationCountDisplay();
        //setHeartrateDisplay();
        // Call the parent onUpdate function to redraw the layout
        //View.onUpdate(dc);
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
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();
        var tick_style = 1;
		var show_min_ticks = true;

   		if (tick_style == 1) {
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			if(show_min_ticks) {
				drawTicks(dc, relative_hour_tick_length*width, relative_hour_tick_stroke*width, 12);
    			drawTicks(dc, relative_min_tick_length*width, relative_min_tick_stroke*width, 60);
			} else {
				drawTicks(dc, relative_min_tick_length*width, relative_min_tick_stroke*width, 12);
			}
		} else if(tick_style == 2) {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			if(show_min_ticks) {
				drawTicksCircle(dc, relative_hour_circle_tick_size*width, 1, 12);
    			drawTicksCircle(dc, relative_min_circle_tick_size*width, 1, 60);
			} else {
				drawTicksCircle(dc, relative_min_circle_tick_size*width, 1, 12);
			}
		} else if(tick_style == 3) {
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			if(show_min_ticks) {
				drawTicksTriangle(dc, relative_hour_triangle_tick_size*width, 1, 12);
    			drawTicksTriangle(dc, relative_min_triangle_tick_size*width, 1, 60);
			} else {
				drawTicksTriangle(dc, relative_min_triangle_tick_size*width, 1, 12);
			}
		}
    	/*drawDate(dc, centerOnLeft(dc, dow_size[0] + 4 + date_size[0]), width/2 - dow_size[1]/2);	
		drawBox(dc);
		drawStatusBox(dc, width/2, centerOnLeft(dc, status_box_size[1]));
    	
    	dc.setColor(hour_min_hand_color, Graphics.COLOR_TRANSPARENT);
    	drawHandOffset(dc, 12.00, 60.00, hours, minutes, relative_hour_hand_length*width, relative_hour_hand_stroke*width);

    	drawHand(dc, 60, minutes, relative_min_hand_length*width, relative_min_hand_stroke*width);
		*/
    }

    function drawTicks(dc, length, stroke, num) {
		dc.setPenWidth(dc.getWidth() * relative_tick_stroke);
    	var tickAngle = 360/num;
    	var center = dc.getWidth()/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
    		var x1 = center + Math.round(Math.cos(angle) * (center-length));
    		var y1 = center + Math.round(Math.sin(angle) * (center-length));
    		//2x^2 = 20
    		//x=10^0.5
    		var x2 = center + Math.round(Math.cos(angle) * (center));
    		var y2 = center + Math.round(Math.sin(angle) * (center));
    		
    		dc.drawLine(x1, y1, x2, y2);
    	}
    }

	function drawTicksCircle(dc, size, stroke, num) {
		dc.setPenWidth(dc.getWidth() * relative_tick_stroke);
    	var tickAngle = 360/num;
    	var center = dc.getWidth()/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
    		var x1 = center + Math.round(Math.cos(angle) * (center - size - 1)) - 1;
    		var y1 = center + Math.round(Math.sin(angle) * (center - size - 1)) - 1;    		
    		dc.fillEllipse(x1, y1, size, size);
    	}
	}

	function drawTicksTriangle(dc, length, stroke, num) {
		dc.setPenWidth(dc.getWidth() * relative_tick_stroke);
    	var tickAngle = 360/num;
    	var center = dc.getWidth()/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
			var offset = Math.toRadians(2);
    		var x1 = center + Math.round(Math.cos(angle) * (center-length));
    		var y1 = center + Math.round(Math.sin(angle) * (center-length));
    		//2x^2 = 20
    		//x=10^0.5
    		var x2 = center + Math.round(Math.cos(angle - offset) * (center));
    		var y2 = center + Math.round(Math.sin(angle - offset) * (center));

			var x3 = center + Math.round(Math.cos(angle + offset) * (center));
    		var y3 = center + Math.round(Math.sin(angle + offset) * (center));
    		
    		dc.fillPolygon([[x1, y1], [x2, y2], [x3, y3]]);
    	}
    }

    function drawHand(dc, num, time, length, stroke) {
    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
    	
    	var center = dc.getWidth()/2;
    	
    	dc.setPenWidth(stroke);
    	
    	var x = center + Math.round((Math.cos(angle) * length));
    	var y = center + Math.round((Math.sin(angle) * length));
    	
    	dc.drawLine(center, center, x, y);
    	
    }
    
    function drawSecondHandClip(dc, num, time, length, stroke) {
		dc.drawBitmap(0, 0, offScreenBuffer);

    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
    	var center = dc.getWidth()/2;
    	dc.setPenWidth(stroke);
    	
    	var cosval = Math.round(Math.cos(angle) * length);
    	var sinval = Math.round(Math.sin(angle) * length);
    	
    	var x = center + cosval;
    	var y = center + sinval;
    	var width2 = (center-x).abs();
    	var height2 = (center-y).abs();
    	var padding = width * relative_padding;
    	var padding2 = width * relative_padding2;
    	
    	if(cosval < 0 && sinval > 0) {
    		dc.setClip(center-width2-padding2, center-padding, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval < 0 && sinval < 0) {
    		dc.setClip(center-width2-padding2, center-height2-padding2, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval > 0 && sinval < 0) {
    		dc.setClip(center-padding, center-height2-padding2, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval > 0 && sinval > 0) {
	    	dc.setClip(center-padding, center-padding, width2+padding+padding2, height2+padding+padding2);
    	}
    	

    	dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
    	dc.drawLine(center, center, x, y);    	
    }
    
	//Draws a hand with an offset for a seperate time set (eg. hour hand)
    function drawHandOffset(dc, num, offsetNum, time, offsetTime, length, stroke) {
    	var angle = Math.toRadians((360/num) * time ) - Math.PI/2;
    	var section = 360.00/num/offsetNum;
    	
    	angle += Math.toRadians(section * offsetTime);
    	
    	var center = dc.getWidth()/2;
    	
    	dc.setPenWidth(stroke);
    	
    	var x = center + Math.round(Math.cos(angle) * length);
    	var y = center + Math.round(Math.sin(angle) * length);
    	
    	dc.drawLine(center, center, x, y);
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
/*
	function drawDate(dc, x, y) {
//		var width = dc.getWidth();
//		var height = dc.getHeight();
    	var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
		var dowString = info.day_of_week;
		
		drawTextBox(dc, dowString, x, y, dow_size[0], dow_size[1]);
		drawTextBox(dc, info.day.toString(), x + dow_size[0] + 4, y, date_size[0], date_size[1]);
    }
*/
/*    
    function drawTimeBox(dc, x, y) {
//		var width = dc.getWidth();
    	var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
    	var clockTime = System.getClockTime();
		var hours = clockTime.hour.format("%02d").toNumber();
		var hourString = hours;

		if(!is24 && hours > 12) {
			hours -= 12;
			hourString = hours;
		}

		if(hours < 10) {
			hourString = " " + hourString;
		}

		drawTextBox(dc, hourString + ":" + clockTime.min.format("%02d"), x, y, time_size[0], time_size[1]);
    }
*/
/*	
	function drawStepBox(dc, x, y) {
//		var width = dc.getWidth();
		var steps = ActivityMonitor.getInfo().steps;
		var stepString;
		if(steps > 99999) {
			stepString = "99+k";
		} else {
			stepString = (steps.toDouble()/1000).format("%.1f") + "k";
		}
		// System.out.println(steps);

		drawTextBox(dc, stepString, x, y, time_size[0], time_size[1]);
	}
*/
/*
	function drawFloorsBox(dc, x, y) {
//		var width = dc.getWidth();
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

	function drawTextBox(dc, text, x, y, width, height) {
		dc.setPenWidth(2);
    	dc.setColor(box_color, Graphics.COLOR_WHITE);
		if(showBoxes) {
   			dc.drawRoundedRectangle(x, y, width, height, box_padding);
		}
    	
		var boxText = new WatchUi.Text({
            :text=>text,
            :color=>text_color,
            :font=>mainFont,
            :locX =>x + text_padding[0],
            :locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_LEFT
        });

		boxText.draw(dc);
	}
*/






/////////////////////////////////////////////////////////////////////////////////////
    private function setClockDisplay() {
        var clockTime = System.getClockTime();
/*        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }*/
        var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);

        // Update the view
        var timeDisplay = View.findDrawableById("TimeDisplay") as Text;
        timeDisplay.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        timeDisplay.setText(timeString);
    }

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
    
    private function setHeartrateDisplay() {
    	var heartRate = "";
    	
    	if(ActivityMonitor has :INVALID_HR_SAMPLE) {
    		heartRate = retrieveHeartrateText();
    	}
    	else {
    		heartRate = "";
    	}
    	var heartrateDisplay = View.findDrawableById("HeartrateDisplay") as Text;

    	heartrateDisplay.setText(heartRate);
    }
    
    private function retrieveHeartrateText() {
    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
    	var currentHeartrate = heartrateIterator.next().heartRate;

    	if(currentHeartrate == ActivityMonitor.INVALID_HR_SAMPLE) {
	    	return "";
	    }
    	return currentHeartrate.format("%d");
    }

}
