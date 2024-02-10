
#include "raytracing.bi"
#Include "common_math.bi"

#Include "raytracing.bas"
#Include "common_math.bas"



' medidas imagen
  Dim As Integer img_w = 1920 
  Dim As Integer img_h = 1080 


  ScreenRes 320,240,32 ' no se emplea, es solo para poder usar "ImageCreate"
  Dim As Any Ptr img= ImageCreate(img_w,img_h)


  Dim As plane_t planes = Type( _
      {0.0, 0.0, 0.0},_ ' Position
      {0.0, 1.0, 0.0},_ ' Normal
      {1.0, 1.0, 1.0},_ ' Color 1 (RGB)
      {0.0, 0.0, 0.0},_ ' Color 2 (RGB)
      0.5,            _ ' Diffuse
      0.25,           _ ' Specular
      0.35            _ ' Reflection
  )

  Dim As sphere_t sphere_0 = Type( _
      {-0.5, 0.6, -2.0}, _  ' Position
      {0.20, 0.59, 0.86},_  ' Color (RGB)
      0.6,               _  ' Radius
      1.0,               _  ' Diffuse
      0.5,               _  ' Specular
      0.15               _  ' Reflection
  )

  Dim As sphere_t sphere_1 = Type( _
      {0.2, 0.2, -2.0}, _ ' Position
      {0.9, 0.30, 0.23},_ ' Color (RGB)
      0.2,              _ ' Radius
      1.0,              _ ' Diffuse
      0.5,              _ ' Specular
      0.15              _ ' Reflection
  )

  Dim As sphere_t sphere_2 = Type( _
      {-0.65, 0.3, -1.0},_  ' Position
      {0.18, 0.80, 0.44},_  ' Color (RGB)
      0.3,               _  ' Radius
      1.0,               _  ' Diffuse
      0.5,               _  ' Specular
      0.15               _  ' Reflection
  )


  Dim As scenario_t scenario 
  With scenario
      .ambient_light=0.0 ' Ambient Light
      .specular_exp =100 ' Specular light power
      
      .camera_pos(0)=0.75 ' Camera Position
      .camera_pos(1)=0.4
      .camera_pos(2)=2.0
      
      .camera_rot(0)=0.0 ' Camera Rotation
      .camera_rot(1)=0.5   
      
      .light_pos(0)=-1.0 ' Light position
      .light_pos(1)=3.0 
      .light_pos(2)=1.0
      
      .light_color(0)=1.0 ' Light color
      .light_color(1)=1.0
      .light_color(2)=1.0
      
      .planes=planes ' Plane info
      
      .spheres(0)=sphere_0 ' Spheres info
      .spheres(1)=sphere_1
      .spheres(2)=sphere_2
  End with

  render_scene(img+55, img_w, img_h, scenario) ' 55=tamaño cabecera BMP

  BSave "resultado.bmp",img


