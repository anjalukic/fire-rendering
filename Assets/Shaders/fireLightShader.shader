Shader "Custom/FireLightShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" { }
        _PerlinNoiseTex("Perlin Noise Texture", 2D) = "white" { }
        _ambient("Ambient", Range(0.0, 1.0)) = 0.2
        _diffuse("Diffuse", Range(0.0, 1.0)) = 1.0
        _specular("Specular", Range(0.0, 1.0)) = 0.2
        _specularPower("Specular power", Int) = 10
        _lightPos("Light position", Vector) = (0,0,0,0)
        _lightStrength("Light Strength", Range(0.0, 5.0)) = 1.0
        _lightFlickeringStrength("Light Flickering Strength", Range(0.0, 0.3)) = 0.3
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            sampler2D _PerlinNoiseTex;
            float _diffuse, _specular, _ambient;
            int _specularPower;
            float4 _lightPos;
            float _lightStrength, _lightFlickeringStrength;
            

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD0;
            };

            struct v2f
            {
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
                float2 texCoord : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float distance : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.lightDir = normalize(_lightPos.xyz - worldPos);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
                o.texCoord = v.texCoord;

                o.distance = length(_lightPos.xyz - worldPos);

                return o;

            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 materialColor = tex2D(_MainTex, i.texCoord);
                // ambient color
                float3 ambient = materialColor * _ambient;
                // diffuse color
                float3 normal = normalize(i.normal);
                float3 lightDir = normalize(i.lightDir);
                float3 diffuse = materialColor * max(0,dot(normal, lightDir)) * _diffuse;
                // specular color
                float3 reflection = reflect(-lightDir, normal);
                float3 specular = pow(max(0,dot(normalize(i.viewDir), reflection)), _specularPower) * _specular;

                float attenuation = 10 * _lightStrength * 1.0 / (i.distance * i.distance) ;

                ambient *= attenuation;
                diffuse *= attenuation;
                specular *= attenuation;

                float lightFlicker = tex2D(_PerlinNoiseTex, float2(_Time.y, _Time.z/10)) * _lightFlickeringStrength;

                fixed4 color = fixed4((ambient + diffuse + specular), 1.0) * lightFlicker;

                return color;
            }
            ENDCG
        }
    }
}
