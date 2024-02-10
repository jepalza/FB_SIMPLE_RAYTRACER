

#define MAX_DEPTH 10

#define PLANE 0
#define SPHERE 1

Type plane_t 
  As Double post(2) 
  As Double normal(2) 
  As Double dark_color(2) 
  As Double light_color(2) 
  As Double diffuse 
  As Double specular 
  As Double reflection 
End Type 

Type sphere_t 
  As Double post(2) 
  As Double colors(2) 
  As Double radius 
  As Double diffuse 
  As Double specular 
  As Double reflection 
End Type 

Type scenario_t 
  As Double ambient_light 
  As Double specular_exp 

  As Double camera_pos(2) 
  As Double camera_rot(1) 

  As Double light_pos(2) 
  As Double light_color(2) 

  As plane_t  planes
  As sphere_t spheres(2) 
End Type 

Declare Function intersect_plane(camera_pos() As Double , camera_dir() As Double , plane_pos() As Double , plane_normal() As Double) As Double 
Declare Function intersect_sphere(camera_pos() As Double , camera_dir() As Double , sphere_pos() As Double , radius As Double) As Double 
Declare Sub render_scene(img_pixels As long ptr, screen_w As Integer , screen_h As Integer , scenario As scenario_t) 
