Shader "GrassyField/GrassShaderTesting_perObject" {
	Properties{
			_MainTex("Albedo and alpha (RGBA)", 2D) = "white" {}
			 _Glossiness("Smoothness", Range(0,1)) = 0.5
			_Metallic("Metallic", Range(0,1)) = 0.0
			_Cutoff("Base Alpha cutoff", Range(0,.9)) = .5


			_WindDistortionMap("Wind Distortion Map", 2D) = "white" {}

			_WindFrecuency("Wind Frecuency",Range(0.001,10)) = 1
			_WindStrength("Wind Strength", Range(0, 2)) = 0.3

			_WindDirection("Wind Direction", vector) = (1,0, 1,0)
			_BoundsSize("Bounds Size", vector) = (0,0,0,0)
			_BottomLeft("Bottom Left", vector) = (0,0,0,0)
			_ObjectPos("Object Pos", vector) = (0,0,0,0)
			_RotAxis("Rot Axis", vector) = (0,0,0,0)
			_DebugNoise("Debug Noise",Range(0,1)) = 1
	}
		SubShader{
			Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
			LOD 200
			Cull Off
			CGPROGRAM
				// Physically based Standard lighting model, and enable shadows on all light types

				#pragma surface surf Standard vertex:vert alphatest:_Cutoff addshadow
				#include "Assets/GrassyField/Shader/quaternionMath.cginc"
			   // #pragma surface surf Lambert alphatest:_Cutoff

				// Use shader model 3.0 target, to get nicer looking lighting
				#pragma target 3.0

				sampler2D _MainTex;

				struct Input {
					float2 uv_MainTex;
					// float3 worldNormal;
					 float3 worldPos;

				 };


				 sampler2D _WindDistortionMap;
				 float _ScrollSpeed;
				 float _DebugNoise;
				 float4 _WindDistortionMap_ST;
				 float _WindFrecuency;
				 half _WindGustDistance;
				 half _WindStrength;
				 float3 _WindDirection;
				 float2 _BoundsSize;
				 float3 _ObjectPos;
				 float3 _RotAxis;
				 float2 _BottomLeft;

				
				 void vert(inout appdata_full v)
				 {
					 float4 localSpaceVertex = v.vertex;
					 float4 midPoint = float4(0, -0.5, 0, 1); // w = 1.0, https://forum.unity.com/threads/a-vertex-position-is-a-float4-what-does-the-4th-component-represent.152809/
					 float4 midPointWRLD = mul(unity_ObjectToWorld, midPoint);
				
					 float4 worldSpaceVertex = mul(unity_ObjectToWorld, localSpaceVertex);
					 float2 worldSpaceNorm = midPointWRLD.xz;
					 worldSpaceNorm.x -= _BottomLeft.x;
					 worldSpaceNorm.x /= _BoundsSize.x;

					 worldSpaceNorm.x = 1 - (worldSpaceNorm.x * 1);
					 worldSpaceNorm.y -= _BottomLeft.y;
					 worldSpaceNorm.y /= _BoundsSize.y;

					 worldSpaceNorm.y = 1 - (worldSpaceNorm.y * 1);
					 float2 offset = _WindDistortionMap_ST.zw;
					 float2 uv = worldSpaceNorm * _WindDistortionMap_ST.xy + offset; ;


					 float3 windSample = (tex2Dlod(_WindDistortionMap, float4(uv.x,uv.y, 0, 0)).xyz);
					
					 float height = (localSpaceVertex.y > 0.1) ? 1 : 0;

				
					


				

			 // Direction of camera relative to object space.
			 // Good for reference: https://gist.github.com/unitycoder/c5847a82343a8e721035
					 //float3 (v.normal.x,UNITY_MATRIX_IT_MV[2].y, UNITY_MATRIX_IT_MV[2].z);
			
					 worldSpaceVertex.x += (_WindStrength * windSample.y * _WindDirection.x) * height;
					 worldSpaceVertex.z += (_WindStrength * windSample.z * _WindDirection.z) * height;
					 //worldSpaceVertex.y -= windSample.x;
					 float3 viewDir = midPointWRLD - _ObjectPos;
					 viewDir.y = 0;
					 viewDir = normalize(viewDir);
					 //viewDir = float3 (0.1, 2,0.1) - viewDir;
					 viewDir *= windSample.x;
					 localSpaceVertex = mul(unity_WorldToObject, worldSpaceVertex);
					 viewDir = mul(unity_WorldToObject, viewDir);
			
					 // Use quaternion to perform rotation toward view direction relative to mid-point. 
					 float4 quaternion = rotationTo(viewDir, _RotAxis);//float3(0,-1,0)); // normal = forward, in this case.
					 float3 offsetPoint = localSpaceVertex - midPoint; // Offset so we can rotate relative to this point.
					 float3 rotatedPoint = rotateVector(quaternion, offsetPoint) + midPoint; // Rotate and return back to offset.
					
			
					 // Setup regular coordinates based on rotated point.
					// o.vertex = UnityObjectToClipPos(rotatedPoint);

					 // takes the new modified position of the vert in world space and then puts it back in local space
					// v.vertex = mul(unity_WorldToObject, worldSpaceVertex);
					// v.vertex = (windSample.x > 0) ? float4(rotatedPoint,1): mul(unity_WorldToObject, worldSpaceVertex);// mul(unity_WorldToObject, worldSpaceVertex);
					 v.vertex = float4(rotatedPoint, 1);// mul(unity_WorldToObject, worldSpaceVertex);
					 //v.vertex = float4(rotatedPoint,1);

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
					 float2 worldPos = IN.worldPos.xz;
					 worldPos.x -= _BottomLeft.x;
					 worldPos.x = worldPos.x / _BoundsSize.x;
					 worldPos.x = 1 - (worldPos.x * 1);
					 worldPos.y -= _BottomLeft.y;
					 worldPos.y = worldPos.y / _BoundsSize.y;
					 worldPos.y = 1 - (worldPos.y * 1);
					 fixed4 cN = tex2D(_WindDistortionMap, worldPos);
					 fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
					 o.Albedo = (c.rgb*(1-_DebugNoise)) +(cN.rgb*_DebugNoise);
					 o.Alpha = c.a;
					 o.Metallic = _Metallic;
					 o.Smoothness = _Glossiness;

				 }
				 ENDCG
			}
				FallBack"Transparent/Cutout/Diffuse"
}