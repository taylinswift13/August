Shader "CloudShader_03"
{
    Properties
    {
        Vector4_A345448D("RotateProjection", Vector) = (1, 0, 0, 0)
        Vector1_56B5804B("NoiseScale", Float) = 10
        Vector1_B542C30("CloudSpeed", Float) = 0.1
        Vector1_11F7BA6B("CloudHeight", Float) = 1
        Vector1_7464FCA1("Occlusion", Float) = 1
        Vector1_996A2909("Smoothness", Float) = 0.5
        Vector1_9145DEE5("Metallic", Float) = 0
        Vector4_1528E80F("Vector4", Vector) = (0, 1, -1, 1)
        Color_249D68A("ColorValleys", Color) = (0, 0, 0, 0)
        Color_C16EB892("ColorPeaks", Color) = (1, 1, 1, 0)
        Vector1_2A3DF01D("SmoothEdge1", Float) = 0
        Vector1_9A231072("SmoothEdge2", Float) = 1
        Vector1_60F4B7B("NoisePower", Float) = 1
        Vector1_2A033F34("BaseScale", Float) = 5
        Vector1_DBC9DB06("BaseSpeed", Float) = 1
        Vector1_C38F0170("BaseStrength", Float) = 1
        Vector1_C8CFAFD6("EmissionStrength", Float) = 1
        Vector1_63892271("CurvatureRadius", Float) = 1
        Vector1_ED5F6A07("FresnelPower", Float) = 1
        Vector1_32ED954F("FresnelOpacity", Float) = 1
        Vector1_81FB2EA8("FadeDepth", Float) = 1
    }
    SubShader
    {
        Tags
    {
        "RenderPipeline"="UniversalPipeline"
        "RenderType"="Transparent"
        "Queue"="Transparent+0"
    }

        Pass
    {
        Name "Universal Forward"
        Tags 
        { 
            "LightMode" = "UniversalForward"
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Back
        ZTest LEqual
        //ZWrite Off
		ZWrite On
        // ColorMask: <None>
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0
    #pragma multi_compile_fog
    #pragma multi_compile_instancing

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS 
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_FORWARD
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A345448D;
    float Vector1_56B5804B;
    float Vector1_B542C30;
    float Vector1_11F7BA6B;
    float Vector1_7464FCA1;
    float Vector1_996A2909;
    float Vector1_9145DEE5;
    float4 Vector4_1528E80F;
    float4 Color_249D68A;
    float4 Color_C16EB892;
    float Vector1_2A3DF01D;
    float Vector1_9A231072;
    float Vector1_60F4B7B;
    float Vector1_2A033F34;
    float Vector1_DBC9DB06;
    float Vector1_C38F0170;
    float Vector1_C8CFAFD6;
    float Vector1_63892271;
    float Vector1_ED5F6A07;
    float Vector1_32ED954F;
    float Vector1_81FB2EA8;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
    {
        Out = lerp(A, B, T);
    }

    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
    {
        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
    }

    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
    {
        Out = A + B;
    }

    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
    {
        Out = A * B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_28BCC07D_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_28BCC07D_Out_2);
        float _Property_6A4549FD_Out_0 = Vector1_63892271;
        float _Divide_8CF523BA_Out_2;
        Unity_Divide_float(_Distance_28BCC07D_Out_2, _Property_6A4549FD_Out_0, _Divide_8CF523BA_Out_2);
        float _Power_A3B4AA8D_Out_2;
        Unity_Power_float(_Divide_8CF523BA_Out_2, 3, _Power_A3B4AA8D_Out_2);
        float3 _Multiply_777A8A0B_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_A3B4AA8D_Out_2.xxx), _Multiply_777A8A0B_Out_2);
        float _Property_6B683C43_Out_0 = Vector1_11F7BA6B;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float3 _Multiply_62EA87EF_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_4CA2CE54_Out_2.xxx), _Multiply_62EA87EF_Out_2);
        float3 _Multiply_2A8170AA_Out_2;
        Unity_Multiply_float((_Property_6B683C43_Out_0.xxx), _Multiply_62EA87EF_Out_2, _Multiply_2A8170AA_Out_2);
        float3 _Add_CD3CAA11_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2A8170AA_Out_2, _Add_CD3CAA11_Out_2);
        float3 _Add_2ADF590F_Out_2;
        Unity_Add_float3(_Multiply_777A8A0B_Out_2, _Add_CD3CAA11_Out_2, _Add_2ADF590F_Out_2);
        description.VertexPosition = _Add_2ADF590F_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 WorldSpaceNormal;
        float3 TangentSpaceNormal;
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };

    struct SurfaceDescription
    {
        float3 Albedo;
        float3 Normal;
        float3 Emission;
        float Metallic;
        float Smoothness;
        float Occlusion;
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float4 _Property_2C69A20E_Out_0 = Color_249D68A;
        float4 _Property_EACCF9B1_Out_0 = Color_C16EB892;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float4 _Lerp_7F124CFD_Out_3;
        Unity_Lerp_float4(_Property_2C69A20E_Out_0, _Property_EACCF9B1_Out_0, (_Divide_4CA2CE54_Out_2.xxxx), _Lerp_7F124CFD_Out_3);
        float _Property_75195C1A_Out_0 = Vector1_ED5F6A07;
        float _FresnelEffect_5996F356_Out_3;
        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_75195C1A_Out_0, _FresnelEffect_5996F356_Out_3);
        float _Multiply_3EEB98A2_Out_2;
        Unity_Multiply_float(_Divide_4CA2CE54_Out_2, _FresnelEffect_5996F356_Out_3, _Multiply_3EEB98A2_Out_2);
        float _Property_4AD968A2_Out_0 = Vector1_32ED954F;
        float _Multiply_5BFBA9E6_Out_2;
        Unity_Multiply_float(_Multiply_3EEB98A2_Out_2, _Property_4AD968A2_Out_0, _Multiply_5BFBA9E6_Out_2);
        float4 _Add_592D41D1_Out_2;
        Unity_Add_float4(_Lerp_7F124CFD_Out_3, (_Multiply_5BFBA9E6_Out_2.xxxx), _Add_592D41D1_Out_2);
        float _Property_3F343659_Out_0 = Vector1_C8CFAFD6;
        float4 _Multiply_CD58101E_Out_2;
        Unity_Multiply_float(_Add_592D41D1_Out_2, (_Property_3F343659_Out_0.xxxx), _Multiply_CD58101E_Out_2);
        float _Property_2C40B89E_Out_0 = Vector1_9145DEE5;
        float _Property_4F35533D_Out_0 = Vector1_996A2909;
        float _Property_5375C6F9_Out_0 = Vector1_7464FCA1;
        float _SceneDepth_68903870_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_68903870_Out_1);
        float4 _ScreenPosition_7D471D5C_Out_0 = IN.ScreenPosition;
        float _Split_C57194B5_R_1 = _ScreenPosition_7D471D5C_Out_0[0];
        float _Split_C57194B5_G_2 = _ScreenPosition_7D471D5C_Out_0[1];
        float _Split_C57194B5_B_3 = _ScreenPosition_7D471D5C_Out_0[2];
        float _Split_C57194B5_A_4 = _ScreenPosition_7D471D5C_Out_0[3];
        float _Subtract_AA101019_Out_2;
        Unity_Subtract_float(_Split_C57194B5_A_4, 1, _Subtract_AA101019_Out_2);
        float _Subtract_283E4E77_Out_2;
        Unity_Subtract_float(_SceneDepth_68903870_Out_1, _Subtract_AA101019_Out_2, _Subtract_283E4E77_Out_2);
        float _Property_89CAF578_Out_0 = Vector1_81FB2EA8;
        float _Divide_4532EF3D_Out_2;
        Unity_Divide_float(_Subtract_283E4E77_Out_2, _Property_89CAF578_Out_0, _Divide_4532EF3D_Out_2);
        float _Saturate_E482199_Out_1;
        Unity_Saturate_float(_Divide_4532EF3D_Out_2, _Saturate_E482199_Out_1);
        float _Smoothstep_643FC2C2_Out_3;
        Unity_Smoothstep_float(0, 1, _Saturate_E482199_Out_1, _Smoothstep_643FC2C2_Out_3);
        surface.Albedo = (_Add_592D41D1_Out_2.xyz);
        surface.Normal = IN.TangentSpaceNormal;
        surface.Emission = (_Multiply_CD58101E_Out_2.xyz);
        surface.Metallic = _Property_2C40B89E_Out_0;
        surface.Smoothness = _Property_4F35533D_Out_0;
        surface.Occlusion = _Property_5375C6F9_Out_0;
        surface.Alpha = _Smoothstep_643FC2C2_Out_3;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float4 tangentWS;
                float3 viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                float2 lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                float3 sh;
                #endif
                float4 fogFactorAndVertexLight;
                float4 shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if defined(LIGHTMAP_ON)
                #endif
                #if !defined(LIGHTMAP_ON)
                #endif
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float3 interp03 : TEXCOORD3;
                float2 interp04 : TEXCOORD4;
                float3 interp05 : TEXCOORD5;
                float4 interp06 : TEXCOORD6;
                float4 interp07 : TEXCOORD7;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyz = input.normalWS;
                output.interp02.xyzw = input.tangentWS;
                output.interp03.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp04.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp05.xyz = input.sh;
                #endif
                output.interp06.xyzw = input.fogFactorAndVertexLight;
                output.interp07.xyzw = input.shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.normalWS = input.interp01.xyz;
                output.tangentWS = input.interp02.xyzw;
                output.viewDirectionWS = input.interp03.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp04.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp05.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp06.xyzw;
                output.shadowCoord = input.interp07.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    	float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


        output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

        ENDHLSL
    }

        Pass
    {
        Name "ShadowCaster"
        Tags 
        { 
            "LightMode" = "ShadowCaster"
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0
    #pragma multi_compile_instancing

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS 
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_SHADOWCASTER
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A345448D;
    float Vector1_56B5804B;
    float Vector1_B542C30;
    float Vector1_11F7BA6B;
    float Vector1_7464FCA1;
    float Vector1_996A2909;
    float Vector1_9145DEE5;
    float4 Vector4_1528E80F;
    float4 Color_249D68A;
    float4 Color_C16EB892;
    float Vector1_2A3DF01D;
    float Vector1_9A231072;
    float Vector1_60F4B7B;
    float Vector1_2A033F34;
    float Vector1_DBC9DB06;
    float Vector1_C38F0170;
    float Vector1_C8CFAFD6;
    float Vector1_63892271;
    float Vector1_ED5F6A07;
    float Vector1_32ED954F;
    float Vector1_81FB2EA8;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_28BCC07D_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_28BCC07D_Out_2);
        float _Property_6A4549FD_Out_0 = Vector1_63892271;
        float _Divide_8CF523BA_Out_2;
        Unity_Divide_float(_Distance_28BCC07D_Out_2, _Property_6A4549FD_Out_0, _Divide_8CF523BA_Out_2);
        float _Power_A3B4AA8D_Out_2;
        Unity_Power_float(_Divide_8CF523BA_Out_2, 3, _Power_A3B4AA8D_Out_2);
        float3 _Multiply_777A8A0B_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_A3B4AA8D_Out_2.xxx), _Multiply_777A8A0B_Out_2);
        float _Property_6B683C43_Out_0 = Vector1_11F7BA6B;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float3 _Multiply_62EA87EF_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_4CA2CE54_Out_2.xxx), _Multiply_62EA87EF_Out_2);
        float3 _Multiply_2A8170AA_Out_2;
        Unity_Multiply_float((_Property_6B683C43_Out_0.xxx), _Multiply_62EA87EF_Out_2, _Multiply_2A8170AA_Out_2);
        float3 _Add_CD3CAA11_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2A8170AA_Out_2, _Add_CD3CAA11_Out_2);
        float3 _Add_2ADF590F_Out_2;
        Unity_Add_float3(_Multiply_777A8A0B_Out_2, _Add_CD3CAA11_Out_2, _Add_2ADF590F_Out_2);
        description.VertexPosition = _Add_2ADF590F_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };

    struct SurfaceDescription
    {
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float _SceneDepth_68903870_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_68903870_Out_1);
        float4 _ScreenPosition_7D471D5C_Out_0 = IN.ScreenPosition;
        float _Split_C57194B5_R_1 = _ScreenPosition_7D471D5C_Out_0[0];
        float _Split_C57194B5_G_2 = _ScreenPosition_7D471D5C_Out_0[1];
        float _Split_C57194B5_B_3 = _ScreenPosition_7D471D5C_Out_0[2];
        float _Split_C57194B5_A_4 = _ScreenPosition_7D471D5C_Out_0[3];
        float _Subtract_AA101019_Out_2;
        Unity_Subtract_float(_Split_C57194B5_A_4, 1, _Subtract_AA101019_Out_2);
        float _Subtract_283E4E77_Out_2;
        Unity_Subtract_float(_SceneDepth_68903870_Out_1, _Subtract_AA101019_Out_2, _Subtract_283E4E77_Out_2);
        float _Property_89CAF578_Out_0 = Vector1_81FB2EA8;
        float _Divide_4532EF3D_Out_2;
        Unity_Divide_float(_Subtract_283E4E77_Out_2, _Property_89CAF578_Out_0, _Divide_4532EF3D_Out_2);
        float _Saturate_E482199_Out_1;
        Unity_Saturate_float(_Divide_4532EF3D_Out_2, _Saturate_E482199_Out_1);
        float _Smoothstep_643FC2C2_Out_3;
        Unity_Smoothstep_float(0, 1, _Saturate_E482199_Out_1, _Smoothstep_643FC2C2_Out_3);
        surface.Alpha = _Smoothstep_643FC2C2_Out_3;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



        output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

        ENDHLSL
    }

        Pass
    {
        Name "DepthOnly"
        Tags 
        { 
            "LightMode" = "DepthOnly"
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0
    #pragma multi_compile_instancing

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS 
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_DEPTHONLY
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A345448D;
    float Vector1_56B5804B;
    float Vector1_B542C30;
    float Vector1_11F7BA6B;
    float Vector1_7464FCA1;
    float Vector1_996A2909;
    float Vector1_9145DEE5;
    float4 Vector4_1528E80F;
    float4 Color_249D68A;
    float4 Color_C16EB892;
    float Vector1_2A3DF01D;
    float Vector1_9A231072;
    float Vector1_60F4B7B;
    float Vector1_2A033F34;
    float Vector1_DBC9DB06;
    float Vector1_C38F0170;
    float Vector1_C8CFAFD6;
    float Vector1_63892271;
    float Vector1_ED5F6A07;
    float Vector1_32ED954F;
    float Vector1_81FB2EA8;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_28BCC07D_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_28BCC07D_Out_2);
        float _Property_6A4549FD_Out_0 = Vector1_63892271;
        float _Divide_8CF523BA_Out_2;
        Unity_Divide_float(_Distance_28BCC07D_Out_2, _Property_6A4549FD_Out_0, _Divide_8CF523BA_Out_2);
        float _Power_A3B4AA8D_Out_2;
        Unity_Power_float(_Divide_8CF523BA_Out_2, 3, _Power_A3B4AA8D_Out_2);
        float3 _Multiply_777A8A0B_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_A3B4AA8D_Out_2.xxx), _Multiply_777A8A0B_Out_2);
        float _Property_6B683C43_Out_0 = Vector1_11F7BA6B;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float3 _Multiply_62EA87EF_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_4CA2CE54_Out_2.xxx), _Multiply_62EA87EF_Out_2);
        float3 _Multiply_2A8170AA_Out_2;
        Unity_Multiply_float((_Property_6B683C43_Out_0.xxx), _Multiply_62EA87EF_Out_2, _Multiply_2A8170AA_Out_2);
        float3 _Add_CD3CAA11_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2A8170AA_Out_2, _Add_CD3CAA11_Out_2);
        float3 _Add_2ADF590F_Out_2;
        Unity_Add_float3(_Multiply_777A8A0B_Out_2, _Add_CD3CAA11_Out_2, _Add_2ADF590F_Out_2);
        description.VertexPosition = _Add_2ADF590F_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };

    struct SurfaceDescription
    {
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float _SceneDepth_68903870_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_68903870_Out_1);
        float4 _ScreenPosition_7D471D5C_Out_0 = IN.ScreenPosition;
        float _Split_C57194B5_R_1 = _ScreenPosition_7D471D5C_Out_0[0];
        float _Split_C57194B5_G_2 = _ScreenPosition_7D471D5C_Out_0[1];
        float _Split_C57194B5_B_3 = _ScreenPosition_7D471D5C_Out_0[2];
        float _Split_C57194B5_A_4 = _ScreenPosition_7D471D5C_Out_0[3];
        float _Subtract_AA101019_Out_2;
        Unity_Subtract_float(_Split_C57194B5_A_4, 1, _Subtract_AA101019_Out_2);
        float _Subtract_283E4E77_Out_2;
        Unity_Subtract_float(_SceneDepth_68903870_Out_1, _Subtract_AA101019_Out_2, _Subtract_283E4E77_Out_2);
        float _Property_89CAF578_Out_0 = Vector1_81FB2EA8;
        float _Divide_4532EF3D_Out_2;
        Unity_Divide_float(_Subtract_283E4E77_Out_2, _Property_89CAF578_Out_0, _Divide_4532EF3D_Out_2);
        float _Saturate_E482199_Out_1;
        Unity_Saturate_float(_Divide_4532EF3D_Out_2, _Saturate_E482199_Out_1);
        float _Smoothstep_643FC2C2_Out_3;
        Unity_Smoothstep_float(0, 1, _Saturate_E482199_Out_1, _Smoothstep_643FC2C2_Out_3);
        surface.Alpha = _Smoothstep_643FC2C2_Out_3;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



        output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

        ENDHLSL
    }

        Pass
    {
        Name "Meta"
        Tags 
        { 
            "LightMode" = "Meta"
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Off
        ZTest LEqual
        ZWrite Off
        // ColorMask: <None>
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS 
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_META
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A345448D;
    float Vector1_56B5804B;
    float Vector1_B542C30;
    float Vector1_11F7BA6B;
    float Vector1_7464FCA1;
    float Vector1_996A2909;
    float Vector1_9145DEE5;
    float4 Vector4_1528E80F;
    float4 Color_249D68A;
    float4 Color_C16EB892;
    float Vector1_2A3DF01D;
    float Vector1_9A231072;
    float Vector1_60F4B7B;
    float Vector1_2A033F34;
    float Vector1_DBC9DB06;
    float Vector1_C38F0170;
    float Vector1_C8CFAFD6;
    float Vector1_63892271;
    float Vector1_ED5F6A07;
    float Vector1_32ED954F;
    float Vector1_81FB2EA8;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
    {
        Out = lerp(A, B, T);
    }

    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
    {
        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
    }

    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
    {
        Out = A + B;
    }

    void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
    {
        Out = A * B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_28BCC07D_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_28BCC07D_Out_2);
        float _Property_6A4549FD_Out_0 = Vector1_63892271;
        float _Divide_8CF523BA_Out_2;
        Unity_Divide_float(_Distance_28BCC07D_Out_2, _Property_6A4549FD_Out_0, _Divide_8CF523BA_Out_2);
        float _Power_A3B4AA8D_Out_2;
        Unity_Power_float(_Divide_8CF523BA_Out_2, 3, _Power_A3B4AA8D_Out_2);
        float3 _Multiply_777A8A0B_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_A3B4AA8D_Out_2.xxx), _Multiply_777A8A0B_Out_2);
        float _Property_6B683C43_Out_0 = Vector1_11F7BA6B;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float3 _Multiply_62EA87EF_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_4CA2CE54_Out_2.xxx), _Multiply_62EA87EF_Out_2);
        float3 _Multiply_2A8170AA_Out_2;
        Unity_Multiply_float((_Property_6B683C43_Out_0.xxx), _Multiply_62EA87EF_Out_2, _Multiply_2A8170AA_Out_2);
        float3 _Add_CD3CAA11_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2A8170AA_Out_2, _Add_CD3CAA11_Out_2);
        float3 _Add_2ADF590F_Out_2;
        Unity_Add_float3(_Multiply_777A8A0B_Out_2, _Add_CD3CAA11_Out_2, _Add_2ADF590F_Out_2);
        description.VertexPosition = _Add_2ADF590F_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 WorldSpaceNormal;
        float3 TangentSpaceNormal;
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };

    struct SurfaceDescription
    {
        float3 Albedo;
        float3 Emission;
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float4 _Property_2C69A20E_Out_0 = Color_249D68A;
        float4 _Property_EACCF9B1_Out_0 = Color_C16EB892;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float4 _Lerp_7F124CFD_Out_3;
        Unity_Lerp_float4(_Property_2C69A20E_Out_0, _Property_EACCF9B1_Out_0, (_Divide_4CA2CE54_Out_2.xxxx), _Lerp_7F124CFD_Out_3);
        float _Property_75195C1A_Out_0 = Vector1_ED5F6A07;
        float _FresnelEffect_5996F356_Out_3;
        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_75195C1A_Out_0, _FresnelEffect_5996F356_Out_3);
        float _Multiply_3EEB98A2_Out_2;
        Unity_Multiply_float(_Divide_4CA2CE54_Out_2, _FresnelEffect_5996F356_Out_3, _Multiply_3EEB98A2_Out_2);
        float _Property_4AD968A2_Out_0 = Vector1_32ED954F;
        float _Multiply_5BFBA9E6_Out_2;
        Unity_Multiply_float(_Multiply_3EEB98A2_Out_2, _Property_4AD968A2_Out_0, _Multiply_5BFBA9E6_Out_2);
        float4 _Add_592D41D1_Out_2;
        Unity_Add_float4(_Lerp_7F124CFD_Out_3, (_Multiply_5BFBA9E6_Out_2.xxxx), _Add_592D41D1_Out_2);
        float _Property_3F343659_Out_0 = Vector1_C8CFAFD6;
        float4 _Multiply_CD58101E_Out_2;
        Unity_Multiply_float(_Add_592D41D1_Out_2, (_Property_3F343659_Out_0.xxxx), _Multiply_CD58101E_Out_2);
        float _SceneDepth_68903870_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_68903870_Out_1);
        float4 _ScreenPosition_7D471D5C_Out_0 = IN.ScreenPosition;
        float _Split_C57194B5_R_1 = _ScreenPosition_7D471D5C_Out_0[0];
        float _Split_C57194B5_G_2 = _ScreenPosition_7D471D5C_Out_0[1];
        float _Split_C57194B5_B_3 = _ScreenPosition_7D471D5C_Out_0[2];
        float _Split_C57194B5_A_4 = _ScreenPosition_7D471D5C_Out_0[3];
        float _Subtract_AA101019_Out_2;
        Unity_Subtract_float(_Split_C57194B5_A_4, 1, _Subtract_AA101019_Out_2);
        float _Subtract_283E4E77_Out_2;
        Unity_Subtract_float(_SceneDepth_68903870_Out_1, _Subtract_AA101019_Out_2, _Subtract_283E4E77_Out_2);
        float _Property_89CAF578_Out_0 = Vector1_81FB2EA8;
        float _Divide_4532EF3D_Out_2;
        Unity_Divide_float(_Subtract_283E4E77_Out_2, _Property_89CAF578_Out_0, _Divide_4532EF3D_Out_2);
        float _Saturate_E482199_Out_1;
        Unity_Saturate_float(_Divide_4532EF3D_Out_2, _Saturate_E482199_Out_1);
        float _Smoothstep_643FC2C2_Out_3;
        Unity_Smoothstep_float(0, 1, _Saturate_E482199_Out_1, _Smoothstep_643FC2C2_Out_3);
        surface.Albedo = (_Add_592D41D1_Out_2.xyz);
        surface.Emission = (_Multiply_CD58101E_Out_2.xyz);
        surface.Alpha = _Smoothstep_643FC2C2_Out_3;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float3 interp02 : TEXCOORD2;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyz = input.normalWS;
                output.interp02.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.normalWS = input.interp01.xyz;
                output.viewDirectionWS = input.interp02.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    	float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


        output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

        ENDHLSL
    }

        Pass
    {
        // Name: <None>
        Tags 
        { 
            "LightMode" = "Universal2D"
        }
       
        // Render State
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        Cull Back
        ZTest LEqual
        ZWrite Off
        // ColorMask: <None>
        

        HLSLPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        // Pragmas
        #pragma prefer_hlslcc gles
    #pragma exclude_renderers d3d11_9x
    #pragma target 2.0
    #pragma multi_compile_instancing

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS 
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        #define SHADERPASS_2D
    #define REQUIRE_DEPTH_TEXTURE

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
    float4 Vector4_A345448D;
    float Vector1_56B5804B;
    float Vector1_B542C30;
    float Vector1_11F7BA6B;
    float Vector1_7464FCA1;
    float Vector1_996A2909;
    float Vector1_9145DEE5;
    float4 Vector4_1528E80F;
    float4 Color_249D68A;
    float4 Color_C16EB892;
    float Vector1_2A3DF01D;
    float Vector1_9A231072;
    float Vector1_60F4B7B;
    float Vector1_2A033F34;
    float Vector1_DBC9DB06;
    float Vector1_C38F0170;
    float Vector1_C8CFAFD6;
    float Vector1_63892271;
    float Vector1_ED5F6A07;
    float Vector1_32ED954F;
    float Vector1_81FB2EA8;
    CBUFFER_END

        // Graph Functions
        
    void Unity_Distance_float3(float3 A, float3 B, out float Out)
    {
        Out = distance(A, B);
    }

    void Unity_Divide_float(float A, float B, out float Out)
    {
        Out = A / B;
    }

    void Unity_Power_float(float A, float B, out float Out)
    {
        Out = pow(A, B);
    }

    void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
    {
        Out = A * B;
    }

    void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
    {
        Rotation = radians(Rotation);

        float s = sin(Rotation);
        float c = cos(Rotation);
        float one_minus_c = 1.0 - c;
        
        Axis = normalize(Axis);

        float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                  one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                  one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                };

        Out = mul(rot_mat,  In);
    }

    void Unity_Multiply_float(float A, float B, out float Out)
    {
        Out = A * B;
    }

    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
    {
        Out = UV * Tiling + Offset;
    }


    float2 Unity_GradientNoise_Dir_float(float2 p)
    {
        // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
        p = p % 289;
        float x = (34 * p.x + 1) * p.x % 289 + p.y;
        x = (34 * x + 1) * x % 289;
        x = frac(x / 41) * 2 - 1;
        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
    }

    void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
    { 
        float2 p = UV * Scale;
        float2 ip = floor(p);
        float2 fp = frac(p);
        float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
        float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
        float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
        float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
    }

    void Unity_Add_float(float A, float B, out float Out)
    {
        Out = A + B;
    }

    void Unity_Saturate_float(float In, out float Out)
    {
        Out = saturate(In);
    }

    void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
    {
        RGBA = float4(R, G, B, A);
        RGB = float3(R, G, B);
        RG = float2(R, G);
    }

    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
    {
        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    }

    void Unity_Absolute_float(float In, out float Out)
    {
        Out = abs(In);
    }

    void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
    {
        Out = smoothstep(Edge1, Edge2, In);
    }

    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
    {
        Out = A + B;
    }

    void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
    {
        Out = lerp(A, B, T);
    }

    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
    {
        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
    }

    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
    {
        Out = A + B;
    }

    void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
    {
        Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
    }

    void Unity_Subtract_float(float A, float B, out float Out)
    {
        Out = A - B;
    }

        // Graph Vertex
        struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 WorldSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float3 WorldSpacePosition;
        float3 TimeParameters;
    };

    struct VertexDescription
    {
        float3 VertexPosition;
        float3 VertexNormal;
        float3 VertexTangent;
    };

    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
    {
        VertexDescription description = (VertexDescription)0;
        float _Distance_28BCC07D_Out_2;
        Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_28BCC07D_Out_2);
        float _Property_6A4549FD_Out_0 = Vector1_63892271;
        float _Divide_8CF523BA_Out_2;
        Unity_Divide_float(_Distance_28BCC07D_Out_2, _Property_6A4549FD_Out_0, _Divide_8CF523BA_Out_2);
        float _Power_A3B4AA8D_Out_2;
        Unity_Power_float(_Divide_8CF523BA_Out_2, 3, _Power_A3B4AA8D_Out_2);
        float3 _Multiply_777A8A0B_Out_2;
        Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_A3B4AA8D_Out_2.xxx), _Multiply_777A8A0B_Out_2);
        float _Property_6B683C43_Out_0 = Vector1_11F7BA6B;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float3 _Multiply_62EA87EF_Out_2;
        Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_4CA2CE54_Out_2.xxx), _Multiply_62EA87EF_Out_2);
        float3 _Multiply_2A8170AA_Out_2;
        Unity_Multiply_float((_Property_6B683C43_Out_0.xxx), _Multiply_62EA87EF_Out_2, _Multiply_2A8170AA_Out_2);
        float3 _Add_CD3CAA11_Out_2;
        Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_2A8170AA_Out_2, _Add_CD3CAA11_Out_2);
        float3 _Add_2ADF590F_Out_2;
        Unity_Add_float3(_Multiply_777A8A0B_Out_2, _Add_CD3CAA11_Out_2, _Add_2ADF590F_Out_2);
        description.VertexPosition = _Add_2ADF590F_Out_2;
        description.VertexNormal = IN.ObjectSpaceNormal;
        description.VertexTangent = IN.ObjectSpaceTangent;
        return description;
    }
        
        // Graph Pixel
        struct SurfaceDescriptionInputs
    {
        float3 WorldSpaceNormal;
        float3 TangentSpaceNormal;
        float3 WorldSpaceViewDirection;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float3 TimeParameters;
    };

    struct SurfaceDescription
    {
        float3 Albedo;
        float Alpha;
        float AlphaClipThreshold;
    };

    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
    {
        SurfaceDescription surface = (SurfaceDescription)0;
        float4 _Property_2C69A20E_Out_0 = Color_249D68A;
        float4 _Property_EACCF9B1_Out_0 = Color_C16EB892;
        float _Property_346CA866_Out_0 = Vector1_2A3DF01D;
        float _Property_1B99FAEF_Out_0 = Vector1_9A231072;
        float4 _Property_95028833_Out_0 = Vector4_A345448D;
        float _Split_EFE2030C_R_1 = _Property_95028833_Out_0[0];
        float _Split_EFE2030C_G_2 = _Property_95028833_Out_0[1];
        float _Split_EFE2030C_B_3 = _Property_95028833_Out_0[2];
        float _Split_EFE2030C_A_4 = _Property_95028833_Out_0[3];
        float3 _RotateAboutAxis_31B322C_Out_3;
        Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_95028833_Out_0.xyz), _Split_EFE2030C_A_4, _RotateAboutAxis_31B322C_Out_3);
        float _Property_1BC88DC9_Out_0 = Vector1_B542C30;
        float _Multiply_FFF95FDC_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_1BC88DC9_Out_0, _Multiply_FFF95FDC_Out_2);
        float2 _TilingAndOffset_7AE5B544_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_FFF95FDC_Out_2.xx), _TilingAndOffset_7AE5B544_Out_3);
        float _Property_2CABF07F_Out_0 = Vector1_56B5804B;
        float _GradientNoise_E075F298_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_7AE5B544_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_E075F298_Out_2);
        float2 _TilingAndOffset_1DC1FA99_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_1DC1FA99_Out_3);
        float _GradientNoise_91090F0E_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_1DC1FA99_Out_3, _Property_2CABF07F_Out_0, _GradientNoise_91090F0E_Out_2);
        float _Add_3B5905E4_Out_2;
        Unity_Add_float(_GradientNoise_E075F298_Out_2, _GradientNoise_91090F0E_Out_2, _Add_3B5905E4_Out_2);
        float _Divide_A46DADB3_Out_2;
        Unity_Divide_float(_Add_3B5905E4_Out_2, 2, _Divide_A46DADB3_Out_2);
        float _Saturate_1C502BA4_Out_1;
        Unity_Saturate_float(_Divide_A46DADB3_Out_2, _Saturate_1C502BA4_Out_1);
        float _Property_57024235_Out_0 = Vector1_60F4B7B;
        float _Power_93573394_Out_2;
        Unity_Power_float(_Saturate_1C502BA4_Out_1, _Property_57024235_Out_0, _Power_93573394_Out_2);
        float4 _Property_8B0DD947_Out_0 = Vector4_1528E80F;
        float _Split_9958406A_R_1 = _Property_8B0DD947_Out_0[0];
        float _Split_9958406A_G_2 = _Property_8B0DD947_Out_0[1];
        float _Split_9958406A_B_3 = _Property_8B0DD947_Out_0[2];
        float _Split_9958406A_A_4 = _Property_8B0DD947_Out_0[3];
        float4 _Combine_ACEDA9E7_RGBA_4;
        float3 _Combine_ACEDA9E7_RGB_5;
        float2 _Combine_ACEDA9E7_RG_6;
        Unity_Combine_float(_Split_9958406A_R_1, _Split_9958406A_G_2, 0, 0, _Combine_ACEDA9E7_RGBA_4, _Combine_ACEDA9E7_RGB_5, _Combine_ACEDA9E7_RG_6);
        float4 _Combine_571FA58E_RGBA_4;
        float3 _Combine_571FA58E_RGB_5;
        float2 _Combine_571FA58E_RG_6;
        Unity_Combine_float(_Split_9958406A_B_3, _Split_9958406A_A_4, 0, 0, _Combine_571FA58E_RGBA_4, _Combine_571FA58E_RGB_5, _Combine_571FA58E_RG_6);
        float _Remap_3667F65D_Out_3;
        Unity_Remap_float(_Power_93573394_Out_2, _Combine_ACEDA9E7_RG_6, _Combine_571FA58E_RG_6, _Remap_3667F65D_Out_3);
        float _Absolute_2163AB30_Out_1;
        Unity_Absolute_float(_Remap_3667F65D_Out_3, _Absolute_2163AB30_Out_1);
        float _Smoothstep_30C71CAC_Out_3;
        Unity_Smoothstep_float(_Property_346CA866_Out_0, _Property_1B99FAEF_Out_0, _Absolute_2163AB30_Out_1, _Smoothstep_30C71CAC_Out_3);
        float _Property_75C2AF01_Out_0 = Vector1_DBC9DB06;
        float _Multiply_924F8F8E_Out_2;
        Unity_Multiply_float(IN.TimeParameters.x, _Property_75C2AF01_Out_0, _Multiply_924F8F8E_Out_2);
        float2 _TilingAndOffset_B55190BB_Out_3;
        Unity_TilingAndOffset_float((_RotateAboutAxis_31B322C_Out_3.xy), float2 (1, 1), (_Multiply_924F8F8E_Out_2.xx), _TilingAndOffset_B55190BB_Out_3);
        float _Property_1003CD65_Out_0 = Vector1_2A033F34;
        float _GradientNoise_35DAE204_Out_2;
        Unity_GradientNoise_float(_TilingAndOffset_B55190BB_Out_3, _Property_1003CD65_Out_0, _GradientNoise_35DAE204_Out_2);
        float _Property_E3EB665_Out_0 = Vector1_C38F0170;
        float _Multiply_390A9C11_Out_2;
        Unity_Multiply_float(_GradientNoise_35DAE204_Out_2, _Property_E3EB665_Out_0, _Multiply_390A9C11_Out_2);
        float _Add_6A252E8_Out_2;
        Unity_Add_float(_Smoothstep_30C71CAC_Out_3, _Multiply_390A9C11_Out_2, _Add_6A252E8_Out_2);
        float _Add_AF1A2FC9_Out_2;
        Unity_Add_float(1, _Property_E3EB665_Out_0, _Add_AF1A2FC9_Out_2);
        float _Divide_4CA2CE54_Out_2;
        Unity_Divide_float(_Add_6A252E8_Out_2, _Add_AF1A2FC9_Out_2, _Divide_4CA2CE54_Out_2);
        float4 _Lerp_7F124CFD_Out_3;
        Unity_Lerp_float4(_Property_2C69A20E_Out_0, _Property_EACCF9B1_Out_0, (_Divide_4CA2CE54_Out_2.xxxx), _Lerp_7F124CFD_Out_3);
        float _Property_75195C1A_Out_0 = Vector1_ED5F6A07;
        float _FresnelEffect_5996F356_Out_3;
        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_75195C1A_Out_0, _FresnelEffect_5996F356_Out_3);
        float _Multiply_3EEB98A2_Out_2;
        Unity_Multiply_float(_Divide_4CA2CE54_Out_2, _FresnelEffect_5996F356_Out_3, _Multiply_3EEB98A2_Out_2);
        float _Property_4AD968A2_Out_0 = Vector1_32ED954F;
        float _Multiply_5BFBA9E6_Out_2;
        Unity_Multiply_float(_Multiply_3EEB98A2_Out_2, _Property_4AD968A2_Out_0, _Multiply_5BFBA9E6_Out_2);
        float4 _Add_592D41D1_Out_2;
        Unity_Add_float4(_Lerp_7F124CFD_Out_3, (_Multiply_5BFBA9E6_Out_2.xxxx), _Add_592D41D1_Out_2);
        float _SceneDepth_68903870_Out_1;
        Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_68903870_Out_1);
        float4 _ScreenPosition_7D471D5C_Out_0 = IN.ScreenPosition;
        float _Split_C57194B5_R_1 = _ScreenPosition_7D471D5C_Out_0[0];
        float _Split_C57194B5_G_2 = _ScreenPosition_7D471D5C_Out_0[1];
        float _Split_C57194B5_B_3 = _ScreenPosition_7D471D5C_Out_0[2];
        float _Split_C57194B5_A_4 = _ScreenPosition_7D471D5C_Out_0[3];
        float _Subtract_AA101019_Out_2;
        Unity_Subtract_float(_Split_C57194B5_A_4, 1, _Subtract_AA101019_Out_2);
        float _Subtract_283E4E77_Out_2;
        Unity_Subtract_float(_SceneDepth_68903870_Out_1, _Subtract_AA101019_Out_2, _Subtract_283E4E77_Out_2);
        float _Property_89CAF578_Out_0 = Vector1_81FB2EA8;
        float _Divide_4532EF3D_Out_2;
        Unity_Divide_float(_Subtract_283E4E77_Out_2, _Property_89CAF578_Out_0, _Divide_4532EF3D_Out_2);
        float _Saturate_E482199_Out_1;
        Unity_Saturate_float(_Divide_4532EF3D_Out_2, _Saturate_E482199_Out_1);
        float _Smoothstep_643FC2C2_Out_3;
        Unity_Smoothstep_float(0, 1, _Saturate_E482199_Out_1, _Smoothstep_643FC2C2_Out_3);
        surface.Albedo = (_Add_592D41D1_Out_2.xyz);
        surface.Alpha = _Smoothstep_643FC2C2_Out_3;
        surface.AlphaClipThreshold = 0;
        return surface;
    }

        // --------------------------------------------------
        // Structs and Packing

        // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };

        // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float3 interp02 : TEXCOORD2;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyz = input.normalWS;
                output.interp02.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.normalWS = input.interp01.xyz;
                output.viewDirectionWS = input.interp02.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);

        output.ObjectSpaceNormal =           input.normalOS;
        output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
        output.ObjectSpaceTangent =          input.tangentOS;
        output.ObjectSpacePosition =         input.positionOS;
        output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
        output.TimeParameters =              _TimeParameters.xyz;

        return output;
    }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

    	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    	float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


        output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
        output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


        output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
        output.WorldSpacePosition =          input.positionWS;
        output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

        return output;
    }

        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

        ENDHLSL
    }

    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}
