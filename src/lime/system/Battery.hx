package lime.system;

#if (lime_cffi && !macro)
import lime._internal.backend.native.NativeCFFI;
#end

#if (lime_cffi && !macro)
@:access(lime._internal.backend.native.NativeCFFI)
#end
class Battery
{
	public static var state(get, never):BatteryState;
	public static var percent(get, never):Int;
	public static var secondsLeft(get, never):Int;
	public static var hasBattery(get, never):Bool;
	public static var charging(get, never):Bool;
	public static var onBattery(get, never):Bool;
	public static var low(get, never):Bool;

	public static var lowThreshold:Int = 20;

	static function get_state():BatteryState
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_power_state();
		#else
		return UNKNOWN;
		#end
	}

	static function get_percent():Int
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_battery_percent();
		#else
		return -1;
		#end
	}

	static function get_secondsLeft():Int
	{
		#if (lime_cffi && !macro)
		return NativeCFFI.lime_hardware_get_battery_seconds();
		#else
		return -1;
		#end
	}

	static function get_hasBattery():Bool
	{
		var current:BatteryState = state;
		return current == ON_BATTERY || current == CHARGING || current == CHARGED;
	}

	static inline function get_charging():Bool
	{
		return state == CHARGING;
	}

	static inline function get_onBattery():Bool
	{
		return state == ON_BATTERY;
	}

	static function get_low():Bool
	{
		if (state != ON_BATTERY) return false;
		var value:Int = percent;
		return value >= 0 && value <= lowThreshold;
	}
}
