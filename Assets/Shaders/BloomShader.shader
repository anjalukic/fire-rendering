Shader "Custom/BloomShader"
{
    SubShader{
        Tags { "RenderType" = "Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 screenPos : TEXCOORD0;
            };

            sampler2D _MainTexture;
            sampler2D _BlurTexture;

            v2f vert(appdata input) {
                v2f output;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.screenPos = (output.vertex.xy / output.vertex.w) * 0.5 + 0.5;


                return output;
            }

            fixed4 frag(v2f input) : SV_Target{
                float2 uvMain;
                #if UNITY_UV_STARTS_AT_TOP
                uvMain = float2(input.screenPos.x, input.screenPos.y);
                #else
                uvMain = float2(input.screenPos.x, 1 - input.screenPos.y);
                #endif
                float2 uvBlur = float2(input.screenPos.x, 1 - input.screenPos.y);

                fixed4 mainColor = tex2D(_MainTexture, uvMain);
                fixed4 bloomColor = tex2D(_BlurTexture, uvBlur);
                float factor = dot(fixed3(0.2126, 0.7152, 0.0722), bloomColor.rgb);
                return lerp(mainColor, bloomColor, factor);
            }
            ENDCG
        }
    }
}
