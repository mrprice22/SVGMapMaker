using gfx
using fwt

class Landmark{
    Str name
    Int x
    Int y
    Int z
    Color color
    Str? notes
    Str? shape
    new make(Str name, Int x, Int y, Int z, Color c){
      this.name = name
      this.x = x
      this.y = y
      this.z = z
      this.color = c
      echo ("created landmark ${name} @ (${x},${y},${z}): ${color}")
    }

    static Landmark? fromStr(Str csvLine){
      //Format: Name, X, Y, Z, Color, Shape
      params := csvLine.split(',')
      Int size := params.size
      //Basic input validation
      if(csvLine.trim().size ==0){
        //blank rows
        echo("Skipping blank row of data")
        return null
      } else if (csvLine.trim()[0..0]=="#"){
        //Ignore comments
        echo ("Skipping Row becuase commented out with # char")
        return null
      } else if (size < 6){
        //Skip if missing expected numbar of params
        echo("unexpected number of params for input line: ${csvLine}")
        return null
      }else{
        //Attempt to parse 
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
          echo ("Parse Err: Skipping landmark ${csvLine}")
          return null
        }
        
      }
   
    }
  }

  class LandmarkTableModel : TableModel
{
  Landmark[]? landmarks
  Str[] headers := ["Name", "X", "Y","Z","Color","Shape"]
  override Int numCols() { return 6 }
  override Int numRows() { return landmarks.size }
  override Str header(Int col) { return headers[col] }
  override Halign halign(Int col) { return col == 1 ? Halign.right : Halign.left }
  override Font? font(Int col, Int row) { return col == 2 ? Font {name=Desktop.sysFont.name; size=Desktop.sysFont.size-1} : null }
  override Color? fg(Int col, Int row)  { return col == 2 ? Color("#666") : null }
  override Color? bg(Int col, Int row)  { return col == 2 ? Color("#eee") : null }
  override Str text(Int col, Int row)
  {
    f := landmarks[row]
    switch (col)
    {
      case 0:  return f.name
      case 1:  return f.x.toStr //f.size?.toLocale("B") ?: ""
      case 2:  return f.y.toStr
      case 3:  return f.z.toStr
      case 4:  return f.color.toStr
      case 5:   return f.shape
      default: return "?"
    }
  }
  override Int sortCompare(Int col, Int row1, Int row2)
  {
    a := landmarks[row1]
    b := landmarks[row2]
    switch (col)
    {
      //case 1:  return a.size <=> b.size
      //case 2:  return a.modified <=> b.modified
      default: return super.sortCompare(col, row1, row2)
    }
  }
  /*override Image? image(Int col, Int row)
  {
    if (col != 0) return null
    return dir[row].isDir ? demo.folderIcon : demo.fileIcon
  }*/
}