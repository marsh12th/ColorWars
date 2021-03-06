Shader "Custom/Sprite"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent+1" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref 1
			Comp  Always
			Pass  Replace
		}

		Cull Off
		Lighting On
		ZWrite Off
		ZTest Always

		Blend One OneMinusSrcAlpha, Zero OneMinusSrcAlpha
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
			
		fixed4 _Color;

		v2f vert(appdata_t IN)
		{
			v2f OUT;
			UNITY_SETUP_INSTANCE_ID(IN);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
			OUT.vertex = UnityObjectToClipPos(IN.vertex);
			OUT.texcoord = IN.texcoord;
			OUT.color = IN.color * _Color;
			#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap (OUT.vertex);
			#endif

			return OUT;
		}

		sampler2D _MainTex;

		fixed4 frag(v2f IN) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, IN.texcoord) * IN.color;
			c.rgb *= c.a;
			if ( c.a < 0.5f ) discard;
			return c;
		}
		ENDCG
		}
	}
}
