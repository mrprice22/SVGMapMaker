using gfx
class Landmark{
    Str text
    Int x
    Int y
    Int z
    Color color
    Str? notes
    new make(Str name, Int x, Int y, Int z, Color c){
      this.text = name
      this.x = x
      this.y = y
      this.z = z
      this.color = c
    }
  }