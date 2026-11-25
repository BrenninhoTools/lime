package lime.system;

enum abstract ThreadPriority(Int) from Int to Int
{
	var LOW = 0;
	var NORMAL = 1;
	var HIGH = 2;
	var TIME_CRITICAL = 3;
}
