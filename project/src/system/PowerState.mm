#import <Foundation/Foundation.h>

extern "C" int lime_ios_thermal_state()
{
	switch ([[NSProcessInfo processInfo] thermalState])
	{
		case NSProcessInfoThermalStateNominal: return 0;
		case NSProcessInfoThermalStateFair: return 1;
		case NSProcessInfoThermalStateSerious: return 3;
		case NSProcessInfoThermalStateCritical: return 4;
	}

	return -1;
}

extern "C" bool lime_ios_low_power_mode()
{
	return [[NSProcessInfo processInfo] isLowPowerModeEnabled];
}
