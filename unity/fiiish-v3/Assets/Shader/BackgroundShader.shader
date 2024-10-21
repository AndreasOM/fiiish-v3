Shader "Unlit/BackgroundShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientTex ("GradientTexture", 2D) = "white" {}
        _Phase ("Phase", Float ) = 0.5
        _Offset ("Offset", Float ) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _GradientTex;
            float4 _MainTex_ST;
            float _Phase;
            float _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv+fixed2( _Offset, 0.0) );
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // col = fixed4( 1.0f, 1.0f, 1.0f, 1.0f );
                fixed4 finalCol = tex2D(_GradientTex, fixed2( col.r, 1.0-_Phase ) );
                //fixed4 finalCol = tex2D(_GradientTex, i.uv);
                return finalCol;
            }
            ENDCG
        }
    }
}
