

Function vec_normalize(vec() As Double) As Double 
  Dim As Double norm = 0 
  for i As Integer = 0 To 2         
    Dim As Double v = IIf(vec(i) > 0 , vec(i) , -vec(i) )
    norm += v * v 
  Next

  norm = Sqr(norm) 
  for i As Integer = 0 To 2        
    vec(i) /= norm 
  Next

  return norm 
End Function

Function vec_dot(a() As Double , b() As Double) As Double 
  Dim As Double dot = 0 
  for i As Integer = 0 To 2       
    dot += a(i) * b(i) 
  Next

  return dot 
End Function
