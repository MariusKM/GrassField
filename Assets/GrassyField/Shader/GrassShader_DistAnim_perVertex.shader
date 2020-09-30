Shader "GrassyField/GrassShaderCutOffDistAnim_perVertex" {
	Properties{
				_MainTex("Albedo and alpha (RGBA)", 2D) = "white" {}
				 _Glossiness("Smoothness", Range(0,1)) = 0.5
				_Metallic("Metallic", Range(0,1)) = 0.0
				_Cutoff("Base Alpha cutoff", Range(0,.9)) = .5


				_WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
				 //_WindFrequency("Wind Frequency", Vector) = (0.05, 0.05,0)
				 _WindFrecuency("Wind Frecuency",Range(0.001,1)) = 1
				 _WindStrength("Wind Strength", Range(0, 2)) = 0.3
					 //_WindGustDistance("Distance between gusts",Range(0.001,50)) = .25
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

					 sampler2D _WindDistortionMap;
					 float _ScrollSpeed;
					 float4 _WindDistortionMap_ST;
					 float _WindFrecuency;
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
						 float2 offset = _WindDistortionMap_ST.zw + (_Time.y * _WindFrecuency);
						 float2 uv = worldSpaceVertex.zw * _WindDistortionMap_ST.xy + offset; //_WindDistortionMap_ST.zw* _WindFrecuency*_Time.y;

						 float3 windSample = (tex2Dlod(_WindDistortionMap, float4(uv.x,uv.y, 0, 0)).xyz);
						 // Height of the vertex in the range (0,1)
						 float height = (localSpaceVertex.y > 0.1) ? 1 : 0;

						 worldSpaceVertex.x += sin(_Time.x* windSample.x + worldSpaceVertex.x )*_WindDirection.x *_WindStrength * height;
						 worldSpaceVertex.z += sin(_Time.x*  windSample.x + worldSpaceVertex.z )*_WindDirection.z *_WindStrength * height;

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