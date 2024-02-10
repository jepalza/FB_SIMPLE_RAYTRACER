

Function intersect_plane(camera_pos() As Double , camera_dir() As Double , plane_pos() As Double , plane_normal() As Double) As Double 
  Dim As Double denom = vec_dot(camera_dir(), plane_normal()) 

  Dim As Double abs_denom = IIf(denom > 0 , denom , -denom )
  if (abs_denom < 1e-6) Then Return DBL_MAX 

  Dim As Double pos_diff(2) 
  for i As Integer = 0 To 2        
    pos_diff(i) = plane_pos(i) - camera_pos(i) 
  Next

  Dim As Double d = vec_dot(pos_diff(), plane_normal()) / denom 
  if (d < 0) Then Return DBL_MAX 

  return d 
End Function

Function intersect_sphere(camera_pos() As Double , camera_dir() As Double , sphere_pos() As Double , radius As Double) As Double 
  Dim As Double pos_diff(2) 
  for i As Integer = 0 To 2
    pos_diff(i) = camera_pos(i) - sphere_pos(i) 
  Next

  Dim As Double b = 2 * vec_dot(camera_dir(), pos_diff()) 
  Dim As Double c = vec_dot(pos_diff(), pos_diff()) - radius * radius 

  Dim As Double delta = b * b - 4 * c 

  if (delta > 0) Then 
  
    Dim As Double sqrt_delta = Sqr(delta) 
    Dim As Double x0 = (-b + sqrt_delta) / 2 
    Dim As Double x1 = (-b - sqrt_delta) / 2 

    if (x0 > 0) AndAlso (x1 > 0) Then Return min(x0, x1) 

  EndIf
  
  return DBL_MAX 
End Function

Sub render_scene( img_pixels As long ptr, screen_w As Integer , screen_h As Integer , scenario As scenario_t) 
  Dim As Double screen_ratio = screen_w / screen_h 
  Dim As Double screen_bounds(3) = {-1.0, -1.0 / screen_ratio, 1.0, 1.0 / screen_ratio} 

  Dim As Double pixel_pos(2) = {0.0, 0.0, 0.0} 

  Dim As Double x_step = (screen_bounds(2) - screen_bounds(0)) / screen_w 
  Dim As Double y_step = (screen_bounds(3) - screen_bounds(1)) / screen_h 

  Dim As Integer n_spheres = uBound(scenario.spheres)+1 ' numero de esferas

  for px As Integer = 0 To screen_w-1         
    for py As Integer = 0 To screen_h-1         
      Dim As Double x = screen_bounds(0) + px * x_step + scenario.camera_rot(0) 
      Dim As Double y = screen_bounds(1) + py * y_step + scenario.camera_rot(1) 

      Dim As Double px_color(2) = {0.0, 0.0, 0.0} 

      pixel_pos(0) = x 
      pixel_pos(1) = y 

      Dim As Double ray_origin(2), ray_dir(2) 
      for i As Integer = 0 To 2       
        ray_dir(i) = pixel_pos(i) - scenario.camera_pos(i) 
        ray_origin(i) = scenario.camera_pos(i) 
      Next

      vec_normalize(ray_dir()) 

      Dim As Double reflection = 1.0 
      For depth As Integer = 0 To MAX_DEPTH -1        
        Dim As BOOLEAN traced = FALSE  

        Dim As Integer closest_sphere_i = 0 
        Dim As Double t_sphere = DBL_MAX 

        for i As Integer = 0 To n_spheres -1        
          Dim As Double t = intersect_sphere(ray_origin(), ray_dir(), scenario.spheres(i).post(), scenario.spheres(i).radius) 
          if (t < t_sphere) Then 
            t_sphere = t 
            closest_sphere_i = i 
          EndIf
        Next

        Dim As sphere_t close_sphere = scenario.spheres(closest_sphere_i) 
        Dim As Double t_plane = intersect_plane(ray_origin(), ray_dir(), scenario.planes.post(), scenario.planes.normal()) 

        Dim As Double tmin = min(t_sphere, t_plane) 
        Dim As Integer tObj = IIf(t_sphere < t_plane , SPHERE , PLANE )

        Dim As Double intersec_pt(2), obj_normal(2), ray_color(2) 
        if (tmin < DBL_MAX) Then 
  
          for i As Integer = 0 To 2         
            intersec_pt(i) = ray_origin(i) + ray_dir(i) * tmin 
          Next

          Dim As Double obj_color(2) 
          if (tObj = PLANE) Then 
  
            Dim As Integer use_dark_color = (abs(intersec_pt(0) * 2.0 + 100000) mod 2) = (abs(intersec_pt(2) * 2.0 + 100000) Mod 2) 
            for i As Integer = 0 To 2         
              obj_normal(i) = scenario.planes.normal(i) 
              obj_color(i) = IIf (use_dark_color , scenario.planes.dark_color(i) , scenario.planes.light_color(i) )
            Next
            
          Else
         
            for i As Integer = 0 To 2         
              obj_normal(i) = intersec_pt(i) - close_sphere.post(i) 
              obj_color(i)  = close_sphere.colors(i) 
            Next

            vec_normalize(obj_normal()) 
            
          EndIf
  

          Dim As Double dir_to_light(2), dir_to_camera(2), bounce_pt(2) 
          for i As Integer = 0 To 2         
            dir_to_light(i)  = scenario.light_pos(i) - intersec_pt(i) 
            dir_to_camera(i) = scenario.light_pos(i) - intersec_pt(i) 
            bounce_pt(i) = intersec_pt(i) + obj_normal(i) * 1e-4 
          Next

          vec_normalize(dir_to_light()) 
          vec_normalize(dir_to_camera()) 

          Dim As BOOLEAN is_shadow 
          if (tObj = PLANE) Then 
            is_shadow = IIf(intersect_sphere(bounce_pt(), dir_to_light(), close_sphere.post(), close_sphere.radius) < DBL_MAX,1,0) 
          Else
            is_shadow = IIf(intersect_plane(bounce_pt(), dir_to_light(), scenario.planes.post(), scenario.planes.normal()) < DBL_MAX,1,0) 
          EndIf
  
          if (is_shadow=0) Then 
  
            Dim As Double obj_diffuse  = IIf(tObj=PLANE , scenario.planes.diffuse  , close_sphere.diffuse )
            Dim As Double obj_specular = IIf(tObj=PLANE , scenario.planes.specular , close_sphere.specular)

            Dim As Double H(2) 
            for i As Integer = 0 To 2         
              H(i) = dir_to_light(i) + dir_to_camera(i) 
            Next

            vec_normalize(H()) 

            Dim As Double diffuse_intensity  = max(vec_dot(obj_normal(), dir_to_light()), 0) 
            Dim As Double specular_intensity = max(vec_dot(obj_normal(), H()), 0) ^ scenario.specular_exp 
            for i As Integer = 0 To 2       
              ray_color(i) = scenario.ambient_light 
              ray_color(i) += obj_diffuse * diffuse_intensity * obj_color(i) 
              ray_color(i) += obj_specular * specular_intensity * scenario.light_color(i) 
            Next

            traced = TRUE  
          EndIf
          
        EndIf

        if traced=0 Then Exit For 

        Dim As Double dir_dot_normal = vec_dot(ray_dir(), obj_normal()) 
        for i As Integer = 0 To 2         
          ray_origin(i) = intersec_pt(i) + obj_normal(i) * 1e-4 
          ray_dir(i)    = ray_dir(i) - 2 * dir_dot_normal * obj_normal(i) 
          px_color(i)  += reflection * ray_color(i) 
        Next

        vec_normalize(ray_dir()) 
        reflection *= IIf(tObj=PLANE , scenario.planes.reflection , close_sphere.reflection ) 
      Next

      for i As Integer = 0 To 2 Step 3      
        img_pixels[ (((screen_h - py - 1)*screen_w)+ px)-6 ] = _ 
        			(min(max(0, px_color(i+0)), 1) * 255) shl 24 + _
        			(min(max(0, px_color(i+1)), 1) * 255) shl 16 + _
        			(min(max(0, px_color(i+2)), 1) * 255) Shl 8
      Next
    
    Next
  
  Next
End Sub
