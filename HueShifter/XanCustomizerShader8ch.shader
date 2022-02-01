Shader "Xan's Shaders/8 Channel Multi-Hue Shift"
{
	// Written by VRC user "Xan" >> Xan the Dragon // Eti the Spirit
	// Previously designed exclusively for use in the Aereis avatar, this shader is designed to leverage draw calls to the best of its ability
	// by merging as many color shift parameters into a single draw call as possible.
	// Based on a standard Unity surface shader.
	// Among these optimizations:
	//	- Array based lookup to color overrides for each individual key 
	//			(no if statements in sight, but if you are one of those people who thinks they are a sin without even checking the compiled bytecode, shame on you!)
	//	- Hilariously hacky micro optimizations littered about that are probably completely useless (but eggsan teh dargin, muh microseconds of compute time!!!)

	Properties
	{
		_MainTex("Main Diffuse Texture", 2D) = "black" {}
		_GlowAndMetalTex("Emission/Specular/Smoothness Map (R/G/B)", 2D) = "black" {}
		_ColorShiftTargetKey("Shift Key", 2D) = "black" {}

		// HSV space, not RGB
		// Edit: Decided to use Vector for this type as to not confuse them because color implies RGB.
		// In addition, gamma correction was causing problems (even without [Gamma]). This is just easier in general.
		// Black:		0
		// Just R:		1
		// Just G:		2
		// R + G (Y):	3
		// Just B:		4
		// R + B (M):	5
		// B + G (C):	6
		// White:		7
		_Ch0Color("Black Key Color (HSV)", Vector) = (1, 1, 1, -1)
		_Ch1Color("Red Key Color (HSV)", Vector) = (1, 1, 1, -1)
		_Ch2Color("Green Key Color (HSV)", Vector) = (1, 1, 1, -1)
		_Ch3Color("Yellow Key Color (HSV)", Vector) = (1, 1, 1, -1)
		_Ch4Color("Blue Key Color (HSV)", Vector) = (1, 1, 1, -1)
		_Ch5Color("Magenta Key Color (HSV)", Vector) = (1, 1, 1, -1)
		_Ch6Color("Cyan Key Color (HSV)", Vector) = (1, 1, 1, -1)
		_Ch7Color("White Key Color (HSV)", Vector) = (1, 1, 1, -1)
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf StandardSpecular fullforwardshadows
		#pragma target 3.0

		struct Input
		{
			float2 uv_ColorShiftTargetKey;
			float2 uv_GlowAndMetalTex;
			float2 uv_MainTex;
		};

		// A zero fixed3 value. Must be static and constant for the compiler to leverage this (and leverage it does)!
		static const fixed3 BLACK = fixed3(0, 0, 0);

		const sampler2D _MainTex;
		const sampler2D _GlowAndMetalTex;
		const sampler2D _ColorShiftTargetKey;

		const float3 _Ch0Color;
		const float3 _Ch1Color;
		const float3 _Ch2Color;
		const float3 _Ch3Color;
		const float3 _Ch4Color;
		const float3 _Ch5Color;
		const float3 _Ch6Color;
		const float3 _Ch7Color;

		fixed3 hsvToRgb(in float3 hsvIn)
		{
			const float hueSix = hsvIn.x * 6;
			const float r = abs(hueSix - 3) - 1;
			const float g = 2 - abs(hueSix - 2);
			const float b = 2 - abs(hueSix - 4);
			const float3 rgb = saturate(float3(r, g, b));
			return ((rgb - 1) * hsvIn.y + 1) * hsvIn.z;
		}

		uint float0Or1ToUInt(in float f)
		{
			return asuint(f) >> 29u; // OMEGALUL
			// This abuses the fact that I 100% know that the value will either be 0f or 1f
			// If its 1, the floating point value 0x3f800000 is used, so I shift over by 29 which cuts off all but bit 0, resulting in 1.
			// Theres more reason to this optimization, see below where I call this method. 
			// In and of itself it makes little sense but given how it's used, its leveraged by the compiler in full
		}

		void surf(in Input IN, inout SurfaceOutputStandardSpecular o)
		{

			const fixed3 keyTex = tex2D(_ColorShiftTargetKey, IN.uv_ColorShiftTargetKey);
			const fixed3 mainTex = tex2D(_MainTex, IN.uv_MainTex);
			const fixed3 glowAndSuch = tex2D(_GlowAndMetalTex, IN.uv_GlowAndMetalTex);
			const uint r = float0Or1ToUInt(keyTex.x);
			const uint g = float0Or1ToUInt(keyTex.y) << 1;
			const uint b = float0Or1ToUInt(keyTex.z) << 2;
			const uint outputKey = r + g + b;
			const fixed3 outputs[8] = {
				_Ch0Color,
				_Ch1Color,
				_Ch2Color,
				_Ch3Color,
				_Ch4Color,
				_Ch5Color,
				_Ch6Color,
				_Ch7Color
			};
			const fixed3 targetColor = hsvToRgb(outputs[outputKey]);
			o.Albedo = mainTex * targetColor;
			o.Specular = glowAndSuch.y * targetColor;
			o.Smoothness = glowAndSuch.z * targetColor;
			o.Emission = glowAndSuch.x * targetColor;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
