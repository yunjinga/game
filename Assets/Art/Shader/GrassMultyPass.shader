// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GrassMultyPass"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (1,1,1,0)
		_VariationColor("Variation Color", Color) = (1,1,1,0)
		_SecondColor("Second Color", Color) = (1,1,1,0)
		_TilingOffset("Tiling Offset", Vector) = (1,1,0,0)
		_Shadow("Shadow", Range( 0 , 1)) = 0
		_WindNoise("Wind Noise", Float) = 0
		_WindStrength("Wind Strength", Float) = 0
		_WindSpeed("Wind Speed", Float) = 0
		_VariationNoise("Variation Noise", Float) = 1
		_VartiationAmountSharpness("Vartiation Amount-Sharpness", Vector) = (0.24,1.06,0,0)
		_Clip("Clip", Range( 0 , 1)) = 0

	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
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
			uniform float4 _BaseColor;
			uniform float4 _VariationColor;
			uniform float2 _VartiationAmountSharpness;
			uniform float _VariationNoise;
			uniform float4 _TilingOffset;
			uniform sampler2D _Texture;
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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_SHADOW_COORDS(3)
			};
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float2 appendResult10 = (float2(ase_worldPos.x , ase_worldPos.z));
				float mulTime19 = _Time.y * _WindSpeed;
				float2 temp_cast_0 = (mulTime19).xx;
				float2 texCoord27 = v.ase_texcoord.xy * appendResult10 + temp_cast_0;
				float simplePerlin2D31 = snoise( texCoord27*_WindNoise );
				simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
				float3 temp_cast_1 = (( simplePerlin2D31 * _WindStrength * v.ase_texcoord.y )).xxx;
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				
				v.vertex.xyz += temp_cast_1;
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

				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float2 appendResult10 = (float2(ase_worldPos.x , ase_worldPos.z));
				float simplePerlin2D13 = snoise( appendResult10*_VariationNoise );
				simplePerlin2D13 = simplePerlin2D13*0.5 + 0.5;
				float smoothstepResult21 = smoothstep( _VartiationAmountSharpness.x , _VartiationAmountSharpness.y , simplePerlin2D13);
				float4 lerpResult23 = lerp( _BaseColor , _VariationColor , smoothstepResult21);
				float2 appendResult16 = (float2(_TilingOffset.x , _TilingOffset.y));
				float2 appendResult22 = (float2(_TilingOffset.z , _TilingOffset.w));
				float2 texCoord25 = i.ase_texcoord2.xy * appendResult16 + appendResult22;
				float4 lerpResult29 = lerp( _SecondColor , lerpResult23 , texCoord25.y);
				float4 tex2DNode34 = tex2D( _Texture, texCoord25 );
				UNITY_LIGHT_ATTENUATION(ase_atten, i, ase_worldPos)
				float clampResult33 = clamp( ( ase_atten + _Shadow ) , 0.0 , 1.0 );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				clip( tex2DNode34.a - _Clip);
				
				
				outColor = ( lerpResult29 * tex2DNode34 * float4( ( clampResult33 * ase_lightColor.rgb ) , 0.0 ) ).rgb;
				outAlpha = tex2DNode34.a;
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
			uniform float4 _BaseColor;
			uniform float4 _VariationColor;
			uniform float2 _VartiationAmountSharpness;
			uniform float _VariationNoise;
			uniform float4 _TilingOffset;
			uniform sampler2D _Texture;
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
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_SHADOW_COORDS(3)
			};

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float2 appendResult10 = (float2(ase_worldPos.x , ase_worldPos.z));
				float mulTime19 = _Time.y * _WindSpeed;
				float2 temp_cast_0 = (mulTime19).xx;
				float2 texCoord27 = v.ase_texcoord.xy * appendResult10 + temp_cast_0;
				float simplePerlin2D31 = snoise( texCoord27*_WindNoise );
				simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
				float3 temp_cast_1 = (( simplePerlin2D31 * _WindStrength * v.ase_texcoord.y )).xxx;
				
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				
				v.vertex.xyz += temp_cast_1;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float3 ase_worldPos = i.ase_texcoord1.xyz;
				float2 appendResult10 = (float2(ase_worldPos.x , ase_worldPos.z));
				float simplePerlin2D13 = snoise( appendResult10*_VariationNoise );
				simplePerlin2D13 = simplePerlin2D13*0.5 + 0.5;
				float smoothstepResult21 = smoothstep( _VartiationAmountSharpness.x , _VartiationAmountSharpness.y , simplePerlin2D13);
				float4 lerpResult23 = lerp( _BaseColor , _VariationColor , smoothstepResult21);
				float2 appendResult16 = (float2(_TilingOffset.x , _TilingOffset.y));
				float2 appendResult22 = (float2(_TilingOffset.z , _TilingOffset.w));
				float2 texCoord25 = i.ase_texcoord2.xy * appendResult16 + appendResult22;
				float4 lerpResult29 = lerp( _SecondColor , lerpResult23 , texCoord25.y);
				float4 tex2DNode34 = tex2D( _Texture, texCoord25 );
				UNITY_LIGHT_ATTENUATION(ase_atten, i, ase_worldPos)
				float clampResult33 = clamp( ( ase_atten + _Shadow ) , 0.0 , 1.0 );
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				clip( tex2DNode34.a - _Clip);
				
				
				outColor = ( lerpResult29 * tex2DNode34 * float4( ( clampResult33 * ase_lightColor.rgb ) , 0.0 ) ).rgb;
				outAlpha = tex2DNode34.a;
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
3046;149;1714;1147;4108.656;2110.354;3.049437;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;8;-3043.69,-607.0602;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;9;-2354.815,-808.0183;Inherit;False;Property;_VariationNoise;Variation Noise;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-2848.803,-580.6224;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;13;-2044.149,-1172.001;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;12;-2083.535,-948.138;Inherit;False;Property;_VartiationAmountSharpness;Vartiation Amount-Sharpness;10;0;Create;True;0;0;0;False;0;False;0.24,1.06;0.24,1.06;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;15;-1555.713,-11.37182;Inherit;False;Property;_Shadow;Shadow;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;11;-1798.342,-504.9979;Inherit;False;Property;_TilingOffset;Tiling Offset;4;0;Create;True;0;0;0;False;0;False;1,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;20;-1482.007,-130.3499;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;21;-1698.739,-1055.579;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.46;False;2;FLOAT;0.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1235.764,-98.91312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1588.945,528.7651;Inherit;False;Property;_WindSpeed;Wind Speed;8;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-1676.789,-1496.228;Inherit;False;Property;_BaseColor;Base Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-1686.175,-1327.437;Inherit;False;Property;_VariationColor;Variation Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;16;-1545.394,-468.0784;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-1550.237,-374.4414;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;24;-800.4891,-654.1295;Inherit;False;Property;_SecondColor;Second Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;33;-1107.738,-95.31351;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-1363.561,-485.6247;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1381.805,525.527;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;23;-1303.847,-1279.3;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;43;-1073.07,41.09161;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;29;-621.0781,-353.929;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;34;-846.3823,-879.7103;Inherit;True;Property;_Texture;Texture;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-1139.35,415.1902;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-905.0696,-61.90839;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1025.742,564.8398;Inherit;False;Property;_WindNoise;Wind Noise;6;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-613.9756,46.94001;Inherit;False;Property;_Clip;Clip;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;31;-825.8537,388.1487;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-690.1171,513.4042;Inherit;False;Property;_WindStrength;Wind Strength;7;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;30;-701.5996,262.6248;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-260.1045,-469.6649;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-432.3834,413.6358;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;5;-233.3122,1.352331;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;55.74026,141.4368;Float;False;False;-1;2;ASEMaterialInspector;100;8;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;Deferred;0;2;Deferred;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;True;0;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;0;False;-1;True;0;False;-1;True;False;0;False;-1;0;False;-1;True;2;LightMode=ShadowCaster;RenderType=Opaque=RenderType;True;2;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;52,81.55009;Float;False;False;-1;2;ASEMaterialInspector;100;8;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardAdd;0;1;ForwardAdd;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;True;1;LightMode=ForwardAdd;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;ASEMaterialInspector;100;2;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ShadowCaster;0;3;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;52,-28.44991;Float;False;True;-1;2;ASEMaterialInspector;100;8;GrassMultyPass;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardBase;0;0;ForwardBase;3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;False;0;False;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;LightMode=ForwardBase;Queue=Geometry=Queue=0;RenderType=Opaque=RenderType;True;2;False;0;;0;0;Standard;0;0;4;True;False;False;True;False;;False;0
WireConnection;10;0;8;1
WireConnection;10;1;8;3
WireConnection;13;0;10;0
WireConnection;13;1;9;0
WireConnection;21;0;13;0
WireConnection;21;1;12;1
WireConnection;21;2;12;2
WireConnection;28;0;20;0
WireConnection;28;1;15;0
WireConnection;16;0;11;1
WireConnection;16;1;11;2
WireConnection;22;0;11;3
WireConnection;22;1;11;4
WireConnection;33;0;28;0
WireConnection;25;0;16;0
WireConnection;25;1;22;0
WireConnection;19;0;14;0
WireConnection;23;0;17;0
WireConnection;23;1;18;0
WireConnection;23;2;21;0
WireConnection;29;0;24;0
WireConnection;29;1;23;0
WireConnection;29;2;25;2
WireConnection;34;1;25;0
WireConnection;27;0;10;0
WireConnection;27;1;19;0
WireConnection;42;0;33;0
WireConnection;42;1;43;1
WireConnection;31;0;27;0
WireConnection;31;1;26;0
WireConnection;36;0;29;0
WireConnection;36;1;34;0
WireConnection;36;2;42;0
WireConnection;35;0;31;0
WireConnection;35;1;32;0
WireConnection;35;2;30;2
WireConnection;5;0;36;0
WireConnection;5;1;34;4
WireConnection;5;2;37;0
WireConnection;0;0;5;0
WireConnection;0;1;34;4
WireConnection;0;2;35;0
ASEEND*/
//CHKSM=AFB488EA6294768039EC556E29766D4F5CB398E4