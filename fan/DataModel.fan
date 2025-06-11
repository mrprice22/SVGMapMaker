using gfx
class Landmark{
    Str text
    Int x
    Int y
    Int z
    Color color
    Str? notes
    Str? shape
    new make(Str name, Int x, Int y, Int z, Color c){
      this.text = name
      this.x = x
      this.y = y
      this.z = z
      this.color = c
      echo ("created landmark ${name}")
    }

    static Landmark? fromStr(Str csvLine){
      params := csvLine.split(',')
      Int size := params.size
      if (size != 6){
        echo("unexpected number of params for input line: ${csvLine}")
        return null
      } else{

        //echo ("Parsing Params:")
        //params.each |p|{echo(p)}
        
        try{
        Str name := params[0]
        Int x := Int.fromStr(params[1])
        Int y := Int.fromStr(params[2])
        Int z := Int.fromStr(params[3])
        color := Color.black
        Str shape := params[5]
        return Landmark.make(name,x,y,z,color)  
        }
        catch (Err e){
          echo ("Skipping landmark ${csvLine}")
          return null
        }
        
      }
   
    }
  }