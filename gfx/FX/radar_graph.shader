Includes = {
	"buttonstate.fxh"
	"sprite_animation.fxh"
}

PixelShader =
{
	Samplers =
	{
		MapTexture =
		{
			Index = 0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
			MipMapLodBias = -0.8
		}
		MaskingTexture =
		{
			Index = 5
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "None"
			AddressU = "Clamp"
			AddressV = "Clamp"
		}
	}
}


VertexStruct VS_OUTPUT
{
	float4  vPosition : PDX_POSITION;
	float2  vTexCoord : TEXCOORD0;
@ifdef MASKING
	float2  vMaskingTexCoord : TEXCOORD2;
@endif
};


VertexShader =
{
	MainCode VertexShader
	[[
		VS_OUTPUT main(const VS_INPUT v )
		{
		    VS_OUTPUT Out;
		    Out.vPosition  = mul( WorldViewProjectionMatrix, float4( v.vPosition.xyz, 1 ) );
		    Out.vTexCoord = v.vTexCoord;
			// Out.vTexCoord += Offset;
		
		    return Out;
		}
	]]
}

PixelShader =
{
	MainCode PixelShaderUp
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 FilledColor = tex2D( MapTexture, v.vTexCoord );
		    float4 EmptyColor = tex2D( MaskingTexture, v.vTexCoord );

			float x = 2 * v.vTexCoord.x - 1;
			float y = 2 * v.vTexCoord.y - 1;
			y *= -1;

			float pi = 3.141592654;

			float angles[5] = {
				2*pi*0/5,
				2*pi*1/5,
				2*pi*2/5,
				2*pi*3/5,
				2*pi*4/5
			};

			float scale[5] = {
				1.0, 0.5, 1.0, 1.0, 1.0
			};

			float2 coords[5] = {
				float2(scale[0]*sin(angles[0]),scale[0]*cos(angles[0])),
				float2(scale[1]*sin(angles[1]),scale[1]*cos(angles[1])),
				float2(scale[2]*sin(angles[2]),scale[2]*cos(angles[2])),
				float2(scale[3]*sin(angles[3]),scale[3]*cos(angles[3])),
				float2(scale[4]*sin(angles[4]),scale[4]*cos(angles[4])),
			};
			
			// line function
			float line_m[5] = {
				(coords[1].y-coords[0].y) / (coords[1].x-coords[0].x),
				(coords[2].y-coords[1].y) / (coords[2].x-coords[1].x),
				(coords[3].y-coords[2].y) / (coords[3].x-coords[2].x),
				(coords[4].y-coords[3].y) / (coords[4].x-coords[3].x),
				(coords[0].y-coords[4].y) / (coords[0].x-coords[4].x)
			};
			float line_b[5] = {
				coords[0].y-line_m[0]*coords[0].x,
				coords[1].y-line_m[1]*coords[1].x,
				coords[2].y-line_m[2]*coords[2].x,
				coords[3].y-line_m[3]*coords[3].x,
				coords[4].y-line_m[4]*coords[4].x
			};

			// function itself
			float line_f[5] = {
				line_m[0]*x + line_b[0],
				line_m[1]*x + line_b[1],
				line_m[2]*x + line_b[2],
				line_m[3]*x + line_b[3],
				line_m[4]*x + line_b[4]
			};

			// checks if region is inside the polygon by checking how many times it has crossed the boundaries
			bool insidePoly = false;
			for (int i = 0; i < 5; i++) {
				int j = (i + 1) % 5;
				float2 a = coords[i];
				float2 b = coords[j];

				bool straddles = (a.y > y) != (b.y > y);
				float intersectX = (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x;
				if (straddles && x < intersectX) {
					insidePoly = !insidePoly;
				}
			}

			if (insidePoly) {
				return FilledColor;
			}
			return EmptyColor;
		}
	]]

	MainCode PixelShaderDown
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
			
			OutColor *= Color;

			float vTime = 0.9 - saturate( (Time - AnimationTime) * 16 );
			vTime *= vTime;
			vTime = 0.9*0.9 - vTime;
		    float4 MixColor = float4( 0.15, 0.15, 0.15, 0 ) * vTime;
		    OutColor.rgb -= ( 0.5 + OutColor.rgb ) * MixColor.rgb;

			return OutColor;
		}
	]]

	MainCode PixelShaderDisable
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );
		    float Grey = dot( OutColor.rgb, float3( 0.212671f, 0.715160f, 0.072169f ) ); 
		    OutColor.rgb = float3(Grey, Grey, Grey);

			OutColor *= Color;
		    return OutColor;
		}	
	]]

	MainCode PixelShaderOver
	[[
		float4 main( VS_OUTPUT v ) : PDX_COLOR
		{
		    float4 OutColor = tex2D( MapTexture, v.vTexCoord );

			OutColor *= Color;
			
			float vTime = 0.9 - saturate( (Time - AnimationTime) * 4 );
			vTime *= vTime;
			vTime = 0.9*0.9 - vTime;
		    float4 MixColor = float4( 0.15, 0.15, 0.15, 0 ) * vTime;
		    OutColor.rgb += ( 0.5 + OutColor.rgb ) * MixColor.rgb;
			
			return OutColor;
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
}


Effect Up
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderUp"
}

Effect Down
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderDown"
}

Effect Disable
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderDisable"
}

Effect Over
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderOver"
}

