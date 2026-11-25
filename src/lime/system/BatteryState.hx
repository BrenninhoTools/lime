package lime.system;

enum abstract BatteryState(Int) from Int to Int
{
	var ERROR = -1;
	var UNKNOWN = 0;
	var ON_BATTERY = 1;
	var NO_BATTERY = 2;
	var CHARGING = 3;
	var CHARGED = 4;

	public function toString():String
	{
		return switch ((cast this : BatteryState))
		{
			case ERROR: "error";
			case ON_BATTERY: "on battery";
			case NO_BATTERY: "no battery";
			case CHARGING: "charging";
			case CHARGED: "charged";
			default: "unknown";
		}
	}
}
