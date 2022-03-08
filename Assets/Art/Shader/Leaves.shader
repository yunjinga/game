// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Leaves"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_SecondColor("Second Color", Color) = (1,1,1,0)
		_TilingOffset("Tiling Offset", Vector) = (1,1,0,0)
		_Shadow("Shadow", Range( 0 , 1)) = 0
		_WindNoise("Wind Noise", Float) = 1.96
		_WindStrength("Wind Strength", Float) = 1
		_WindSpeed("Wind Speed", Float) = 0
		_Clip("Clip", Range( 0 , 1)) = 0

	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
	LOD 100

		Cull Off
		CGINCLUDE
		#pragma target 3.0 
		ENDCG
		
		
		Pass
		{
			
			Name "ForwardBase"
			Tags { "LightMode"="ForwardBase" "Queue"="Geometry" "RenderType"="Opaque" }

			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend Off
			AlphaToMask Off
			Cull Off
			ColorMask RGBA
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#ifndef UNITY_PASS_FORWARDBASE
			#define UNITY_PASS_FORWARDBASE
			#endif
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#define ASE_SHADOWS 1

			uniform float _WindSpeed;
			uniform float _WindNoise;
			uniform float _WindStrength;
			uniform float4 _SecondColor;
			uniform sampler2D _Texture;
			uniform float4 _TilingOffset;
			uniform float _Shadow;
			uniform float _Clip;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_SHADOW_COORDS(2)
				float4 ase_texcoord3 : TEXCOORD3;
			};
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float3 _Vector0 = float3(0,0,0);
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float2 appendResult6 = (float2(ase_worldPos.x , ase_worldPos.y));
				float mulTime22 = _Time.y * _WindSpeed;
				float2 temp_cast_0 = (mulTime22).xx;
				float2 texCoord24 = v.ase_texcoord.xy * appendResult6 + temp_cast_0;
				float simplePerlin2D31 = snoise( texCoord24*_WindNoise );
				simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
				float temp_output_34_0 = ( (-1.0 + (simplePerlin2D31 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * _WindStrength * v.ase_texcoord.y );
				float3 appendResult48 = (float3(( _Vector0.x + temp_output_34_0 ) , ( _Vector0.y + temp_output_34_0 ) , _Vector0.z));
				
				o.ase_texcoord3.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord3.w = 0;
				
				v.vertex.xyz += appendResult48;
				o.pos = UnityObjectToClipPos(v.vertex);
				#if ASE_SHADOWS
					#if UNITY_VERSION >= 560
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
					#else
						TRANSFER_SHADOW( o );
					#endif
				#endif
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float2 appendResult13 = (float2(_TilingOffset.x , _TilingOffset.y));
				float2 appendResult10 = (float2(_TilingOffset.z , _TilingOffset.w));
				float2 texCoord21 = i.ase_texcoord1.xy * appendResult13 + appendResult10;
				float4 tex2DNode25 = tex2D( _Texture, texCoord21 );
				float3 ase_worldPos = i.ase_texcoord3.xyz;
				UNITY_LIGHT_ATTENUATION(ase_atten, i, ase_worldPos)
				float clampResult26 = clamp( ( ase_atten + _Shadow ) , 0.0 , 1.0 );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				clip( tex2DNode25.a - _Clip);
				
				
				outColor = ( _SecondColor * tex2DNode25 * float4( ( clampResult26 * ase_lightColor.rgb ) , 0.0 ) ).rgb;
				outAlpha = 1;
				clip(outAlpha);
				return float4(outColor,outAlpha);
			}
			ENDCG
		}
		
		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }
			ZWrite On
			ZTest LEqual
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#ifndef UNITY_PASS_SHADOWCASTER
			#define UNITY_PASS_SHADOWCASTER
			#endif
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#define ASE_SHADOWS 1

			uniform float _WindSpeed;
			uniform float _WindNoise;
			uniform float _WindStrength;
			uniform float4 _SecondColor;
			uniform sampler2D _Texture;
			uniform float4 _TilingOffset;
			uniform float _Shadow;
			uniform float _Clip;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				V2F_SHADOW_CASTER;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_SHADOW_COORDS(2)
				float4 ase_texcoord3 : TEXCOORD3;
			};

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float3 _Vector0 = float3(0,0,0);
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float2 appendResult6 = (float2(ase_worldPos.x , ase_worldPos.y));
				float mulTime22 = _Time.y * _WindSpeed;
				float2 temp_cast_0 = (mulTime22).xx;
				float2 texCoord24 = v.ase_texcoord.xy * appendResult6 + temp_cast_0;
				float simplePerlin2D31 = snoise( texCoord24*_WindNoise );
				simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
				float temp_output_34_0 = ( (-1.0 + (simplePerlin2D31 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * _WindStrength * v.ase_texcoord.y );
				float3 appendResult48 = (float3(( _Vector0.x + temp_output_34_0 ) , ( _Vector0.y + temp_output_34_0 ) , _Vector0.z));
				
				o.ase_texcoord3.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord3.w = 0;
				
				v.vertex.xyz += appendResult48;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float2 appendResult13 = (float2(_TilingOffset.x , _TilingOffset.y));
				float2 appendResult10 = (float2(_TilingOffset.z , _TilingOffset.w));
				float2 texCoord21 = i.ase_texcoord1.xy * appendResult13 + appendResult10;
				float4 tex2DNode25 = tex2D( _Texture, texCoord21 );
				float3 ase_worldPos = i.ase_texcoord3.xyz;
				UNITY_LIGHT_ATTENUATION(ase_atten, i, ase_worldPos)
				float clampResult26 = clamp( ( ase_atten + _Shadow ) , 0.0 , 1.0 );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				clip( tex2DNode25.a - _Clip);
				
				
				outColor = ( _SecondColor * tex2DNode25 * float4( ( clampResult26 * ase_lightColor.rgb ) , 0.0 ) ).rgb;
				outAlpha = 1;
				clip(outAlpha);
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
		
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
3046;149;1714;1147;2401.027;499.0017;1.3;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;4;-1711.297,526.4873;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;16;-1805.03,702.1422;Inherit;False;Property;_WindSpeed;Wind Speed;6;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;22;-1597.89,698.9041;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;-1516.41,552.9251;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1771.798,162.0051;Inherit;False;Property;_Shadow;Shadow;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;11;-1698.092,43.02705;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1324.479,741.7207;Inherit;False;Property;_WindNoise;Wind Noise;4;0;Create;True;0;0;0;False;0;False;1.96;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;7;-2014.427,-331.621;Inherit;False;Property;_TilingOffset;Tiling Offset;2;0;Create;True;0;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-1295.087,498.3581;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;31;-1086.267,547.7693;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-1451.849,74.46382;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-1761.479,-294.7014;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-1766.323,-201.0645;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LightColorNode;51;-1296.428,190.1028;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.TexCoordVertexDataNode;32;-894.2953,927.1841;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1579.646,-312.2478;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;26;-1323.823,78.06343;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;41;-829.1976,564.4852;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-904.2024,776.9431;Inherit;False;Property;_WindStrength;Wind Strength;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-573.8195,539.7496;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-858.5293,-550.6126;Inherit;False;Property;_SecondColor;Second Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-1134.531,89.72647;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;46;-535.7375,316.8165;Inherit;False;Constant;_Vector0;Vector 0;8;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;25;-1333.898,-560.3367;Inherit;True;Property;_Texture;Texture;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-297.9846,434.653;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-830.0609,220.3169;Inherit;False;Property;_Clip;Clip;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-618.93,-269.3272;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-293.4689,335.3086;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-146.7099,326.2772;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClipNode;33;-449.3976,174.7293;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;100;8;Leaves;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardBase;0;0;ForwardBase;3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;LightMode=ForwardBase;Queue=Geometry=Queue=0;RenderType=Opaque=RenderType;True;2;False;0;;0;0;Standard;0;0;4;True;False;False;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,110;Float;False;False;-1;2;ASEMaterialInspector;100;8;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardAdd;0;1;ForwardAdd;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;1;LightMode=ForwardAdd;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;ASEMaterialInspector;100;1;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ShadowCaster;0;3;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;22.23777,153.2035;Float;False;False;-1;2;ASEMaterialInspector;100;8;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;Deferred;0;2;Deferred;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;LightMode=ShadowCaster;RenderType=Opaque=RenderType;True;2;False;0;;0;0;Standard;0;False;0
WireConnection;22;0;16;0
WireConnection;6;0;4;1
WireConnection;6;1;4;2
WireConnection;24;0;6;0
WireConnection;24;1;22;0
WireConnection;31;0;24;0
WireConnection;31;1;23;0
WireConnection;20;0;11;0
WireConnection;20;1;14;0
WireConnection;13;0;7;1
WireConnection;13;1;7;2
WireConnection;10;0;7;3
WireConnection;10;1;7;4
WireConnection;21;0;13;0
WireConnection;21;1;10;0
WireConnection;26;0;20;0
WireConnection;41;0;31;0
WireConnection;34;0;41;0
WireConnection;34;1;30;0
WireConnection;34;2;32;2
WireConnection;50;0;26;0
WireConnection;50;1;51;1
WireConnection;25;1;21;0
WireConnection;49;0;46;2
WireConnection;49;1;34;0
WireConnection;28;0;19;0
WireConnection;28;1;25;0
WireConnection;28;2;50;0
WireConnection;47;0;46;1
WireConnection;47;1;34;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;48;2;46;3
WireConnection;33;0;28;0
WireConnection;33;1;25;4
WireConnection;33;2;29;0
WireConnection;0;0;33;0
WireConnection;0;2;48;0
ASEEND*/
//CHKSM=2331B76340D4FB6DD7566506CD12C5705087ED75