// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "J_FX_01"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HDR]_Tint("Tint", Color) = (1,1,1,1)
		[Enum(Additive,1,Blended,10)]_Blend_Mode("Blend_Mode", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Cull_Mode("Cull_Mode", Float) = 0
		[Enum(Use Alpha,0,Use R,1)]_Alpha("Alpha", Float) = 0
		_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_MainUseDistort("MainUseDistort", Float) = 1
		_MainTexPannerXY("MainTex Panner X/Y", Vector) = (0,0,0,0)
		_DistortTex("DistortTex", 2D) = "white" {}
		_DistortPannerXYPowerXY("DistortPannerXY/Power/XY", Vector) = (0,0,0,0)
		[Enum(Step,0,Smooth,1)]_Dissolve_Mode("Dissolve_Mode", Float) = 0
		[Enum(UV,0,Screen,1)]_DissolveUV("DissolveUV", Float) = 0
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_Dissolveamount("Dissolveamount", Range( 0 , 1)) = 0
		[Toggle]_DissolveUseDistort("DissolveUseDistort", Float) = 0
		_DissolvePannerXY("DissolvePannerXY", Vector) = (0,0,0,0)
		_Brightnessamount("Brightnessamount", Range( 0 , 1)) = 0
		[HDR]_BrightnessColor("BrightnessColor", Color) = (0,0,0,0)
		[Toggle]_UseCustom("UseCustom", Float) = 0
		[Enum(MainOffset,0,MainTiling,1,DistortPower,2,DistortOffset,3,DistortTiling,4,DissolveOffset,5,DissolveTiling,6)]_Custom1_XY("Custom1_XY", Float) = 0
		[Enum(MainOffset,0,MainTiling,1,DistortPower,2,DistortOffset,3,DistortTiling,4,DissolveOffset,5,DissolveTiling,6)]_Custom1_ZW("Custom1_ZW", Float) = 1
		[Enum(MainOffset,0,MainTiling,1,DistortPower,2,DistortOffset,3,DistortTiling,4,DissolveOffset,5,DissolveTiling,6)]_Custom2_XY("Custom2_XY", Float) = 2

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "PreviewType"="Plane" }
		
		Cull [_Cull_Mode]
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }
			
			Blend SrcAlpha [_Blend_Mode], SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 170003

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DistortTex_ST;
			float4 _Tint;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _DistortPannerXYPowerXY;
			float4 _DissolvePannerXY;
			float4 _BrightnessColor;
			float2 _MainTexPannerXY;
			float _Brightnessamount;
			float _Dissolveamount;
			float _DissolveUseDistort;
			float _DissolveUV;
			float _Blend_Mode;
			float _Dissolve_Mode;
			float _Custom2_XY;
			float _Custom1_ZW;
			float _Custom1_XY;
			float _UseCustom;
			float _Cull_Mode;
			float _MainUseDistort;
			float _Alpha;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_texcoord5 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner205 = ( 1.0 * _Time.y * _MainTexPannerXY + uv_MainTex);
				float2 appendResult183 = (float2(IN.ase_texcoord4.x , IN.ase_texcoord4.y));
				float2 lerpResult209 = lerp( float2( 0,0 ) , appendResult183 , _UseCustom);
				float2 Custom1XY184 = lerpResult209;
				float Custom1_XY_To254 = _Custom1_XY;
				float2 appendResult188 = (float2(IN.ase_texcoord4.z , IN.ase_texcoord4.w));
				float2 lerpResult211 = lerp( float2( 0,0 ) , appendResult188 , _UseCustom);
				float2 Custom1ZW187 = lerpResult211;
				float Custom1_ZW_To261 = _Custom1_ZW;
				float2 appendResult192 = (float2(IN.ase_texcoord5.x , IN.ase_texcoord5.y));
				float2 lerpResult212 = lerp( float2( 0,0 ) , appendResult192 , _UseCustom);
				float2 Custom2XY193 = lerpResult212;
				float Custom2_XY_To262 = _Custom2_XY;
				float2 MainTiling317 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 1.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult63 = (float2(_DistortPannerXYPowerXY.z , _DistortPannerXYPowerXY.w));
				float2 DistortPower356 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 2.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult60 = (float2(_DistortPannerXYPowerXY.x , _DistortPannerXYPowerXY.y));
				float2 uv_DistortTex = IN.ase_texcoord3.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float2 panner56 = ( 1.0 * _Time.y * appendResult60 + uv_DistortTex);
				float2 DistortTiling424 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 4.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortOffset388 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 3.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortTerm87 = ( ( appendResult63 + DistortPower356 ) * tex2D( _DistortTex, ( ( panner56 * ( DistortTiling424 + 1.0 ) ) + DistortOffset388 ) ).r * 0.1 );
				float2 lerpResult518 = lerp( float2( 0,0 ) , DistortTerm87 , _MainUseDistort);
				float2 MainOffset260 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 0.0 * -1.0 ) ) ) ) ) ) );
				float4 tex2DNode13 = tex2D( _MainTex, ( ( panner205 * ( MainTiling317 + 1.0 ) ) + lerpResult518 + MainOffset260 ) );
				float2 DissolveOffset461 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 5.0 * -1.0 ) ) ) ) ) ) );
				float2 DissolveTiling496 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 6.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult99 = (float2(_DissolvePannerXY.x , _DissolvePannerXY.y));
				float2 uv_DissolveTex = IN.ase_texcoord3.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult172 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenpositionTerm177 = ( appendResult172 * 2.0 );
				float2 lerpResult180 = lerp( uv_DissolveTex , ScreenpositionTerm177 , _DissolveUV);
				float2 panner96 = ( 1.0 * _Time.y * appendResult99 + lerpResult180);
				float2 lerpResult92 = lerp( float2( 0,0 ) , DistortTerm87 , _DissolveUseDistort);
				float4 tex2DNode66 = tex2D( _DissolveTex, ( ( DissolveOffset461 + ( ( DissolveTiling496 + 1.0 ) * panner96 ) ) + lerpResult92 ) );
				float lerpResult214 = lerp( 0.0 , IN.ase_texcoord5.w , _UseCustom);
				float Custom2W196 = lerpResult214;
				float temp_output_197_0 = ( _Dissolveamount + Custom2W196 );
				float clampResult79 = clamp( step( tex2DNode66.r , temp_output_197_0 ) , 0.0 , 1.0 );
				float temp_output_71_0 = ( 1.0 - clampResult79 );
				float lerpResult213 = lerp( 0.0 , IN.ase_texcoord5.z , _UseCustom);
				float Custom2Z195 = lerpResult213;
				float temp_output_200_0 = ( _Brightnessamount + Custom2Z195 );
				float clampResult102 = clamp( step( tex2DNode66.r , ( temp_output_197_0 + temp_output_200_0 ) ) , 0.0 , 1.0 );
				float temp_output_515_0 = ( 1.0 - tex2DNode66.r );
				float clampResult78 = clamp( ( temp_output_515_0 + (-1.0 + (temp_output_197_0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float temp_output_76_0 = ( 1.0 - clampResult78 );
				float clampResult112 = clamp( ( temp_output_515_0 + (-1.0 + (( temp_output_200_0 + temp_output_197_0 ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float lerpResult117 = lerp( ( temp_output_71_0 - ( 1.0 - clampResult102 ) ) , ( temp_output_76_0 - ( 1.0 - clampResult112 ) ) , _Dissolve_Mode);
				float BrightnessTerm106 = lerpResult117;
				float4 lerpResult107 = lerp( ( _Tint * IN.ase_color * tex2DNode13 ) , _BrightnessColor , BrightnessTerm106);
				
				float lerpResult119 = lerp( tex2DNode13.a , tex2DNode13.r , _Alpha);
				float lerpResult81 = lerp( temp_output_71_0 , temp_output_76_0 , _Dissolve_Mode);
				float DissolveTerm85 = lerpResult81;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult107.rgb;
				float Alpha = ( _Tint.a * IN.ase_color.a * lerpResult119 * DissolveTerm85 );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 170003

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DistortTex_ST;
			float4 _Tint;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _DistortPannerXYPowerXY;
			float4 _DissolvePannerXY;
			float4 _BrightnessColor;
			float2 _MainTexPannerXY;
			float _Brightnessamount;
			float _Dissolveamount;
			float _DissolveUseDistort;
			float _DissolveUV;
			float _Blend_Mode;
			float _Dissolve_Mode;
			float _Custom2_XY;
			float _Custom1_ZW;
			float _Custom1_XY;
			float _UseCustom;
			float _Cull_Mode;
			float _MainUseDistort;
			float _Alpha;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_texcoord4 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner205 = ( 1.0 * _Time.y * _MainTexPannerXY + uv_MainTex);
				float2 appendResult183 = (float2(IN.ase_texcoord3.x , IN.ase_texcoord3.y));
				float2 lerpResult209 = lerp( float2( 0,0 ) , appendResult183 , _UseCustom);
				float2 Custom1XY184 = lerpResult209;
				float Custom1_XY_To254 = _Custom1_XY;
				float2 appendResult188 = (float2(IN.ase_texcoord3.z , IN.ase_texcoord3.w));
				float2 lerpResult211 = lerp( float2( 0,0 ) , appendResult188 , _UseCustom);
				float2 Custom1ZW187 = lerpResult211;
				float Custom1_ZW_To261 = _Custom1_ZW;
				float2 appendResult192 = (float2(IN.ase_texcoord4.x , IN.ase_texcoord4.y));
				float2 lerpResult212 = lerp( float2( 0,0 ) , appendResult192 , _UseCustom);
				float2 Custom2XY193 = lerpResult212;
				float Custom2_XY_To262 = _Custom2_XY;
				float2 MainTiling317 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 1.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult63 = (float2(_DistortPannerXYPowerXY.z , _DistortPannerXYPowerXY.w));
				float2 DistortPower356 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 2.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult60 = (float2(_DistortPannerXYPowerXY.x , _DistortPannerXYPowerXY.y));
				float2 uv_DistortTex = IN.ase_texcoord2.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float2 panner56 = ( 1.0 * _Time.y * appendResult60 + uv_DistortTex);
				float2 DistortTiling424 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 4.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortOffset388 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 3.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortTerm87 = ( ( appendResult63 + DistortPower356 ) * tex2D( _DistortTex, ( ( panner56 * ( DistortTiling424 + 1.0 ) ) + DistortOffset388 ) ).r * 0.1 );
				float2 lerpResult518 = lerp( float2( 0,0 ) , DistortTerm87 , _MainUseDistort);
				float2 MainOffset260 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 0.0 * -1.0 ) ) ) ) ) ) );
				float4 tex2DNode13 = tex2D( _MainTex, ( ( panner205 * ( MainTiling317 + 1.0 ) ) + lerpResult518 + MainOffset260 ) );
				float lerpResult119 = lerp( tex2DNode13.a , tex2DNode13.r , _Alpha);
				float2 DissolveOffset461 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 5.0 * -1.0 ) ) ) ) ) ) );
				float2 DissolveTiling496 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 6.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult99 = (float2(_DissolvePannerXY.x , _DissolvePannerXY.y));
				float2 uv_DissolveTex = IN.ase_texcoord2.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult172 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenpositionTerm177 = ( appendResult172 * 2.0 );
				float2 lerpResult180 = lerp( uv_DissolveTex , ScreenpositionTerm177 , _DissolveUV);
				float2 panner96 = ( 1.0 * _Time.y * appendResult99 + lerpResult180);
				float2 lerpResult92 = lerp( float2( 0,0 ) , DistortTerm87 , _DissolveUseDistort);
				float4 tex2DNode66 = tex2D( _DissolveTex, ( ( DissolveOffset461 + ( ( DissolveTiling496 + 1.0 ) * panner96 ) ) + lerpResult92 ) );
				float lerpResult214 = lerp( 0.0 , IN.ase_texcoord4.w , _UseCustom);
				float Custom2W196 = lerpResult214;
				float temp_output_197_0 = ( _Dissolveamount + Custom2W196 );
				float clampResult79 = clamp( step( tex2DNode66.r , temp_output_197_0 ) , 0.0 , 1.0 );
				float temp_output_71_0 = ( 1.0 - clampResult79 );
				float temp_output_515_0 = ( 1.0 - tex2DNode66.r );
				float clampResult78 = clamp( ( temp_output_515_0 + (-1.0 + (temp_output_197_0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float temp_output_76_0 = ( 1.0 - clampResult78 );
				float lerpResult81 = lerp( temp_output_71_0 , temp_output_76_0 , _Dissolve_Mode);
				float DissolveTerm85 = lerpResult81;
				
				float Alpha = ( _Tint.a * IN.ase_color.a * lerpResult119 * DissolveTerm85 );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }
			
			Blend SrcAlpha [_Blend_Mode], SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 170003

			
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#define ASE_NEEDS_FRAG_COLOR


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _DistortTex_ST;
			float4 _Tint;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _DistortPannerXYPowerXY;
			float4 _DissolvePannerXY;
			float4 _BrightnessColor;
			float2 _MainTexPannerXY;
			float _Brightnessamount;
			float _Dissolveamount;
			float _DissolveUseDistort;
			float _DissolveUV;
			float _Blend_Mode;
			float _Dissolve_Mode;
			float _Custom2_XY;
			float _Custom1_ZW;
			float _Custom1_XY;
			float _UseCustom;
			float _Cull_Mode;
			float _MainUseDistort;
			float _Alpha;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_texcoord5 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner205 = ( 1.0 * _Time.y * _MainTexPannerXY + uv_MainTex);
				float2 appendResult183 = (float2(IN.ase_texcoord4.x , IN.ase_texcoord4.y));
				float2 lerpResult209 = lerp( float2( 0,0 ) , appendResult183 , _UseCustom);
				float2 Custom1XY184 = lerpResult209;
				float Custom1_XY_To254 = _Custom1_XY;
				float2 appendResult188 = (float2(IN.ase_texcoord4.z , IN.ase_texcoord4.w));
				float2 lerpResult211 = lerp( float2( 0,0 ) , appendResult188 , _UseCustom);
				float2 Custom1ZW187 = lerpResult211;
				float Custom1_ZW_To261 = _Custom1_ZW;
				float2 appendResult192 = (float2(IN.ase_texcoord5.x , IN.ase_texcoord5.y));
				float2 lerpResult212 = lerp( float2( 0,0 ) , appendResult192 , _UseCustom);
				float2 Custom2XY193 = lerpResult212;
				float Custom2_XY_To262 = _Custom2_XY;
				float2 MainTiling317 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 1.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult63 = (float2(_DistortPannerXYPowerXY.z , _DistortPannerXYPowerXY.w));
				float2 DistortPower356 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 2.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult60 = (float2(_DistortPannerXYPowerXY.x , _DistortPannerXYPowerXY.y));
				float2 uv_DistortTex = IN.ase_texcoord3.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float2 panner56 = ( 1.0 * _Time.y * appendResult60 + uv_DistortTex);
				float2 DistortTiling424 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 4.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortOffset388 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 3.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortTerm87 = ( ( appendResult63 + DistortPower356 ) * tex2D( _DistortTex, ( ( panner56 * ( DistortTiling424 + 1.0 ) ) + DistortOffset388 ) ).r * 0.1 );
				float2 lerpResult518 = lerp( float2( 0,0 ) , DistortTerm87 , _MainUseDistort);
				float2 MainOffset260 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 0.0 * -1.0 ) ) ) ) ) ) );
				float4 tex2DNode13 = tex2D( _MainTex, ( ( panner205 * ( MainTiling317 + 1.0 ) ) + lerpResult518 + MainOffset260 ) );
				float2 DissolveOffset461 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 5.0 * -1.0 ) ) ) ) ) ) );
				float2 DissolveTiling496 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 6.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult99 = (float2(_DissolvePannerXY.x , _DissolvePannerXY.y));
				float2 uv_DissolveTex = IN.ase_texcoord3.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult172 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenpositionTerm177 = ( appendResult172 * 2.0 );
				float2 lerpResult180 = lerp( uv_DissolveTex , ScreenpositionTerm177 , _DissolveUV);
				float2 panner96 = ( 1.0 * _Time.y * appendResult99 + lerpResult180);
				float2 lerpResult92 = lerp( float2( 0,0 ) , DistortTerm87 , _DissolveUseDistort);
				float4 tex2DNode66 = tex2D( _DissolveTex, ( ( DissolveOffset461 + ( ( DissolveTiling496 + 1.0 ) * panner96 ) ) + lerpResult92 ) );
				float lerpResult214 = lerp( 0.0 , IN.ase_texcoord5.w , _UseCustom);
				float Custom2W196 = lerpResult214;
				float temp_output_197_0 = ( _Dissolveamount + Custom2W196 );
				float clampResult79 = clamp( step( tex2DNode66.r , temp_output_197_0 ) , 0.0 , 1.0 );
				float temp_output_71_0 = ( 1.0 - clampResult79 );
				float lerpResult213 = lerp( 0.0 , IN.ase_texcoord5.z , _UseCustom);
				float Custom2Z195 = lerpResult213;
				float temp_output_200_0 = ( _Brightnessamount + Custom2Z195 );
				float clampResult102 = clamp( step( tex2DNode66.r , ( temp_output_197_0 + temp_output_200_0 ) ) , 0.0 , 1.0 );
				float temp_output_515_0 = ( 1.0 - tex2DNode66.r );
				float clampResult78 = clamp( ( temp_output_515_0 + (-1.0 + (temp_output_197_0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float temp_output_76_0 = ( 1.0 - clampResult78 );
				float clampResult112 = clamp( ( temp_output_515_0 + (-1.0 + (( temp_output_200_0 + temp_output_197_0 ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float lerpResult117 = lerp( ( temp_output_71_0 - ( 1.0 - clampResult102 ) ) , ( temp_output_76_0 - ( 1.0 - clampResult112 ) ) , _Dissolve_Mode);
				float BrightnessTerm106 = lerpResult117;
				float4 lerpResult107 = lerp( ( _Tint * IN.ase_color * tex2DNode13 ) , _BrightnessColor , BrightnessTerm106);
				
				float lerpResult119 = lerp( tex2DNode13.a , tex2DNode13.r , _Alpha);
				float lerpResult81 = lerp( temp_output_71_0 , temp_output_76_0 , _Dissolve_Mode);
				float DissolveTerm85 = lerpResult81;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult107.rgb;
				float Alpha = ( _Tint.a * IN.ase_color.a * lerpResult119 * DissolveTerm85 );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}


		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
			Cull Off

			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 170003

        
			#pragma only_renderers d3d11 glcore gles gles3 ps5 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DistortTex_ST;
			float4 _Tint;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _DistortPannerXYPowerXY;
			float4 _DissolvePannerXY;
			float4 _BrightnessColor;
			float2 _MainTexPannerXY;
			float _Brightnessamount;
			float _Dissolveamount;
			float _DissolveUseDistort;
			float _DissolveUV;
			float _Blend_Mode;
			float _Dissolve_Mode;
			float _Custom2_XY;
			float _Custom1_ZW;
			float _Custom1_XY;
			float _UseCustom;
			float _Cull_Mode;
			float _MainUseDistort;
			float _Alpha;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif
			
			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner205 = ( 1.0 * _Time.y * _MainTexPannerXY + uv_MainTex);
				float2 appendResult183 = (float2(IN.ase_texcoord1.x , IN.ase_texcoord1.y));
				float2 lerpResult209 = lerp( float2( 0,0 ) , appendResult183 , _UseCustom);
				float2 Custom1XY184 = lerpResult209;
				float Custom1_XY_To254 = _Custom1_XY;
				float2 appendResult188 = (float2(IN.ase_texcoord1.z , IN.ase_texcoord1.w));
				float2 lerpResult211 = lerp( float2( 0,0 ) , appendResult188 , _UseCustom);
				float2 Custom1ZW187 = lerpResult211;
				float Custom1_ZW_To261 = _Custom1_ZW;
				float2 appendResult192 = (float2(IN.ase_texcoord2.x , IN.ase_texcoord2.y));
				float2 lerpResult212 = lerp( float2( 0,0 ) , appendResult192 , _UseCustom);
				float2 Custom2XY193 = lerpResult212;
				float Custom2_XY_To262 = _Custom2_XY;
				float2 MainTiling317 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 1.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult63 = (float2(_DistortPannerXYPowerXY.z , _DistortPannerXYPowerXY.w));
				float2 DistortPower356 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 2.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult60 = (float2(_DistortPannerXYPowerXY.x , _DistortPannerXYPowerXY.y));
				float2 uv_DistortTex = IN.ase_texcoord.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float2 panner56 = ( 1.0 * _Time.y * appendResult60 + uv_DistortTex);
				float2 DistortTiling424 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 4.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortOffset388 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 3.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortTerm87 = ( ( appendResult63 + DistortPower356 ) * tex2D( _DistortTex, ( ( panner56 * ( DistortTiling424 + 1.0 ) ) + DistortOffset388 ) ).r * 0.1 );
				float2 lerpResult518 = lerp( float2( 0,0 ) , DistortTerm87 , _MainUseDistort);
				float2 MainOffset260 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 0.0 * -1.0 ) ) ) ) ) ) );
				float4 tex2DNode13 = tex2D( _MainTex, ( ( panner205 * ( MainTiling317 + 1.0 ) ) + lerpResult518 + MainOffset260 ) );
				float lerpResult119 = lerp( tex2DNode13.a , tex2DNode13.r , _Alpha);
				float2 DissolveOffset461 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 5.0 * -1.0 ) ) ) ) ) ) );
				float2 DissolveTiling496 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 6.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult99 = (float2(_DissolvePannerXY.x , _DissolvePannerXY.y));
				float2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult172 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenpositionTerm177 = ( appendResult172 * 2.0 );
				float2 lerpResult180 = lerp( uv_DissolveTex , ScreenpositionTerm177 , _DissolveUV);
				float2 panner96 = ( 1.0 * _Time.y * appendResult99 + lerpResult180);
				float2 lerpResult92 = lerp( float2( 0,0 ) , DistortTerm87 , _DissolveUseDistort);
				float4 tex2DNode66 = tex2D( _DissolveTex, ( ( DissolveOffset461 + ( ( DissolveTiling496 + 1.0 ) * panner96 ) ) + lerpResult92 ) );
				float lerpResult214 = lerp( 0.0 , IN.ase_texcoord2.w , _UseCustom);
				float Custom2W196 = lerpResult214;
				float temp_output_197_0 = ( _Dissolveamount + Custom2W196 );
				float clampResult79 = clamp( step( tex2DNode66.r , temp_output_197_0 ) , 0.0 , 1.0 );
				float temp_output_71_0 = ( 1.0 - clampResult79 );
				float temp_output_515_0 = ( 1.0 - tex2DNode66.r );
				float clampResult78 = clamp( ( temp_output_515_0 + (-1.0 + (temp_output_197_0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float temp_output_76_0 = ( 1.0 - clampResult78 );
				float lerpResult81 = lerp( temp_output_71_0 , temp_output_76_0 , _Dissolve_Mode);
				float DissolveTerm85 = lerpResult81;
				
				surfaceDescription.Alpha = ( _Tint.a * IN.ase_color.a * lerpResult119 * DissolveTerm85 );
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

			ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 170003


			#pragma only_renderers d3d11 glcore gles gles3 ps5 
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY
			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DistortTex_ST;
			float4 _Tint;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _DistortPannerXYPowerXY;
			float4 _DissolvePannerXY;
			float4 _BrightnessColor;
			float2 _MainTexPannerXY;
			float _Brightnessamount;
			float _Dissolveamount;
			float _DissolveUseDistort;
			float _DissolveUV;
			float _Blend_Mode;
			float _Dissolve_Mode;
			float _Custom2_XY;
			float _Custom1_ZW;
			float _Custom1_XY;
			float _UseCustom;
			float _Cull_Mode;
			float _MainUseDistort;
			float _Alpha;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;


			
        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner205 = ( 1.0 * _Time.y * _MainTexPannerXY + uv_MainTex);
				float2 appendResult183 = (float2(IN.ase_texcoord1.x , IN.ase_texcoord1.y));
				float2 lerpResult209 = lerp( float2( 0,0 ) , appendResult183 , _UseCustom);
				float2 Custom1XY184 = lerpResult209;
				float Custom1_XY_To254 = _Custom1_XY;
				float2 appendResult188 = (float2(IN.ase_texcoord1.z , IN.ase_texcoord1.w));
				float2 lerpResult211 = lerp( float2( 0,0 ) , appendResult188 , _UseCustom);
				float2 Custom1ZW187 = lerpResult211;
				float Custom1_ZW_To261 = _Custom1_ZW;
				float2 appendResult192 = (float2(IN.ase_texcoord2.x , IN.ase_texcoord2.y));
				float2 lerpResult212 = lerp( float2( 0,0 ) , appendResult192 , _UseCustom);
				float2 Custom2XY193 = lerpResult212;
				float Custom2_XY_To262 = _Custom2_XY;
				float2 MainTiling317 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 1.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult63 = (float2(_DistortPannerXYPowerXY.z , _DistortPannerXYPowerXY.w));
				float2 DistortPower356 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 2.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult60 = (float2(_DistortPannerXYPowerXY.x , _DistortPannerXYPowerXY.y));
				float2 uv_DistortTex = IN.ase_texcoord.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float2 panner56 = ( 1.0 * _Time.y * appendResult60 + uv_DistortTex);
				float2 DistortTiling424 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 4.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortOffset388 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 3.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortTerm87 = ( ( appendResult63 + DistortPower356 ) * tex2D( _DistortTex, ( ( panner56 * ( DistortTiling424 + 1.0 ) ) + DistortOffset388 ) ).r * 0.1 );
				float2 lerpResult518 = lerp( float2( 0,0 ) , DistortTerm87 , _MainUseDistort);
				float2 MainOffset260 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 0.0 * -1.0 ) ) ) ) ) ) );
				float4 tex2DNode13 = tex2D( _MainTex, ( ( panner205 * ( MainTiling317 + 1.0 ) ) + lerpResult518 + MainOffset260 ) );
				float lerpResult119 = lerp( tex2DNode13.a , tex2DNode13.r , _Alpha);
				float2 DissolveOffset461 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 5.0 * -1.0 ) ) ) ) ) ) );
				float2 DissolveTiling496 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 6.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult99 = (float2(_DissolvePannerXY.x , _DissolvePannerXY.y));
				float2 uv_DissolveTex = IN.ase_texcoord.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult172 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenpositionTerm177 = ( appendResult172 * 2.0 );
				float2 lerpResult180 = lerp( uv_DissolveTex , ScreenpositionTerm177 , _DissolveUV);
				float2 panner96 = ( 1.0 * _Time.y * appendResult99 + lerpResult180);
				float2 lerpResult92 = lerp( float2( 0,0 ) , DistortTerm87 , _DissolveUseDistort);
				float4 tex2DNode66 = tex2D( _DissolveTex, ( ( DissolveOffset461 + ( ( DissolveTiling496 + 1.0 ) * panner96 ) ) + lerpResult92 ) );
				float lerpResult214 = lerp( 0.0 , IN.ase_texcoord2.w , _UseCustom);
				float Custom2W196 = lerpResult214;
				float temp_output_197_0 = ( _Dissolveamount + Custom2W196 );
				float clampResult79 = clamp( step( tex2DNode66.r , temp_output_197_0 ) , 0.0 , 1.0 );
				float temp_output_71_0 = ( 1.0 - clampResult79 );
				float temp_output_515_0 = ( 1.0 - tex2DNode66.r );
				float clampResult78 = clamp( ( temp_output_515_0 + (-1.0 + (temp_output_197_0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float temp_output_76_0 = ( 1.0 - clampResult78 );
				float lerpResult81 = lerp( temp_output_71_0 , temp_output_76_0 , _Dissolve_Mode);
				float DissolveTerm85 = lerpResult81;
				
				surfaceDescription.Alpha = ( _Tint.a * IN.ase_color.a * lerpResult119 * DissolveTerm85 );
				surfaceDescription.AlphaClipThreshold = 0.5;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}
        
			ENDHLSL
        }
		
		
        Pass
        {
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

        
			HLSLPROGRAM
			
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 170003

			
			#pragma only_renderers d3d11 glcore gles gles3 ps5 
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DistortTex_ST;
			float4 _Tint;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _DistortPannerXYPowerXY;
			float4 _DissolvePannerXY;
			float4 _BrightnessColor;
			float2 _MainTexPannerXY;
			float _Brightnessamount;
			float _Dissolveamount;
			float _DissolveUseDistort;
			float _DissolveUV;
			float _Blend_Mode;
			float _Dissolve_Mode;
			float _Custom2_XY;
			float _Custom1_ZW;
			float _Custom1_XY;
			float _UseCustom;
			float _Cull_Mode;
			float _MainUseDistort;
			float _Alpha;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;


			      
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner205 = ( 1.0 * _Time.y * _MainTexPannerXY + uv_MainTex);
				float2 appendResult183 = (float2(IN.ase_texcoord2.x , IN.ase_texcoord2.y));
				float2 lerpResult209 = lerp( float2( 0,0 ) , appendResult183 , _UseCustom);
				float2 Custom1XY184 = lerpResult209;
				float Custom1_XY_To254 = _Custom1_XY;
				float2 appendResult188 = (float2(IN.ase_texcoord2.z , IN.ase_texcoord2.w));
				float2 lerpResult211 = lerp( float2( 0,0 ) , appendResult188 , _UseCustom);
				float2 Custom1ZW187 = lerpResult211;
				float Custom1_ZW_To261 = _Custom1_ZW;
				float2 appendResult192 = (float2(IN.ase_texcoord3.x , IN.ase_texcoord3.y));
				float2 lerpResult212 = lerp( float2( 0,0 ) , appendResult192 , _UseCustom);
				float2 Custom2XY193 = lerpResult212;
				float Custom2_XY_To262 = _Custom2_XY;
				float2 MainTiling317 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 1.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult63 = (float2(_DistortPannerXYPowerXY.z , _DistortPannerXYPowerXY.w));
				float2 DistortPower356 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 2.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult60 = (float2(_DistortPannerXYPowerXY.x , _DistortPannerXYPowerXY.y));
				float2 uv_DistortTex = IN.ase_texcoord1.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float2 panner56 = ( 1.0 * _Time.y * appendResult60 + uv_DistortTex);
				float2 DistortTiling424 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 4.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortOffset388 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 3.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortTerm87 = ( ( appendResult63 + DistortPower356 ) * tex2D( _DistortTex, ( ( panner56 * ( DistortTiling424 + 1.0 ) ) + DistortOffset388 ) ).r * 0.1 );
				float2 lerpResult518 = lerp( float2( 0,0 ) , DistortTerm87 , _MainUseDistort);
				float2 MainOffset260 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 0.0 * -1.0 ) ) ) ) ) ) );
				float4 tex2DNode13 = tex2D( _MainTex, ( ( panner205 * ( MainTiling317 + 1.0 ) ) + lerpResult518 + MainOffset260 ) );
				float lerpResult119 = lerp( tex2DNode13.a , tex2DNode13.r , _Alpha);
				float2 DissolveOffset461 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 5.0 * -1.0 ) ) ) ) ) ) );
				float2 DissolveTiling496 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 6.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult99 = (float2(_DissolvePannerXY.x , _DissolvePannerXY.y));
				float2 uv_DissolveTex = IN.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult172 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenpositionTerm177 = ( appendResult172 * 2.0 );
				float2 lerpResult180 = lerp( uv_DissolveTex , ScreenpositionTerm177 , _DissolveUV);
				float2 panner96 = ( 1.0 * _Time.y * appendResult99 + lerpResult180);
				float2 lerpResult92 = lerp( float2( 0,0 ) , DistortTerm87 , _DissolveUseDistort);
				float4 tex2DNode66 = tex2D( _DissolveTex, ( ( DissolveOffset461 + ( ( DissolveTiling496 + 1.0 ) * panner96 ) ) + lerpResult92 ) );
				float lerpResult214 = lerp( 0.0 , IN.ase_texcoord3.w , _UseCustom);
				float Custom2W196 = lerpResult214;
				float temp_output_197_0 = ( _Dissolveamount + Custom2W196 );
				float clampResult79 = clamp( step( tex2DNode66.r , temp_output_197_0 ) , 0.0 , 1.0 );
				float temp_output_71_0 = ( 1.0 - clampResult79 );
				float temp_output_515_0 = ( 1.0 - tex2DNode66.r );
				float clampResult78 = clamp( ( temp_output_515_0 + (-1.0 + (temp_output_197_0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float temp_output_76_0 = ( 1.0 - clampResult78 );
				float lerpResult81 = lerp( temp_output_71_0 , temp_output_76_0 , _Dissolve_Mode);
				float DissolveTerm85 = lerpResult81;
				
				surfaceDescription.Alpha = ( _Tint.a * IN.ase_color.a * lerpResult119 * DissolveTerm85 );
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}
        
			ENDHLSL
        }

		
        Pass
        {
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }
        
			ZTest LEqual
			ZWrite On
        
        
			HLSLPROGRAM
        
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 170003

        
			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag
        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
        
			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _DistortTex_ST;
			float4 _Tint;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _DistortPannerXYPowerXY;
			float4 _DissolvePannerXY;
			float4 _BrightnessColor;
			float2 _MainTexPannerXY;
			float _Brightnessamount;
			float _Dissolveamount;
			float _DissolveUseDistort;
			float _DissolveUV;
			float _Blend_Mode;
			float _Dissolve_Mode;
			float _Custom2_XY;
			float _Custom1_ZW;
			float _Custom1_XY;
			float _UseCustom;
			float _Cull_Mode;
			float _MainUseDistort;
			float _Alpha;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DistortTex;
			sampler2D _DissolveTex;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
      
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3 = v.ase_texcoord2;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_color = v.ase_color;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 uv_MainTex = IN.ase_texcoord1.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner205 = ( 1.0 * _Time.y * _MainTexPannerXY + uv_MainTex);
				float2 appendResult183 = (float2(IN.ase_texcoord2.x , IN.ase_texcoord2.y));
				float2 lerpResult209 = lerp( float2( 0,0 ) , appendResult183 , _UseCustom);
				float2 Custom1XY184 = lerpResult209;
				float Custom1_XY_To254 = _Custom1_XY;
				float2 appendResult188 = (float2(IN.ase_texcoord2.z , IN.ase_texcoord2.w));
				float2 lerpResult211 = lerp( float2( 0,0 ) , appendResult188 , _UseCustom);
				float2 Custom1ZW187 = lerpResult211;
				float Custom1_ZW_To261 = _Custom1_ZW;
				float2 appendResult192 = (float2(IN.ase_texcoord3.x , IN.ase_texcoord3.y));
				float2 lerpResult212 = lerp( float2( 0,0 ) , appendResult192 , _UseCustom);
				float2 Custom2XY193 = lerpResult212;
				float Custom2_XY_To262 = _Custom2_XY;
				float2 MainTiling317 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 1.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 1.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult63 = (float2(_DistortPannerXYPowerXY.z , _DistortPannerXYPowerXY.w));
				float2 DistortPower356 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 2.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 2.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult60 = (float2(_DistortPannerXYPowerXY.x , _DistortPannerXYPowerXY.y));
				float2 uv_DistortTex = IN.ase_texcoord1.xy * _DistortTex_ST.xy + _DistortTex_ST.zw;
				float2 panner56 = ( 1.0 * _Time.y * appendResult60 + uv_DistortTex);
				float2 DistortTiling424 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 4.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 4.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortOffset388 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 3.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 3.0 * -1.0 ) ) ) ) ) ) );
				float2 DistortTerm87 = ( ( appendResult63 + DistortPower356 ) * tex2D( _DistortTex, ( ( panner56 * ( DistortTiling424 + 1.0 ) ) + DistortOffset388 ) ).r * 0.1 );
				float2 lerpResult518 = lerp( float2( 0,0 ) , DistortTerm87 , _MainUseDistort);
				float2 MainOffset260 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 0.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 0.0 * -1.0 ) ) ) ) ) ) );
				float4 tex2DNode13 = tex2D( _MainTex, ( ( panner205 * ( MainTiling317 + 1.0 ) ) + lerpResult518 + MainOffset260 ) );
				float lerpResult119 = lerp( tex2DNode13.a , tex2DNode13.r , _Alpha);
				float2 DissolveOffset461 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 5.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 5.0 * -1.0 ) ) ) ) ) ) );
				float2 DissolveTiling496 = ( ( Custom1XY184 * ( 1.0 - abs( sign( ( Custom1_XY_To254 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom1ZW187 * ( 1.0 - abs( sign( ( Custom1_ZW_To261 + ( 6.0 * -1.0 ) ) ) ) ) ) + ( Custom2XY193 * ( 1.0 - abs( sign( ( Custom2_XY_To262 + ( 6.0 * -1.0 ) ) ) ) ) ) );
				float2 appendResult99 = (float2(_DissolvePannerXY.x , _DissolvePannerXY.y));
				float2 uv_DissolveTex = IN.ase_texcoord1.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult172 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 ScreenpositionTerm177 = ( appendResult172 * 2.0 );
				float2 lerpResult180 = lerp( uv_DissolveTex , ScreenpositionTerm177 , _DissolveUV);
				float2 panner96 = ( 1.0 * _Time.y * appendResult99 + lerpResult180);
				float2 lerpResult92 = lerp( float2( 0,0 ) , DistortTerm87 , _DissolveUseDistort);
				float4 tex2DNode66 = tex2D( _DissolveTex, ( ( DissolveOffset461 + ( ( DissolveTiling496 + 1.0 ) * panner96 ) ) + lerpResult92 ) );
				float lerpResult214 = lerp( 0.0 , IN.ase_texcoord3.w , _UseCustom);
				float Custom2W196 = lerpResult214;
				float temp_output_197_0 = ( _Dissolveamount + Custom2W196 );
				float clampResult79 = clamp( step( tex2DNode66.r , temp_output_197_0 ) , 0.0 , 1.0 );
				float temp_output_71_0 = ( 1.0 - clampResult79 );
				float temp_output_515_0 = ( 1.0 - tex2DNode66.r );
				float clampResult78 = clamp( ( temp_output_515_0 + (-1.0 + (temp_output_197_0 - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) , 0.0 , 1.0 );
				float temp_output_76_0 = ( 1.0 - clampResult78 );
				float lerpResult81 = lerp( temp_output_71_0 , temp_output_76_0 , _Dissolve_Mode);
				float DissolveTerm85 = lerpResult81;
				
				surfaceDescription.Alpha = ( _Tint.a * IN.ase_color.a * lerpResult119 * DissolveTerm85 );
				surfaceDescription.AlphaClipThreshold = 0.5;
				
				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}

			ENDHLSL
        }
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.CommentaryNode;501;-9194.708,-2870.803;Inherit;False;512.7383;356.5713;커스텀 판별식;6;319;355;354;254;261;262;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-9142.708,-2818.637;Inherit;False;Property;_Custom1_XY;Custom1_XY;18;1;[Enum];Create;True;0;7;MainOffset;0;MainTiling;1;DistortPower;2;DistortOffset;3;DistortTiling;4;DissolveOffset;5;DissolveTiling;6;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;355;-9144.708,-2630.637;Inherit;False;Property;_Custom2_XY;Custom2_XY;20;1;[Enum];Create;True;0;7;MainOffset;0;MainTiling;1;DistortPower;2;DistortOffset;3;DistortTiling;4;DissolveOffset;5;DissolveTiling;6;0;True;0;False;2;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;392;-9159.959,176.7199;Inherit;False;1935.792;1263.738;Custom_DistortTiling;32;424;423;422;421;420;419;418;417;416;415;414;413;412;411;410;409;408;407;406;405;404;403;402;401;400;399;398;397;396;395;394;393;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;319;-9144.235,-2725.203;Inherit;False;Property;_Custom1_ZW;Custom1_ZW;19;1;[Enum];Create;True;0;7;MainOffset;0;MainTiling;1;DistortPower;2;DistortOffset;3;DistortTiling;4;DissolveOffset;5;DissolveTiling;6;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;254;-8912.97,-2820.803;Inherit;False;Custom1_XY_To;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;261;-8918.626,-2726.231;Inherit;False;Custom1_ZW_To;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;403;-9107.783,875.1375;Inherit;False;Constant;_Float14;Float 14;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-8916.626,-2630.231;Inherit;False;Custom2_XY_To;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;404;-9044.176,514.0274;Inherit;False;Constant;_Float13;Float 13;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;407;-9101.602,770.5083;Inherit;False;Constant;_Float12;Float 12;18;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;408;-9037.994,409.3977;Inherit;False;Constant;_Float11;Float 11;18;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;417;-9109.959,1324.458;Inherit;False;Constant;_Float10;Float 10;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-9103.777,1219.828;Inherit;False;Constant;_Float9;Float 9;18;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;206;-8662.98,-3415.107;Inherit;False;1503.416;896.4095;커스텀 선언;16;195;196;187;193;214;213;212;211;184;210;209;183;188;192;18;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;416;-8900.64,1224.599;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;397;-9107.918,316.574;Inherit;False;254;Custom1_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;357;-7190.412,-1157.585;Inherit;False;1935.792;1263.738;Custom_DistortOffset;32;389;388;387;386;385;384;383;382;381;380;379;378;377;376;375;374;373;372;371;370;369;368;367;366;365;364;363;362;361;360;359;358;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;18;-8570.807,-3261.222;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;-8898.462,775.2776;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;402;-9088.494,657.2036;Inherit;False;261;Custom1_ZW_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;423;-9090.67,1106.523;Inherit;False;262;Custom2_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;19;-8595.484,-3005.52;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;393;-8834.855,414.1685;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;188;-8273.886,-3143.643;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-8265.174,-2657.879;Inherit;False;Property;_UseCustom;UseCustom;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-7138.236,-459.1675;Inherit;False;Constant;_Float40;Float 40;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;394;-8688.732,322.0249;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;192;-8275.921,-2996.264;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;183;-8274.128,-3262.683;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-7068.448,-924.9073;Inherit;False;Constant;_Float43;Float 43;18;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;376;-7134.23,-114.4764;Inherit;False;Constant;_Float41;Float 41;18;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;415;-8752.517,1119.455;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;422;-8752.339,683.1348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;387;-7132.054,-563.7966;Inherit;False;Constant;_Float44;Float 44;18;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;321;-9162.796,-1157.44;Inherit;False;1935.792;1263.738;Custom_DistortPower;32;353;352;350;349;348;347;346;345;344;343;342;341;340;339;338;337;336;335;334;333;332;331;330;329;328;327;326;325;324;323;322;356;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-7074.628,-820.2774;Inherit;False;Constant;_Float39;Float 39;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-7140.412,-9.846437;Inherit;False;Constant;_Float42;Float 42;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;212;-7761.958,-3011.441;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;334;-9110.62,-459.0232;Inherit;False;Constant;_Float34;Float 34;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;378;-6931.092,-109.7054;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-9040.832,-924.763;Inherit;False;Constant;_Float37;Float 37;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;211;-7772.861,-3155.743;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;209;-7766.146,-3286.242;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;353;-9104.438,-563.6522;Inherit;False;Constant;_Float38;Float 38;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;340;-9106.614,-114.332;Inherit;False;Constant;_Float35;Float 35;18;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;-7121.123,-227.7814;Inherit;False;262;Custom2_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-6928.915,-559.0273;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;360;-6865.308,-920.1363;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;413;-8572.971,1113.776;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;395;-8524.188,321.346;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;341;-9112.796,-9.702036;Inherit;False;Constant;_Float36;Float 36;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;358;-7138.371,-1017.731;Inherit;False;254;Custom1_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;323;-9047.013,-820.1331;Inherit;False;Constant;_Float33;Float 33;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;421;-8587.794,682.4556;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;-7118.948,-677.1013;Inherit;False;261;Custom1_ZW_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;-7399.566,-3018.276;Inherit;False;Custom2XY;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;187;-7393.228,-3143.751;Inherit;False;Custom1ZW;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;380;-6782.969,-214.8494;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;-8903.477,-109.5611;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;-6719.184,-1012.28;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;412;-8331.746,1115.127;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;-7395.025,-3292.96;Inherit;False;Custom1XY;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;-9093.507,-227.6371;Inherit;False;262;Custom2_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;420;-8320.57,680.8066;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;333;-9091.332,-676.957;Inherit;False;261;Custom1_ZW_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;464;-9146.855,1493.004;Inherit;False;1935.792;1263.738;Custom_DissolveTiling;32;496;495;494;493;492;491;490;489;488;487;486;485;484;483;482;481;480;479;478;477;476;475;474;473;472;471;470;469;468;467;466;465;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;372;-6782.792,-651.1702;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-9110.755,-1017.587;Inherit;False;254;Custom1_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;-8901.299,-558.8831;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;396;-8312.117,317.5649;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;-8837.692,-919.992;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;381;-6603.423,-220.5284;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;398;-8125.473,226.7199;Inherit;False;184;Custom1XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;489;-9096.855,2640.741;Inherit;False;Constant;_Float21;Float 21;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;411;-8098.791,1111.32;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;480;-9024.891,1725.682;Inherit;False;Constant;_Float22;Float 22;18;0;Create;True;0;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;476;-9031.072,1830.312;Inherit;False;Constant;_Float23;Float 23;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;419;-8132.617,682.9998;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;362;-6554.64,-1012.959;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;475;-9094.68,2191.421;Inherit;False;Constant;_Float25;Float 25;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;336;-8755.176,-651.0259;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;410;-8110.701,1025.137;Inherit;False;193;Custom2XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-8755.354,-214.7051;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;400;-8145.991,596.1038;Inherit;False;187;Custom1ZW;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-9090.674,2536.111;Inherit;False;Constant;_Float24;Float 24;18;0;Create;True;0;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;325;-8691.568,-1012.136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;373;-6618.247,-651.8493;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;479;-9088.499,2086.792;Inherit;False;Constant;_Float26;Float 26;18;0;Create;True;0;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;405;-8124.164,319.758;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;382;-6362.2,-219.1774;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;429;-7185.123,173.9674;Inherit;False;1935.792;1263.738;Custom_DissolveOffset;32;461;460;459;458;457;456;455;454;453;452;451;450;449;448;447;446;445;444;443;442;441;440;439;438;437;436;435;434;433;432;431;430;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;478;-8885.359,2091.561;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;326;-8527.024,-1012.815;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;495;-9077.566,2422.806;Inherit;False;262;Custom2_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;474;-9075.391,1973.487;Inherit;False;261;Custom1_ZW_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;414;-7869.515,1087.468;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;-8887.537,2540.882;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;-7885.872,297.0209;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-7898.991,668.9026;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;-9094.814,1632.858;Inherit;False;254;Custom1_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;363;-6342.571,-1016.74;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;374;-6351.023,-653.4982;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;337;-8590.631,-651.705;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;345;-8575.808,-220.3841;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;465;-8821.753,1730.453;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;346;-8334.584,-219.0331;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;409;-7651.894,645.3816;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-6141.149,-309.1674;Inherit;False;193;Custom2XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;494;-8739.236,1999.419;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;89;-5190.495,-1538.218;Inherit;False;2541.989;780.2305;Distort Term;17;425;56;390;60;59;391;55;63;190;191;65;64;87;57;426;427;428;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-7132.947,872.3846;Inherit;False;Constant;_Float27;Float 27;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;365;-6155.922,-1107.585;Inherit;False;184;Custom1XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;441;-7069.34,511.2747;Inherit;False;Constant;_Float28;Float 28;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;383;-6129.241,-222.9845;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;364;-6154.613,-1014.547;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;455;-7128.941,1217.075;Inherit;False;Constant;_Float32;Float 32;18;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;338;-8323.407,-653.3539;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;444;-7126.766,767.7555;Inherit;False;Constant;_Float31;Float 31;18;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;466;-8675.629,1638.309;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;454;-7135.123,1321.705;Inherit;False;Constant;_Float30;Float 30;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;487;-8739.414,2435.738;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;375;-6163.066,-651.3052;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;-6176.441,-738.2012;Inherit;False;187;Custom1ZW;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;445;-7063.158,406.6451;Inherit;False;Constant;_Float29;Float 29;18;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;327;-8314.955,-1016.596;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;424;-7475.369,639.9215;Inherit;False;DistortTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;-8113.532,-309.0231;Inherit;False;193;Custom2XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-7113.658,654.4508;Inherit;False;261;Custom1_ZW_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;347;-8101.624,-222.8401;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;339;-8135.45,-651.1609;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;443;-6923.626,772.5248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;-5899.964,-246.8365;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;59;-5133.872,-1076.355;Inherit;False;Property;_DistortPannerXYPowerXY;DistortPannerXY/Power/XY;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0.4,0,0.25;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;329;-8128.307,-1107.44;Inherit;False;184;Custom1XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;430;-6860.02,411.4159;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;-7115.834,1103.77;Inherit;False;262;Custom2_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;-8148.825,-738.0569;Inherit;False;187;Custom1ZW;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;368;-5929.44,-665.4023;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SignOpNode;485;-8559.867,2430.059;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;366;-5916.323,-1037.284;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;453;-6925.804,1221.846;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;434;-7133.082,313.8215;Inherit;False;254;Custom1_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;328;-8126.997,-1014.403;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;178;-2624.038,-1533.176;Inherit;False;1035.401;310.6633;Screenposition;5;171;172;173;175;177;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SignOpNode;493;-8574.691,1998.74;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;467;-8511.086,1637.63;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-5070.568,-1321.326;Inherit;False;0;55;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;426;-4661.67,-1489.831;Inherit;False;424;DistortTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;332;-7901.823,-665.258;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;171;-2574.038,-1460.075;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;431;-6713.896,319.2724;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-4809.485,-1131.848;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;459;-6777.503,680.382;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;348;-7872.347,-246.6921;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;492;-8307.467,1997.09;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;484;-8318.643,2431.41;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;330;-7888.706,-1037.14;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;452;-6777.681,1116.702;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;385;-5682.343,-688.9233;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;468;-8299.014,1633.849;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;428;-4615.677,-1412.727;Inherit;False;Constant;_Float57;Float 57;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-2287.338,-1483.176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;472;-8132.888,1912.388;Inherit;False;187;Custom1ZW;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;350;-7654.727,-688.779;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;491;-8119.514,1999.284;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-2240.637,-1338.513;Inherit;False;Constant;_Float2;Float 2;16;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;427;-4423.901,-1455.199;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;482;-8097.597,2341.42;Inherit;False;193;Custom2XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;483;-8085.687,2427.603;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;432;-6549.353,318.5934;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;388;-5510.819,-638.3834;Inherit;False;DistortOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SignOpNode;450;-6598.135,1111.023;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;458;-6612.958,679.7028;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;477;-8111.061,1636.042;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;470;-8112.37,1543.004;Inherit;False;184;Custom1XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;56;-4632.78,-1322.182;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;286;-9196.86,-2496.156;Inherit;False;1935.792;1263.738;Custom_MainTiling;32;318;317;316;315;314;313;312;311;310;309;308;307;306;305;304;303;302;301;300;299;298;297;296;295;294;293;292;291;290;289;288;287;;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;433;-6337.281,314.8124;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;457;-6345.734,678.0536;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;425;-4316.135,-1318.427;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;449;-6356.91,1112.374;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;-2064.637,-1443.513;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;473;-7885.887,1985.187;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;391;-4605.354,-903.3447;Inherit;False;388;DistortOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;486;-7856.411,2403.751;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;-7483.202,-638.2391;Inherit;False;DistortPower;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;-7872.768,1613.305;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-9140.679,-1453.048;Inherit;False;Constant;_Float19;Float 19;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;308;-9146.86,-1348.418;Inherit;False;Constant;_Float20;Float 20;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;289;-9081.077,-2158.849;Inherit;False;Constant;_Float16;Float 16;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;300;-9138.503,-1902.368;Inherit;False;Constant;_Float17;Float 17;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;288;-9074.896,-2263.479;Inherit;False;Constant;_Float15;Float 15;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;301;-9144.685,-1797.739;Inherit;False;Constant;_Float18;Float 18;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;447;-6135.865,1022.384;Inherit;False;193;Custom2XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;481;-7638.79,1961.666;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-4105.577,-911.0865;Inherit;False;356;DistortPower;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;177;-1842.638,-1412.513;Inherit;False;ScreenpositionTerm;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;390;-4230.873,-1193.723;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;456;-6157.781,680.2469;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;90;-5191.25,-741.5341;Inherit;False;4383.109;1663.513;Dissolve Term;48;463;462;96;95;180;179;181;111;101;103;106;115;102;200;114;100;105;112;117;199;104;113;110;85;81;71;76;80;79;78;73;69;75;66;94;197;198;92;70;93;91;99;98;497;498;500;499;515;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;437;-6171.155,593.3511;Inherit;False;187;Custom1ZW;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;442;-6149.328,317.0054;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;435;-6150.637,223.9673;Inherit;False;184;Custom1XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;448;-6123.955,1108.567;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-4118.951,-1065.262;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;302;-8935.363,-1897.599;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;309;-8937.541,-1448.277;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;285;-7195.236,-2486.082;Inherit;False;1935.792;1263.738;Custom_Mainoffset;32;255;247;243;244;245;248;249;256;257;258;271;273;263;264;265;266;267;268;269;270;276;277;278;275;279;280;281;282;284;283;260;259;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;-9144.819,-2356.303;Inherit;False;254;Custom1_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;310;-9127.571,-1566.353;Inherit;False;262;Custom2_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;-8871.757,-2258.708;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;-9125.396,-2015.673;Inherit;False;261;Custom1_ZW_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;496;-7462.265,1954.205;Inherit;False;DissolveTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;438;-5924.155,666.1498;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-3734.619,-931.873;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-3961.162,-1332.952;Inherit;True;Property;_DistortTex;DistortTex;7;0;Create;True;0;0;0;False;0;False;-1;None;774bdf0220ed4484caec9bbc96075f6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;179;-5082.485,-321.5707;Inherit;False;Property;_DissolveUV;DissolveUV;10;1;[Enum];Create;True;0;2;UV;0;Screen;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;-5911.036,294.2684;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;191;-3907.953,-1063.58;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;95;-5134.749,-554.1498;Inherit;False;0;66;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;181;-5150.224,-424.951;Inherit;False;177;ScreenpositionTerm;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;451;-5894.679,1084.715;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;98;-5133.222,-169.1351;Inherit;False;Property;_DissolvePannerXY;DissolvePannerXY;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;291;-8725.633,-2350.852;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-7136.877,-1892.294;Inherit;False;Constant;_Float6;Float 6;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;311;-8789.418,-1553.421;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-7143.06,-1787.665;Inherit;False;Constant;_Float4;Float 4;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;276;-7139.054,-1442.974;Inherit;False;Constant;_Float7;Float 7;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;303;-8789.24,-1989.742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-7073.271,-2253.405;Inherit;False;Constant;_Float5;Float 5;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;243;-7079.453,-2148.775;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;277;-7145.236,-1338.344;Inherit;False;Constant;_Float8;Float 8;18;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;180;-4841.277,-468.89;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;500;-4722.771,-594.2617;Inherit;False;Constant;_Float70;Float 70;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;446;-5677.058,642.6288;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-3497.215,-1079.581;Inherit;True;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;498;-4768.918,-678.6927;Inherit;False;496;DissolveTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;-4879.944,-140.078;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-7123.771,-2005.599;Inherit;False;261;Custom1_ZW_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;304;-8624.695,-1990.421;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;-6933.739,-1887.524;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;312;-8609.872,-1559.1;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;244;-6870.133,-2248.634;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-7143.194,-2346.229;Inherit;False;254;Custom1_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;-6935.916,-1438.203;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-7125.947,-1556.279;Inherit;False;262;Custom2_XY_To;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;292;-8561.089,-2351.531;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-3121.37,-1215.467;Inherit;True;DistortTerm;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;461;-5500.533,635.1686;Inherit;False;DissolveOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;96;-4639.014,-327.7631;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;499;-4572.771,-631.2617;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;293;-8349.02,-2355.312;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;214;-7763.756,-2691.642;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;279;-6787.793,-1543.347;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-6724.008,-2340.778;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;267;-6787.616,-1979.668;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;313;-8368.648,-1557.749;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;305;-8357.472,-1992.07;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;463;-4372.47,-634.7343;Inherit;False;461;DissolveOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-4951.167,89.034;Inherit;False;87;DistortTerm;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;497;-4364.895,-470.47;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-4967.468,228.0964;Inherit;False;Property;_DissolveUseDistort;DissolveUseDistort;13;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;-8182.897,-2076.773;Inherit;False;187;Custom1ZW;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;306;-8169.521,-1989.877;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;248;-6559.464,-2341.457;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-8147.603,-1647.739;Inherit;False;193;Custom2XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SignOpNode;268;-6623.07,-1980.347;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;295;-8162.379,-2446.156;Inherit;False;184;Custom1XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-7401.566,-2716.275;Inherit;False;Custom2W;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;314;-8135.696,-1561.556;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;280;-6608.247,-1549.026;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;294;-8161.069,-2353.119;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;462;-4094.1,-519.7216;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;92;-4669.139,65.67363;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;269;-6355.847,-1981.996;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;315;-7883.795,-1580.883;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;281;-6367.024,-1547.675;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;249;-6347.396,-2345.238;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;296;-7922.778,-2375.856;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-7935.895,-2003.974;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-3867.644,-64.57197;Inherit;False;196;Custom2W;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-3923.647,-215.1054;Inherit;False;Property;_Dissolveamount;Dissolveamount;12;0;Create;True;0;0;0;False;0;False;0;0.125;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-3851.024,-365.9623;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-6160.755,-2436.082;Inherit;False;184;Custom1XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;318;-7688.797,-2027.495;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;197;-3593.078,-212.5683;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-6181.274,-2066.699;Inherit;False;187;Custom1ZW;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;256;-6159.446,-2343.045;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;282;-6134.074,-1551.482;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-6145.979,-1637.665;Inherit;False;193;Custom2XY;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;270;-6167.897,-1979.803;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;66;-3708.987,-528.4453;Inherit;True;Property;_DissolveTex;DissolveTex;11;0;Create;True;0;0;0;False;0;False;-1;None;0302a63c3d0414e44b3846273e1c5c1a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;-5882.171,-1570.809;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;-7485.068,-2034.564;Inherit;False;MainTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-5934.269,-1993.9;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;258;-5921.153,-2365.782;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;207;-5193.3,-2489.158;Inherit;False;3592.735;924.4105;MainTerm;33;20;201;203;26;205;202;88;204;186;61;13;118;14;119;17;86;15;16;109;108;107;5;2;8;6;3;7;1;4;9;10;517;518;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;75;-3424,272;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;515;-3392,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-4877.265,-1831.043;Inherit;False;317;MainTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;259;-5687.174,-2017.421;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;203;-4829.924,-1682.302;Inherit;False;Constant;_Float3;Float 3;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;69;-3283.78,-508.7602;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-5071.3,-2377.67;Inherit;False;0;13;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;26;-5095.102,-2100.718;Inherit;False;Property;_MainTexPannerXY;MainTex Panner X/Y;6;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-3200,224;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;205;-4732.865,-2100.968;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;-5483.443,-2024.49;Inherit;False;MainOffset;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-4667.924,-1764.302;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;79;-2993.836,-531.0419;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;78;-2912.397,246.7263;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-4480,-2272;Inherit;False;87;DistortTerm;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;517;-4464,-2160;Inherit;False;Property;_MainUseDistort;MainUseDistort;5;1;[Toggle];Create;True;0;1;Option1;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;76;-2683.015,162.8406;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-4416.925,-1929.303;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;71;-2770.976,-529.3574;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2487.32,-92.57606;Inherit;False;Property;_Dissolve_Mode;Dissolve_Mode;9;1;[Enum];Create;True;0;2;Step;0;Smooth;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-4400,-1680;Inherit;False;260;MainOffset;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;518;-4160,-2208;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;81;-2076.718,-141.6532;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-3904,-1792;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-3424.109,-1715.495;Inherit;False;Property;_Alpha;Alpha;3;1;[Enum];Create;True;0;2;Use Alpha;0;Use R;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-1791.706,-316.5883;Inherit;False;DissolveTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-3564.462,-1946.799;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;0;False;0;False;-1;None;cbf663b33e410604e96c1dc6e26a6ba6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;119;-3091.411,-1828.369;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-2768.463,-1680.747;Inherit;False;85;DissolveTerm;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-3478.638,-2369.04;Inherit;False;Property;_Tint;Tint;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;23.96863,23.96863,23.96863,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.VertexColorNode;14;-3509.03,-2165.909;Inherit;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;513;-2533.443,-1150.207;Inherit;False;Property;_Blend_Mode;Blend_Mode;1;1;[Enum];Create;True;0;2;Additive;1;Blended;10;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;103;-2735.453,-185.1654;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;104;-3189.757,-138.5682;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;110;-3311.135,579.6489;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-3661.695,216.5535;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-7399.566,-2899.276;Inherit;False;Custom2Z;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;-3067.484,503.4518;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;112;-2824.321,537.2593;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;213;-7759.159,-2870.642;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-3508.226,531.7818;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-2387.683,-525.727;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-2887.323,-2025.77;Inherit;False;106;BrightnessTerm;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-3899.774,241.2087;Inherit;False;195;Custom2Z;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;109;-2880.964,-2235.672;Inherit;False;Property;_BrightnessColor;BrightnessColor;16;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.5019608,0.5019608,0.5019608,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-2473.9,-1866.502;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;514;-2527.174,-1028.442;Inherit;False;Property;_Cull_Mode;Cull_Mode;2;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-3370.019,-196.7386;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2802.128,-2364.733;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;107;-2505.932,-2263.747;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-3951.906,112.9314;Inherit;False;Property;_Brightnessamount;Brightnessamount;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;117;-1673.188,154.0701;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-1338.662,133.3499;Inherit;True;BrightnessTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;102;-2921.913,-128.349;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;113;-2594.939,453.3737;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;115;-2304,304;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;-2577.984,-2042.12;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;-1990.18,-2116.74;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;J_FX_01;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;2;True;_Cull_Mode;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;PreviewType=Plane;True;5;True;12;all;0;True;True;2;5;False;;10;True;_Blend_Mode;2;5;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;638395320235613455;  Blend;0;0;Two Sided;0;638395320585905634;Cast Shadows;0;638395320406996014;  Use Shadow Threshold;0;0;Receive Shadows;0;638395320660810389;GPU Instancing;1;0;LOD CrossFade;0;638397160442504318;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;10;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;5;d3d11;glcore;gles;gles3;ps5;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;True;2;5;False;;10;True;_Blend_Mode;2;5;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;3;False;;True;False;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;5;d3d11;glcore;gles;gles3;ps5;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;5;d3d11;glcore;gles;gles3;ps5;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;254;0;354;0
WireConnection;261;0;319;0
WireConnection;262;0;355;0
WireConnection;416;0;418;0
WireConnection;416;1;417;0
WireConnection;406;0;407;0
WireConnection;406;1;403;0
WireConnection;393;0;408;0
WireConnection;393;1;404;0
WireConnection;188;0;18;3
WireConnection;188;1;18;4
WireConnection;394;0;397;0
WireConnection;394;1;393;0
WireConnection;192;0;19;1
WireConnection;192;1;19;2
WireConnection;183;0;18;1
WireConnection;183;1;18;2
WireConnection;415;0;423;0
WireConnection;415;1;416;0
WireConnection;422;0;402;0
WireConnection;422;1;406;0
WireConnection;212;1;192;0
WireConnection;212;2;210;0
WireConnection;378;0;376;0
WireConnection;378;1;377;0
WireConnection;211;1;188;0
WireConnection;211;2;210;0
WireConnection;209;1;183;0
WireConnection;209;2;210;0
WireConnection;371;0;387;0
WireConnection;371;1;370;0
WireConnection;360;0;386;0
WireConnection;360;1;359;0
WireConnection;413;0;415;0
WireConnection;395;0;394;0
WireConnection;421;0;422;0
WireConnection;193;0;212;0
WireConnection;187;0;211;0
WireConnection;380;0;379;0
WireConnection;380;1;378;0
WireConnection;342;0;340;0
WireConnection;342;1;341;0
WireConnection;361;0;358;0
WireConnection;361;1;360;0
WireConnection;412;0;413;0
WireConnection;184;0;209;0
WireConnection;420;0;421;0
WireConnection;372;0;369;0
WireConnection;372;1;371;0
WireConnection;335;0;353;0
WireConnection;335;1;334;0
WireConnection;396;0;395;0
WireConnection;324;0;352;0
WireConnection;324;1;323;0
WireConnection;381;0;380;0
WireConnection;411;0;412;0
WireConnection;419;0;420;0
WireConnection;362;0;361;0
WireConnection;336;0;333;0
WireConnection;336;1;335;0
WireConnection;344;0;343;0
WireConnection;344;1;342;0
WireConnection;325;0;322;0
WireConnection;325;1;324;0
WireConnection;373;0;372;0
WireConnection;405;0;396;0
WireConnection;382;0;381;0
WireConnection;478;0;479;0
WireConnection;478;1;475;0
WireConnection;326;0;325;0
WireConnection;414;0;410;0
WireConnection;414;1;411;0
WireConnection;488;0;490;0
WireConnection;488;1;489;0
WireConnection;399;0;398;0
WireConnection;399;1;405;0
WireConnection;401;0;400;0
WireConnection;401;1;419;0
WireConnection;363;0;362;0
WireConnection;374;0;373;0
WireConnection;337;0;336;0
WireConnection;345;0;344;0
WireConnection;465;0;480;0
WireConnection;465;1;476;0
WireConnection;346;0;345;0
WireConnection;409;0;399;0
WireConnection;409;1;401;0
WireConnection;409;2;414;0
WireConnection;494;0;474;0
WireConnection;494;1;478;0
WireConnection;383;0;382;0
WireConnection;364;0;363;0
WireConnection;338;0;337;0
WireConnection;466;0;469;0
WireConnection;466;1;465;0
WireConnection;487;0;495;0
WireConnection;487;1;488;0
WireConnection;375;0;374;0
WireConnection;327;0;326;0
WireConnection;424;0;409;0
WireConnection;347;0;346;0
WireConnection;339;0;338;0
WireConnection;443;0;444;0
WireConnection;443;1;440;0
WireConnection;389;0;384;0
WireConnection;389;1;383;0
WireConnection;430;0;445;0
WireConnection;430;1;441;0
WireConnection;368;0;367;0
WireConnection;368;1;375;0
WireConnection;485;0;487;0
WireConnection;366;0;365;0
WireConnection;366;1;364;0
WireConnection;453;0;455;0
WireConnection;453;1;454;0
WireConnection;328;0;327;0
WireConnection;493;0;494;0
WireConnection;467;0;466;0
WireConnection;332;0;331;0
WireConnection;332;1;339;0
WireConnection;431;0;434;0
WireConnection;431;1;430;0
WireConnection;60;0;59;1
WireConnection;60;1;59;2
WireConnection;459;0;439;0
WireConnection;459;1;443;0
WireConnection;348;0;349;0
WireConnection;348;1;347;0
WireConnection;492;0;493;0
WireConnection;484;0;485;0
WireConnection;330;0;329;0
WireConnection;330;1;328;0
WireConnection;452;0;460;0
WireConnection;452;1;453;0
WireConnection;385;0;366;0
WireConnection;385;1;368;0
WireConnection;385;2;389;0
WireConnection;468;0;467;0
WireConnection;172;0;171;1
WireConnection;172;1;171;2
WireConnection;350;0;330;0
WireConnection;350;1;332;0
WireConnection;350;2;348;0
WireConnection;491;0;492;0
WireConnection;427;0;426;0
WireConnection;427;1;428;0
WireConnection;483;0;484;0
WireConnection;432;0;431;0
WireConnection;388;0;385;0
WireConnection;450;0;452;0
WireConnection;458;0;459;0
WireConnection;477;0;468;0
WireConnection;56;0;57;0
WireConnection;56;2;60;0
WireConnection;433;0;432;0
WireConnection;457;0;458;0
WireConnection;425;0;56;0
WireConnection;425;1;427;0
WireConnection;449;0;450;0
WireConnection;173;0;172;0
WireConnection;173;1;175;0
WireConnection;473;0;472;0
WireConnection;473;1;491;0
WireConnection;486;0;482;0
WireConnection;486;1;483;0
WireConnection;356;0;350;0
WireConnection;471;0;470;0
WireConnection;471;1;477;0
WireConnection;481;0;471;0
WireConnection;481;1;473;0
WireConnection;481;2;486;0
WireConnection;177;0;173;0
WireConnection;390;0;425;0
WireConnection;390;1;391;0
WireConnection;456;0;457;0
WireConnection;442;0;433;0
WireConnection;448;0;449;0
WireConnection;63;0;59;3
WireConnection;63;1;59;4
WireConnection;302;0;300;0
WireConnection;302;1;301;0
WireConnection;309;0;307;0
WireConnection;309;1;308;0
WireConnection;290;0;288;0
WireConnection;290;1;289;0
WireConnection;496;0;481;0
WireConnection;438;0;437;0
WireConnection;438;1;456;0
WireConnection;55;1;390;0
WireConnection;436;0;435;0
WireConnection;436;1;442;0
WireConnection;191;0;63;0
WireConnection;191;1;190;0
WireConnection;451;0;447;0
WireConnection;451;1;448;0
WireConnection;291;0;287;0
WireConnection;291;1;290;0
WireConnection;311;0;310;0
WireConnection;311;1;309;0
WireConnection;303;0;299;0
WireConnection;303;1;302;0
WireConnection;180;0;95;0
WireConnection;180;1;181;0
WireConnection;180;2;179;0
WireConnection;446;0;436;0
WireConnection;446;1;438;0
WireConnection;446;2;451;0
WireConnection;64;0;191;0
WireConnection;64;1;55;1
WireConnection;64;2;65;0
WireConnection;99;0;98;1
WireConnection;99;1;98;2
WireConnection;304;0;303;0
WireConnection;266;0;264;0
WireConnection;266;1;265;0
WireConnection;312;0;311;0
WireConnection;244;0;247;0
WireConnection;244;1;243;0
WireConnection;278;0;276;0
WireConnection;278;1;277;0
WireConnection;292;0;291;0
WireConnection;87;0;64;0
WireConnection;461;0;446;0
WireConnection;96;0;180;0
WireConnection;96;2;99;0
WireConnection;499;0;498;0
WireConnection;499;1;500;0
WireConnection;293;0;292;0
WireConnection;214;1;19;4
WireConnection;214;2;210;0
WireConnection;279;0;275;0
WireConnection;279;1;278;0
WireConnection;245;0;255;0
WireConnection;245;1;244;0
WireConnection;267;0;263;0
WireConnection;267;1;266;0
WireConnection;313;0;312;0
WireConnection;305;0;304;0
WireConnection;497;0;499;0
WireConnection;497;1;96;0
WireConnection;306;0;305;0
WireConnection;248;0;245;0
WireConnection;268;0;267;0
WireConnection;196;0;214;0
WireConnection;314;0;313;0
WireConnection;280;0;279;0
WireConnection;294;0;293;0
WireConnection;462;0;463;0
WireConnection;462;1;497;0
WireConnection;92;1;93;0
WireConnection;92;2;91;0
WireConnection;269;0;268;0
WireConnection;315;0;316;0
WireConnection;315;1;314;0
WireConnection;281;0;280;0
WireConnection;249;0;248;0
WireConnection;296;0;295;0
WireConnection;296;1;294;0
WireConnection;298;0;297;0
WireConnection;298;1;306;0
WireConnection;94;0;462;0
WireConnection;94;1;92;0
WireConnection;318;0;296;0
WireConnection;318;1;298;0
WireConnection;318;2;315;0
WireConnection;197;0;70;0
WireConnection;197;1;198;0
WireConnection;256;0;249;0
WireConnection;282;0;281;0
WireConnection;270;0;269;0
WireConnection;66;1;94;0
WireConnection;284;0;283;0
WireConnection;284;1;282;0
WireConnection;317;0;318;0
WireConnection;273;0;271;0
WireConnection;273;1;270;0
WireConnection;258;0;257;0
WireConnection;258;1;256;0
WireConnection;75;0;197;0
WireConnection;515;0;66;1
WireConnection;259;0;258;0
WireConnection;259;1;273;0
WireConnection;259;2;284;0
WireConnection;69;0;66;1
WireConnection;69;1;197;0
WireConnection;73;0;515;0
WireConnection;73;1;75;0
WireConnection;205;0;20;0
WireConnection;205;2;26;0
WireConnection;260;0;259;0
WireConnection;202;0;201;0
WireConnection;202;1;203;0
WireConnection;79;0;69;0
WireConnection;78;0;73;0
WireConnection;76;0;78;0
WireConnection;204;0;205;0
WireConnection;204;1;202;0
WireConnection;71;0;79;0
WireConnection;518;1;88;0
WireConnection;518;2;517;0
WireConnection;81;0;71;0
WireConnection;81;1;76;0
WireConnection;81;2;80;0
WireConnection;61;0;204;0
WireConnection;61;1;518;0
WireConnection;61;2;186;0
WireConnection;85;0;81;0
WireConnection;13;1;61;0
WireConnection;119;0;13;4
WireConnection;119;1;13;1
WireConnection;119;2;118;0
WireConnection;103;0;102;0
WireConnection;104;0;66;1
WireConnection;104;1;100;0
WireConnection;110;0;114;0
WireConnection;200;0;101;0
WireConnection;200;1;199;0
WireConnection;195;0;213;0
WireConnection;111;0;515;0
WireConnection;111;1;110;0
WireConnection;112;0;111;0
WireConnection;213;1;19;3
WireConnection;213;2;210;0
WireConnection;114;0;200;0
WireConnection;114;1;197;0
WireConnection;105;0;71;0
WireConnection;105;1;103;0
WireConnection;15;0;17;4
WireConnection;15;1;14;4
WireConnection;15;2;119;0
WireConnection;15;3;86;0
WireConnection;100;0;197;0
WireConnection;100;1;200;0
WireConnection;16;0;17;0
WireConnection;16;1;14;0
WireConnection;16;2;13;0
WireConnection;107;0;16;0
WireConnection;107;1;109;0
WireConnection;107;2;108;0
WireConnection;117;0;105;0
WireConnection;117;1;115;0
WireConnection;117;2;80;0
WireConnection;106;0;117;0
WireConnection;102;0;104;0
WireConnection;113;0;112;0
WireConnection;115;0;76;0
WireConnection;115;1;113;0
WireConnection;2;2;107;0
WireConnection;2;3;15;0
ASEEND*/
//CHKSM=C17C3630DDF4FB460752EA56F94024A36F3F7F40