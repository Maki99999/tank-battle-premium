Shader "Custom/EarlyLitWobble"
{
    Properties
    {
        [NoScaleOffset]Texture2D_D79F2AC("Albedo", 2D) = "white" {}
        [NoScaleOffset]Texture2D_C7C08109("Normal", 2D) = "white" {}
        Vector1_6A42FEE5("VariationAmplitude", Float) = 0.02
        Vector1_4129371F("DriftSpeed", Float) = 0.25
        Vector1_853C47CD("VertexAmplitude", Float) = 1
        Vector1_39DFB8FD("SamplingSpeed", Float) = 0.1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Geometry-3"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
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
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
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
            UnityTexture2D _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_D79F2AC);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.tex, _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_R_4 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.r;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_G_5 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.g;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_B_6 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.b;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_A_7 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.a;
            UnityTexture2D _Property_935f42ecd992d080927984b4bfd236f0_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_C7C08109);
            float4 _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_935f42ecd992d080927984b4bfd236f0_Out_0.tex, _Property_935f42ecd992d080927984b4bfd236f0_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_R_4 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.r;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_G_5 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.g;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_B_6 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.b;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_A_7 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.a;
            surface.BaseColor = (_SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.xyz);
            surface.NormalTS = (_SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
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
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
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
            UnityTexture2D _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_D79F2AC);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.tex, _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_R_4 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.r;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_G_5 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.g;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_B_6 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.b;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_A_7 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.a;
            UnityTexture2D _Property_935f42ecd992d080927984b4bfd236f0_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_C7C08109);
            float4 _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_935f42ecd992d080927984b4bfd236f0_Out_0.tex, _Property_935f42ecd992d080927984b4bfd236f0_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_R_4 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.r;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_G_5 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.g;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_B_6 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.b;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_A_7 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.a;
            surface.BaseColor = (_SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.xyz);
            surface.NormalTS = (_SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

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
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
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
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_935f42ecd992d080927984b4bfd236f0_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_C7C08109);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_935f42ecd992d080927984b4bfd236f0_Out_0.tex, _Property_935f42ecd992d080927984b4bfd236f0_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_R_4 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.r;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_G_5 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.g;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_B_6 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.b;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_A_7 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.a;
            surface.NormalTS = (_SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.xyz);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

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
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_D79F2AC);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.tex, _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_R_4 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.r;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_G_5 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.g;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_B_6 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.b;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_A_7 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.a;
            surface.BaseColor = (_SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
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
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_D79F2AC);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.tex, _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_R_4 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.r;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_G_5 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.g;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_B_6 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.b;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_A_7 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.a;
            surface.BaseColor = (_SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.xyz);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Geometry-3"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
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
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
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
            UnityTexture2D _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_D79F2AC);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.tex, _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_R_4 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.r;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_G_5 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.g;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_B_6 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.b;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_A_7 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.a;
            UnityTexture2D _Property_935f42ecd992d080927984b4bfd236f0_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_C7C08109);
            float4 _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_935f42ecd992d080927984b4bfd236f0_Out_0.tex, _Property_935f42ecd992d080927984b4bfd236f0_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_R_4 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.r;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_G_5 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.g;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_B_6 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.b;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_A_7 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.a;
            surface.BaseColor = (_SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.xyz);
            surface.NormalTS = (_SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
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
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
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
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_935f42ecd992d080927984b4bfd236f0_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_C7C08109);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_935f42ecd992d080927984b4bfd236f0_Out_0.tex, _Property_935f42ecd992d080927984b4bfd236f0_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_R_4 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.r;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_G_5 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.g;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_B_6 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.b;
            float _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_A_7 = _SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.a;
            surface.NormalTS = (_SampleTexture2D_5adf4f915792cd8eb364a26e351941d0_RGBA_0.xyz);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

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
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_D79F2AC);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.tex, _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_R_4 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.r;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_G_5 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.g;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_B_6 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.b;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_A_7 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.a;
            surface.BaseColor = (_SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
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
            Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_D79F2AC_TexelSize;
        float4 Texture2D_C7C08109_TexelSize;
        float Vector1_6A42FEE5;
        float Vector1_4129371F;
        float Vector1_853C47CD;
        float Vector1_39DFB8FD;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_D79F2AC);
        SAMPLER(samplerTexture2D_D79F2AC);
        TEXTURE2D(Texture2D_C7C08109);
        SAMPLER(samplerTexture2D_C7C08109);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }


        inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)));
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

        void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
        {
            float2 g = floor(UV * CellDensity);
            float2 f = frac(UV * CellDensity);
            float t = 8.0;
            float3 res = float3(8.0, 0.0, 0.0);

            for(int y=-1; y<=1; y++)
            {
                for(int x=-1; x<=1; x++)
                {
                    float2 lattice = float2(x,y);
                    float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
                    float d = distance(lattice + offset, f);

                    if(d < res.x)
                    {
                        res = float3(d, offset.x, offset.y);
                        Out = res.x;
                        Cells = res.y;
                    }
                }
            }
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Sine_float(float In, out float Out)
        {
            Out = sin(In);
        }

        void TriangleWave_float4(float4 In, out float4 Out)
        {
            Out = 2.0 * abs( 2 * (In - floor(0.5 + In)) ) - 1.0;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_380b0d58927c04858094dc05d2450c16_Out_0 = Vector1_853C47CD;
            float _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2;
            Unity_Multiply_float(0, _Property_380b0d58927c04858094dc05d2450c16_Out_0, _Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2);
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2;
            Unity_Multiply_float(_Multiply_efbc0114d1dd7c85b9916947810fb5e6_Out_2, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2);
            float _Add_d3530975fb390e89bce188a15493fd03_Out_2;
            Unity_Add_float(_Multiply_0dfe2c05e0d6f58799d05ca12f9ade36_Out_2, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0 = float3(0, 0, _Add_d3530975fb390e89bce188a15493fd03_Out_2);
            float3 _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Vector3_1a97b7f74ac1d38f902d1f288d0a319f_Out_0, _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2);
            description.Position = _Add_32db6da1e9d63f83ae069b95ddb6ec34_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_D79F2AC);
            float4 _UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0 = IN.uv0;
            float4 _UV_7c6327595baf418e962476ae3b173f32_Out_0 = IN.uv0;
            float4 _Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0 = float4(IN.TimeParameters.x, IN.TimeParameters.y, IN.TimeParameters.z, 0);
            float _Property_2d455a86d1b1e38da448350b0d644071_Out_0 = Vector1_4129371F;
            float4 _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2;
            Unity_Multiply_float(_Vector4_a6c272be991e3c8d96ee6c19152b568c_Out_0, (_Property_2d455a86d1b1e38da448350b0d644071_Out_0.xxxx), _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2);
            float4 _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2;
            Unity_Add_float4(_UV_7c6327595baf418e962476ae3b173f32_Out_0, _Multiply_edb2ec7006ae5783aec8a63d7e7ea1eb_Out_2, _Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2);
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3;
            float _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4;
            Unity_Voronoi_float((_Add_6c69dc82f5c09086b184def32f5ebbb7_Out_2.xy), 3, 3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Voronoi_cff8322fdf787486b6a03581293f83b6_Cells_4);
            float _Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0 = Vector1_6A42FEE5;
            float _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, 0, _Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2);
            float _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1;
            Unity_Sine_float(_Multiply_7e6a35aad7da7188a952a9aa33029561_Out_2, _Sine_9b3d5f3de0472f8083478490934fff7f_Out_1);
            float _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2;
            Unity_Add_float(_Sine_9b3d5f3de0472f8083478490934fff7f_Out_1, 1, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2);
            float _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2;
            Unity_Multiply_float(_Property_a3e0ac0db116c08b9cf857269fcb3ba4_Out_0, _Add_f1b37b3bb2fccb87908459c1d87cbf9d_Out_2, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2);
            float _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2;
            Unity_Multiply_float(_Voronoi_cff8322fdf787486b6a03581293f83b6_Out_3, _Multiply_7d6911134b69c98194d3fbb5c17f89e9_Out_2, _Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2);
            float4 _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0 = float4(_Multiply_d3f55ac5a8c8778b8fa4e4cfbecee2c5_Out_2, 0, 0, 0);
            float4 _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2;
            Unity_Add_float4(_UV_6d0a5a9d0df18a8ea95696efeb755c07_Out_0, _Vector4_70fa53a148f0168daa67a3b5dc0c35f1_Out_0, _Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2);
            float _Property_91875b5e951685819f5ded977a6497fc_Out_0 = Vector1_39DFB8FD;
            float4 _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2;
            Unity_Multiply_float(_Add_e6ce4a5e91705a86839f5a98a9a71881_Out_2, (_Property_91875b5e951685819f5ded977a6497fc_Out_0.xxxx), _Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2);
            float4 _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1;
            TriangleWave_float4(_Multiply_987c945344ce7d8d90dd45a0ab27a882_Out_2, _TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1);
            float4 _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2;
            Unity_Add_float4(_TriangleWave_6bfdb4a869aca283a56887481287627b_Out_1, float4(1, 1, 1, 0), _Add_87d755971ecaf183aa98f74e6ab8546a_Out_2);
            float4 _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2;
            Unity_Multiply_float(_Add_87d755971ecaf183aa98f74e6ab8546a_Out_2, float4(0.5, 0.5, 0.5, 2), _Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2);
            float4 _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.tex, _Property_4cc3f137434eb5848a86379dc8fd4f88_Out_0.samplerstate, (_Multiply_373c56f18902b4888d4b1dfe1e4ec58e_Out_2.xy));
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_R_4 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.r;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_G_5 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.g;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_B_6 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.b;
            float _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_A_7 = _SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.a;
            surface.BaseColor = (_SampleTexture2D_102f3e7cf5452287ae2f13a3d49d9bf8_RGBA_0.xyz);
            surface.Alpha = 1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;
            output.uv0 =                         input.uv0;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.uv0 =                         input.texCoord0;
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}