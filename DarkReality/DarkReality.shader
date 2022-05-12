Shader "Xan's Shaders/Dark Reality"
{
	Properties
	{
		_CLR_Shard("Color", Color) = (1, 1, 1, 1)
		_RefractionFactor("Refraction", Range(0, 1)) = 0.001
		_ColorDivisor("Color Divisor", Range(0.125, 16)) = 4
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent+2000" }
		LOD 200 // Bump this up to 200 from 100, it's unlit but some variants need a few extra ops in the compiled code.
		// Additionally, this uses a grab pass, which is not very ideal.
		// n.b. this value is an arbitrary measure of how "complex" the shader is to render, it is used by the engine. Good to set!
		ZWrite On
		Cull Off

		GrabPass {} // I don't like that I have to do this but I do, as far as I am aware, anything else would not achieve the same effect.
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				UNITY_FOG_COORDS(0)
				float4 vertex : SV_POSITION;
				float4 screenUV : TEXCOORD1;
			};

			sampler2D _GrabTexture;
			half4 _CLR_Shard;
			float _RefractionFactor, _ColorDivisor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenUV = ComputeGrabScreenPos(o.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 grabNoRef = tex2Dproj(_GrabTexture, i.screenUV);
				float ref = _RefractionFactor;
				ref += _Time.w % 0.1 / 64;
				fixed4 grabA = tex2Dproj(_GrabTexture, i.screenUV + float4(ref, ref, 0, 0));
				fixed4 grabB = tex2Dproj(_GrabTexture, i.screenUV - float4(ref, ref, 0, 0));
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				//return col;
				//return frac(i.screenUV * 16.0);
				fixed4 grabAltD = grabNoRef * (grabA / grabB) / _ColorDivisor;
				return grabAltD * _CLR_Shard;
			}
			ENDCG
		}
	}
}
