var start_stop_btn, wpid=false, map, z, op, prev_lat, prev_long, min_speed=0, max_speed=0, min_altitude=0, max_altitude=0, distance_travelled=0, min_accuracy=151, date_pos_updated="", geoinfo_string="", string_head = "Csci 5715 - ";

// This function just adds a leading "0" to time/date components which are <10
function format_time_component(time_component)
{
	if(time_component<10)
		time_component="0"+time_component;
	else if(time_component.length<2)
		time_component=time_component+"0";
		
	return time_component;
}

// This is the function which is called each time the Geo location position is updated
function geo_success(position)
{
	start_stop_btn.innerHTML="Stop"; // Set the label on the start/stop button to "Stop"
	
	geoinfo_string="";
	var d=new Date(); // Date object, used below for output messahe
	var h=d.getHours();
	var m=d.getMinutes();
	var s=d.getSeconds();
		
	var current_time=format_time_component(h)+":"+format_time_component(m)+":"+format_time_component(s);
		
	// Check that the accuracy of our Geo location is sufficient for our needs
	if(position.coords.accuracy<=min_accuracy)
	{
			if(position.coords.speed>max_speed)
				max_speed=position.coords.speed;
			else if(position.coords.speed<min_speed)
				min_speed=position.coords.speed;
				
			if(position.coords.altitude>max_altitude)
				max_altitude=position.coords.altitude;
			else if(position.coords.altitude<min_altitude)
				min_altitude=position.coords.altitude;
			
			
			prev_lat=position.coords.latitude;
			prev_long=position.coords.longitude;
            prev_acc=position.coords.accuracy;
            
			geoinfo_string="<br/>" + string_head +"Current position: lat=" + prev_lat + "\u00B0, long=" + prev_long + "\u00B0 (accuracy " + prev_acc + "m) <br/>last reading taken at: "+ current_time;
		
	}
	else
		geoinfo_string="Accuracy not sufficient ("+position.coords.accuracy.toFixed(0)+"m vs "+min_accuracy+"m) - last reading taken at: "+current_time;

	if(geoinfo_string)
		op.innerHTML+=geoinfo_string;
}

// This function is called each time navigator.geolocation.watchPosition() generates an error (i.e. cannot get a Geo location reading)
function geo_error(error)
{
	switch(error.code)
	{
		case error.TIMEOUT:
			op.innerHTML="Timeout!";
		break;
	};
}


function get_pos()
{
	// Set up a watchPosition to constantly monitor the geo location provided by the browser - NOTE: !! forces a boolean response
	// We  use watchPosition rather than getPosition since it more easily allows (on IPhone at least) the browser/device to refine the geo location rather than simply taking the first available position
	// Full spec for navigator.geolocation can be foud here: http://dev.w3.org/geo/api/spec-source.html#geolocation_interface
	
	// First, check that the Browser is capable
	if(!!navigator.geolocation)
		wpid=navigator.geolocation.watchPosition(geo_success, geo_error, {enableHighAccuracy:true, maximumAge:30000, timeout:27000});
	else
		op.innerHTML="ERROR: Your Browser doesn't support the Geo Location API";
}


// Initialiser: This will find the output message div and set up the actions on the start/stop button
function init_geo()
{
	op=document.getElementById("output"); // Note the op is defined in global space and is therefore globally available
	
	if(op)
	{
		start_stop_btn=document.getElementById("geo_start_stop");
		
		
		if(start_stop_btn)
		{
			
			
			start_stop_btn.onclick=function()
			{
				if(wpid) // If we already have a wpid which is the ID returned by navigator.geolocation.watchPosition()
				{
					start_stop_btn.innerHTML="Start Streaming";
					navigator.geolocation.clearWatch(wpid);
					wpid=false;
				}
				else // Else...We should only ever get here right at the start of the process
				{
					start_stop_btn.innerHTML="Acquiring Geo Location...";
					get_pos();
				}
			}
			
			
		}
		else
			op.innerHTML="ERROR: Couldn't find the start/stop button";
	}
}

function toFixed(value, precision) {
    var power = Math.pow(10, precision || 0);
    return String(Math.round(value * power) / power);
}

//CSci 5715, Fall 15
// Initialise the whole system (above)
window.onload=init_geo;