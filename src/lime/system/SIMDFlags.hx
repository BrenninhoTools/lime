package lime.system;

enum abstract SIMDFlags(Int) from Int to Int
{
	var NONE = 0;
	var MMX = 1 << 0;
	var SSE = 1 << 1;
	var SSE2 = 1 << 2;
	var SSE3 = 1 << 3;
	var SSE41 = 1 << 4;
	var SSE42 = 1 << 5;
	var AVX = 1 << 6;
	var AVX2 = 1 << 7;
	var AVX512F = 1 << 8;
	var ALTIVEC = 1 << 9;
	var ARMSIMD = 1 << 10;
	var NEON = 1 << 11;
	var LSX = 1 << 12;
	var LASX = 1 << 13;

	public inline function has(flag:SIMDFlags):Bool
	{
		return (this & (flag : Int)) != 0;
	}

	public function toArray():Array<String>
	{
		var names:Array<String> = [];
		var all:Array<SIMDFlags> = [MMX, SSE, SSE2, SSE3, SSE41, SSE42, AVX, AVX2, AVX512F, ALTIVEC, ARMSIMD, NEON, LSX, LASX];
		var labels:Array<String> = ["MMX", "SSE", "SSE2", "SSE3", "SSE4.1", "SSE4.2", "AVX", "AVX2", "AVX-512F", "AltiVec", "ARM SIMD", "NEON", "LSX", "LASX"];
		for (i in 0...all.length)
			if (has(all[i])) names.push(labels[i]);
		return names;
	}

	public inline function toString():String
	{
		return toArray().join(", ");
	}
}
