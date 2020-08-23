Shader "GrassyField/GrassShader" {
    Properties{
        _MainTex("Albedo and alpha (RGBA)", 2D) = "white" {}
         _Glossiness("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.0
        _Cutoff("Base Alpha cutoff", Range(0,.9)) = .5
    }
        SubShader{
            Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
            LOD 200
            Cull Off
            CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types

        #pragma surface surf Standard alphatest:_Cutoff addshadows//fullforwardshadows
       // #pragma surface surf Lambert alphatest:_Cutoff

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };
        half _Glossiness;
        half _Metallic;

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
}
