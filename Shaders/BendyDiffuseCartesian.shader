// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Bendy diffuse - Cartesian" 
{
	Properties 
	{
	//	_CurveOrigin ("Curve origin", Vector) = (0, 0, 0)
	//	_CurvatureScale ("Curvature scale", Float) = 1
	//	_XCurvature ("X curvature", Range (-1, 1)) = 0
	//	_ZCurvature ("Z curvature", Range (-1, 1)) = 0
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		uniform float3 _CurveOrigin;
		uniform half _CurvatureScale;
		uniform fixed _XCurvature;
		uniform fixed _ZCurvature;
		uniform half _XFlatMargin;
		uniform half _ZFlatMargin;

		sampler2D _MainTex;
		fixed4 _Color;

		struct Input 
		{
			float2 uv_MainTex;
		};

		float4 Bend(float4 v)
		{
			float4 wpos = mul (unity_ObjectToWorld, v);
			
			float xDist = max(0, abs(wpos.x - _CurveOrigin.x) - _XFlatMargin);
			float zDist = max(0, abs(wpos.z - _CurveOrigin.z) - _ZFlatMargin);
			
			float zOff = xDist * xDist * _XCurvature + zDist * zDist * _ZCurvature;
			
			wpos.y += zOff * _CurvatureScale * 0.00001;
			wpos = mul (unity_WorldToObject, wpos);
			
			return wpos;
		}

		void vert (inout appdata_full v) 
		{
			float4 vpos = Bend(v.vertex);	
			
			v.vertex = vpos;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}

	Fallback "Legacy Shaders/VertexLit"
}
