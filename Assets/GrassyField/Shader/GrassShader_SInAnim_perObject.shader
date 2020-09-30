﻿Shader "GrassyField/GrassShaderSinAnim_perObject" {
	Properties{
		_MainTex("Albedo and alpha (RGBA)", 2D) = "white" {}
		 _Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Cutoff("Base Alpha cutoff", Range(0,.9)) = .5


		_WindFrecuency("Wind Frecuency",Range(0.001,100)) = 1
		_WindStrength("Wind Strength", Range(0, 2)) = 0.3
		_WindGustDistance("Distance between gusts",Range(0.001,50)) = .25
		_WindDirection("Wind Direction", vector) = (1,0, 1,0)
	}
		SubShader{
			Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
			LOD 200
			Cull Off
			CGPROGRAM
			 // Physically based Standard lighting model, and enable shadows on all light types

			 #pragma surface surf Standard vertex:vert alphatest:_Cutoff addshadow
			// #pragma surface surf Lambert alphatest:_Cutoff

			 // Use shader model 3.0 target, to get nicer looking lighting
			 #pragma target 3.0

			 sampler2D _MainTex;

			 struct Input {
				 float2 uv_MainTex;
			 };
			 half _WindFrecuency;
			 half _WindGustDistance;
			 half _WindStrength;
			 float3 _WindDirection;

			 // our vert modification function
			 void vert(inout appdata_full v)
			 {
				 float4 localSpaceVertex = v.vertex;
				 // Takes the mesh's verts and turns it into a point in world space
				 // this is the equivalent of Transform.TransformPoint on the scripting side
				 float4 worldSpaceVertex = mul(unity_ObjectToWorld, localSpaceVertex);
				 float4 midPoint = float4(0, -0.5, 0, 1); // w = 1.0, https://forum.unity.com/threads/a-vertex-position-is-a-float4-what-does-the-4th-component-represent.152809/
				 float4 midPointWRLD = mul(unity_ObjectToWorld, midPoint);
				 // Height of the vertex in the range (0,1)
				
			
				 float height = (localSpaceVertex.y > 0.1) ? 1 : 0;

				 worldSpaceVertex.x += sin(_Time.x * _WindFrecuency + midPointWRLD.x * _WindGustDistance) * height * _WindStrength * _WindDirection.x;
				 worldSpaceVertex.z += sin(_Time.x * _WindFrecuency + midPointWRLD.z * _WindGustDistance) * height * _WindStrength * _WindDirection.z;

				// worldSpaceVertex.x += sin(_Time.x * _WindFrecuency + worldSpaceVertex.x * _WindGustDistance) * height * _WindStrength * _WindDirection.x;
				// worldSpaceVertex.z += sin(_Time.x * _WindFrecuency + worldSpaceVertex.z * _WindGustDistance) * height * _WindStrength * _WindDirection.z;
	

				 // takes the new modified position of the vert in world space and then puts it back in local space
				 v.vertex = mul(unity_WorldToObject, worldSpaceVertex);

			 }


			 half _Glossiness;
			 half _Metallic;

			 // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
						 // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
						 // #pragma instancing_options assumeuniformscaling
			 UNITY_INSTANCING_BUFFER_START(Props)
				 // put more per-instance properties here
			 UNITY_INSTANCING_BUFFER_END(Props)


			 void surf(Input IN, inout SurfaceOutputStandard o) {
				 // Albedo comes from a texture
				 fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
				 o.Albedo = c.rgb;
				 o.Alpha = c.a;
				 o.Metallic = _Metallic;
				 o.Smoothness = _Glossiness;
			 }
			 ENDCG
		 }
			 FallBack"Transparent/Cutout/Diffuse"
}
