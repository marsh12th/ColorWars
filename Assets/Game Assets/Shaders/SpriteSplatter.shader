Shader "Custom/Sprite splatter"
{
	Properties
	{
		[PerRendererData] _MainTex ("Splatter Texture", 2D) = "white" {}
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent+2" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting On
		ZWrite Off
		ZTest Always

		Stencil
		{
			Ref 1
			Comp Equal
		}

		Blend Zero One, One Zero
		Pass 
		{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0
		#pragma multi_compile _ PIXELSNAP_ON
		#include "UnityCG.cginc"
			
		struct appdata_t
		{
			float4 vertex   : POSITION;
			float4 color    : COLOR;
			float2 texcoord : TEXCOORD0;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct v2f
		{
			float4 vertex   : SV_POSITION;
			fixed4 color    : COLOR;
			float2 texcoord  : TEXCOORD0;
			UNITY_VERTEX_OUTPUT_STEREO
		};

		v2f vert(appdata_t IN)
		{
			v2f OUT;
			UNITY_SETUP_INSTANCE_ID(IN);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
			OUT.vertex = UnityObjectToClipPos(IN.vertex);
			OUT.texcoord = IN.texcoord;
			#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap (OUT.vertex);
			#endif

			return OUT;
		}

		sampler2D _MainTex;
		fixed4 frag(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord);
			c.rgb *= c.a;
			return c;
		}
		ENDCG
		}
	}
}
