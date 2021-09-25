
Shader "Custom/FireEffectShader"
{
	Properties
	{
		[Header(Textures)]
		_FireTex("Fire Texture", 2D) = "white"
		_NoiseTex("Noise Texture", 2D) = "white" { }
		_AlphaTex("Alpha Texture", 2D) = "white" { }
		_HeatAlphaTex("Heat Alpha Texture", 2D) = "white" { }
		_HeatNoiseTex("Heat Noise Texture", 2D) = "white" { }
		[Header(Fire)]
		_scrollSpeed("Scroll speed", Vector) = (1.3, 2.1, 2.3)
		_scale("Texture scales", Vector) = (1.0,2.0,3.0)
		_distortion1("Distortion 1", Vector) = (0.1,0.2,0,0)
		_distortion2("Distortion 2", Vector) = (0.1,0.3,0,0)
		_distortion3("Distortion 3", Vector) = (0.1,0.1,0,0)
		_distortionScale("Distortion scale", Float) = 0.4
		_distortionBias("Distortion bias", Float) = 0.1
		_Transparency("Transparency", Float) = 0.5
		[Header(Heat)]
		_heatScrollSpeed("Scroll speed", Vector) = (2.0, 2.0, 0.0)
		_heatStrength("Strength", Float) = 0.5
		[Header(Rendering)]
		[Enum(OFF, 0, ON, 1)] _Billboard("Toggle Billboard", int) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
			// Grab the screen behind the object into _BackgroundTexture
			GrabPass { "_BackgroundTex" }
			LOD 100
			Pass
			{
				Blend SrcAlpha OneMinusSrcAlpha
				ZWrite Off
				Cull Off
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertexPos: POSITION;
					float2 texCoords: TEXCOORD0;
				};

				struct v2f
				{
					float4 fragPos: SV_POSITION;
					float2 tex : TEXCOORD0;
					float2 texCoords1 : TEXCOORD1;
					float2 texCoords2 : TEXCOORD2;
					float2 texCoords3 : TEXCOORD3;
					float2 heatCoords : TEXCOORD4;
					float2 backgroundCoords : TEXCOORD5;
				};

				uniform sampler2D _FireTex; 
				uniform sampler2D _NoiseTex; 
				uniform sampler2D _AlphaTex; 
				sampler2D _BackgroundTex;
				uniform sampler2D _HeatAlphaTex;
				uniform sampler2D _HeatNoiseTex;
				uniform float3 _scrollSpeed;
				uniform float3 _scale;
				uniform float2 _distortion1;
				uniform float2 _distortion2;
				uniform float2 _distortion3;
				uniform float _distortionScale;
				uniform float _distortionBias;
				uniform float _Transparency;
				uniform int _Billboard;
				uniform float2 _heatScrollSpeed;
				uniform float _heatStrength;

				v2f vert(appdata input)
				{
					v2f output;

					float4 pos = mul(UNITY_MATRIX_P, float4(UnityObjectToViewPos(float4(0, 0, 0, 1)),1) + float4(input.vertexPos.x, input.vertexPos.y, input.vertexPos.z, 0));
					output.fragPos = lerp(UnityObjectToClipPos(input.vertexPos), pos, _Billboard);

					output.tex = input.texCoords;

					// Compute texture coordinates for first noise texture using the first scale and upward scrolling speed values.
					output.texCoords1 = (input.texCoords * _scale.x);
					output.texCoords1.y -= (_Time.x * _scrollSpeed.x);

					// Compute texture coordinates for second noise texture using the second scale and upward scrolling speed values.
					output.texCoords2 = (input.texCoords * _scale.y);
					output.texCoords2.y -= (_Time.x * _scrollSpeed.y);

					// Compute texture coordinates for third noise texture using the third scale and upward scrolling speed values.
					output.texCoords3 = (input.texCoords * _scale.z);
					output.texCoords3.y -= (_Time.x * _scrollSpeed.z);

					output.backgroundCoords = (output.fragPos.xy / output.fragPos.w) * 0.5 + 0.5;
					output.backgroundCoords.y = 1 - output.backgroundCoords.y;

					// Compute texture coordinates for the heat noise texture
					output.heatCoords = output.backgroundCoords;
					output.heatCoords.x -= (_Time.x * _heatScrollSpeed.x);
					output.heatCoords.y -= (_Time.x * _heatScrollSpeed.y);

					return output;
				 }

				fixed4 frag(v2f input) : SV_Target
				{
					// Sample the heat noise texture and get the background color
					float4 heatNoise = tex2D(_HeatNoiseTex, input.heatCoords);
					float heatStrength = tex2D(_HeatAlphaTex, input.tex).r;
					float4 backgroundColor = tex2D(_BackgroundTex, input.backgroundCoords - heatNoise.xy * heatStrength * saturate(_heatStrength) * 0.03);


					// Sample the same noise texture using the three different texture coordinates to get three different noise scales.
					float4 noise1 = tex2D(_NoiseTex, input.texCoords1);
					float4 noise2 = tex2D(_NoiseTex, input.texCoords2);
					float4 noise3 = tex2D(_NoiseTex, input.texCoords3);

					//// Move the noise from the (0, 1) range to the (-1, +1) range.
					//noise1 = (noise1 - 0.5f) * 2.0f;
					//noise2 = (noise2 - 0.5f) * 2.0f;
					//noise3 = (noise3 - 0.5f) * 2.0f;

					// Distort the three noise x and y coordinates by the three different distortion x and y values.
					noise1.xy = noise1.xy * _distortion1.xy;
					noise2.xy = noise2.xy * _distortion2.xy;
					noise3.xy = noise3.xy * _distortion3.xy;

					// Combine all three distorted noise results into a single noise result.
					float4 finalNoise = noise1 + noise2 + noise3;

					// Perturb the input texture Y coordinates by the distortion scale and bias values.
					// The perturbation gets stronger as you move up the texture which creates the flame flickering at the top effect.
					float perturb = ((input.tex.y) * _distortionScale) + _distortionBias;

					// Now create the perturbed and distorted texture sampling coordinates that will be used to sample the fire color texture.
					float2 fireCoords = (finalNoise.xy * perturb) + input.tex.xy;

					// Sample the color from the fire texture using the perturbed and distorted texture sampling coordinates.
					// Use the clamping sample state instead of the wrap sample state to prevent flames wrapping around.
					float4 fireColor = tex2D(_FireTex, fireCoords.xy);

					// Sample the alpha value from the alpha texture using the perturbed and distorted texture sampling coordinates.
					// This will be used for transparency of the fire.
					// Use the clamping sample state instead of the wrap sample state to prevent flames wrapping around.
					float alphaColor = tex2D(_AlphaTex, fireCoords.xy).r;

					// Set the alpha blending of the fire to the perturbed and distored alpha texture value.
					// fireColor.a = alphaColor * saturate(_Transparency);
					fireColor.a = 1;
					float alpha = alphaColor * saturate(_Transparency);

					// Calculate the final color
					float4 color = fireColor * alpha + backgroundColor * (1 - alpha);

					return color;
				 }
				 ENDCG

			 }

		}
			Fallback "Diffuse"
}