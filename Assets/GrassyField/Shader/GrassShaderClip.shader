﻿Shader "GrassyField/GrassShaderClip" {
	Properties{
		 _MainTex("Albedo and alpha (RGBA)", 2D) = "white" {}
		  _Glossiness("Smoothness", Range(0,1)) = 0.5
		 _Metallic("Metallic", Range(0,1)) = 0.0
		
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200
			Cull Off
			CGPROGRAM
			  // Physically based Standard lighting model, and enable shadows on all light types

			  #pragma surface surf Standard vertex:vert addshadow

			  // Use shader model 3.0 target, to get nicer looking lighting
			  #pragma target 3.0



			struct Input {
				  float2 uv_MainTex;
			  };
			float _Amount;
			void vert(inout appdata_full v, out Input o) {
			  UNITY_INITIALIZE_OUTPUT(Input, o);
			 
		  }


			  half _Glossiness;
			  half _Metallic;

			  // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
					 // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
					 // #pragma instancing_options assumeuniformscaling
			  UNITY_INSTANCING_BUFFER_START(Props)
				  // put more per-instance properties here
			  UNITY_INSTANCING_BUFFER_END(Props)
			  sampler2D _MainTex;
			  void surf(Input IN, inout SurfaceOutputStandard o) {
				  // Albedo comes from a texture
				  fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
				  clip(c.a - 0.01);
				  o.Albedo = c.rgb;
				  // o.Alpha = c.a;
				   o.Metallic = _Metallic;
				   o.Smoothness = _Glossiness;
			   }
			   ENDCG
		  }
			  FallBack"Transparent/Cutout/Diffuse"
}

