Shader "Custom/BlurShader"{ 

    SubShader {
        Tags { "RenderType"="Opaque" }

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
            float4 _MainTexture_TexelSize;
            uniform float _bias;
            uniform int _filterSize;

            v2f vert (appdata input) {
                v2f output;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.screenPos = (output.vertex.xy / output.vertex.w) * 0.5 + 0.5;
                return output;
            }

            fixed4 frag (v2f input) : SV_Target {
                 int maxSteps = _filterSize*2 + 1; float divisor = maxSteps * maxSteps;

                float2 uvMain;
                #if UNITY_UV_STARTS_AT_TOP
                uvMain = float2(input.screenPos.x, input.screenPos.y);
                #else
                uvMain = float2(input.screenPos.x, 1 - input.screenPos.y);
                #endif
                float2 uv = uvMain - _filterSize * _MainTexture_TexelSize.xy;
                float4 color = float4(0,0,0,0);
                for (int i = 0; i < maxSteps; i++) {
                    for (int j = 0; j < maxSteps; j++) {
                        float4 tmp = tex2D(_MainTexture, uv + float2(_MainTexture_TexelSize.x * j, _MainTexture_TexelSize.y * i));
                        tmp += _bias;  
                        color += tmp * tmp;
                    }
                }
                return fixed4(color.rgb / divisor, 1);
            }
            ENDCG
        }
    }
}
