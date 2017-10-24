Shader "Hidden/DepthEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "classicnoise4D.cg"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			sampler2D _CameraDepthNormalsTexture;
			float4x4 _inverseView;

			float fbm(float4 pos, int octave){
				float value = 0;
				float amplitude = .5;

				for(int i = 0; i < octave; i++){
					value += amplitude * cnoise(pos);
					pos *= 2;
					amplitude *= .5;
				}
				return value;
			}

			float fbmRidge(float4 pos, int octave){
				float value = 0;
				float amplitude = .5;

				for(int i = 0; i < octave; i++){
					value += amplitude * abs(cnoise(pos));
					pos *= 2;
					amplitude *= .5;
				}
				return value;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(1,1,1,1);

				float depth = 0;
				float3 normal = float3(0,0,0);

				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
				depth = lerp(0, _ProjectionParams.z, depth);

				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
				float3 wPos = float3((i.uv * 2 - 1) / p11_22, -1) * depth;
				wPos = mul(_inverseView, float4(wPos, 1)).xyz;
				normal = mul(_inverseView, float4(normal, 0)).xyz;


				float2 coordXZ = wPos.xz * 2;
				float2 gridXZ = abs(frac(coordXZ - 0.5) - 0.5) / fwidth(coordXZ);
				float linerXZ = min(gridXZ.x, gridXZ.y);


				float4 gridColorXZ = float4(1.0 - min(linerXZ, 1.0),
							 1.0 - min(linerXZ, 1.0),
							 1.0 - min(linerXZ, 1.0),
							 1.0);

				float2 coordXY = wPos.xy * 2;
				float2 gridXY = abs(frac(coordXY - 0.5) - 0.5) / fwidth(coordXY);
				float linerXY = min(gridXY.x, gridXY.y);

				float4 gridColorXY = float4(1.0 - min(linerXY, 1.0),
							 1.0 - min(linerXY, 1.0),
							 1.0 - min(linerXY, 1.0),
							 1.0);

				float2 coordYZ = wPos.yz * 2;
				float2 gridYZ = abs(frac(coordYZ - 0.5) - 0.5) / fwidth(coordYZ);
				float linerYZ = min(gridYZ.x, gridYZ.y);

				float4 gridColorYZ = float4(1.0 - min(linerYZ, 1.0),
							 1.0 - min(linerYZ, 1.0),
							 1.0 - min(linerYZ, 1.0),
							 1.0);

				col = lerp(gridColorXY, gridColorXZ, step(abs(normal.z), abs(normal.y)));
				col = lerp(col, gridColorYZ, step(abs(normal.y), abs(normal.x)));
				col *= 3;


				float3 pos = wPos * 0.25;
				pos = floor(pos * 32) / 32;
				float n = abs(fbmRidge(float4(pos, _Time.x * 2.5), 6));
				n = 0.8 - n;
				n = pow(n,8);
				n = smoothstep(0, 0.1, n);
				// col *= n;

				col *= float4(normal, 1.0);//DEBUG Normal
				col = lerp(tex2D(_MainTex, i.uv), col, n);

				//DEBUG

				// col *= frac(depth);//DEBUG WPOS
				// col *= float4(frac(wPos + float3(0, 0.3, 0.0)), 1.0);//DEBUG WPOS


				return col;
			}
			ENDCG
		}
	}
}
