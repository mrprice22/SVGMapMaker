using gfx
using fwt

enum class Shape{
  circle,
  square,
  diamond,
  triangle
}

class Landmark{
    Str name
    Int x
    Int y
    Int z
    Color color
    Str? notes
    Shape shape
    static const Int expectedParams := 6
    new make(Str name, Int x, Int y, Int z, Color c, Shape shape){
      this.name = name
      this.x = x
      this.y = y
      this.z = z
      this.color = c
      this.shape = shape
      echo ("created landmark ${name} @ (${x},${y},${z}): ${color}")
    }

   
    static Landmark? fromStr(Str csvLine){
      //Format: Name, X, Y, Z, Color, Shape
      params := csvLine.split(',').map |Str s -> Str| {return s.trim}
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
      } else if (size < expectedParams){
        //Skip if missing expected numbar of params
        echo("unexpected number of params for input line: ${csvLine}")
        return null
      }else{
        //Attempt to parse 
        try{
        Str name := "Defaulto"; try{ name = params[0]}catch (Err e){echo("Unable to convert '${params[4]}' to a name, defaulting to Defaulto: ${e.traceToStr}")}
        Int x := Int.fromStr(params[1])
        Int y := Int.fromStr(params[2])
        Int z := Int.fromStr(params[3])
        color := Color.black; try{color= Color.fromStr(params[4])}catch (Err e){echo("Unable to convert '${params[4]}' to a color, defaulting to black: ${e.traceToStr}")}
        shape := Shape.circle; try{shape = Shape.fromStr(params[5])}catch (Err e){echo("Unable to convert '${params[5]}' to a shape, defaulting to circle: ${e.traceToStr}")}
        return Landmark.make(name,x,y,z,color, shape)  
        }
        catch (Err e){
          echo ("Err Parsing Landmark '${csvLine}': ${e.traceToStr}")
          return null
        } 
      }  
    }
  }

  class LandmarkTableModel : TableModel{
    Landmark[]? landmarks
    Str[] headers := ["Name", "X", "Y","Z","Color","Shape"]
    override Int numCols() { return 6 }
    override Int numRows() { return landmarks.size }
    override Str header(Int col) { return headers[col] }
    override Halign halign(Int col) { return (col >= 1 && col <=3) ? Halign.right : Halign.left }
    override Font? font(Int col, Int row) { return (col >= 1 && col<=3) ? Font {name=Desktop.sysFont.name; size=Desktop.sysFont.size-1} : null }
    override Color? fg(Int col, Int row)  { return (col >= 1 && col<=3) ? Color("#666") : null }
    override Color? bg(Int col, Int row)  { return col == 4 ? landmarks[row].color : null }
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
        case 5:  return f.shape.toStr
        default: return "?"
      }
    }
    override Int sortCompare(Int col, Int row1, Int row2)
    {
      a := landmarks[row1]
      b := landmarks[row2]
      switch (col)
      {
        case 1:  return a.x <=> b.x
        case 2:  return a.y <=> b.y
        case 3:  return a.z <=> b.z
        default: return super.sortCompare(col, row1, row2)
      }
    }
    /*override Image? image(Int col, Int row)
    {
      if (col != 0) return null
      return dir[row].isDir ? demo.folderIcon : demo.fileIcon
    }*/
}

class MapRenderer{
    Int width := 1000
    Int height := 1000
    Int padding := 125
    Float zoom := 1.0f
    Float minX
    Float maxX
    Float minZ
    Float maxZ

    Str renderSvg(Landmark[] landmarks) {
      if (landmarks.isEmpty)
        throw Err("No landmarks provided")
        
        calculateZoom(landmarks)
        svg := StrBuf()
        svg.add("<svg xmlns='http://www.w3.org/2000/svg' width='${width}' height='${height}'>\n")
        landmarks.each |l| {
          Int x := ((l.x.toFloat - minX) * zoom + padding).toInt
          Int y := (height.toFloat - ((l.z.toFloat - minZ) * zoom + padding)).toInt
          Str shape := l.shape.name
          Str color := l.color.toStr
          Str safeName := l.name
          switch (shape) {
    case "square":
        svg.add("<rect x='${x - 5}' y='${y - 5}' width='10' height='10' fill='${color}'>")
           .add("<title>${safeName} (X=${l.x}, Y=${l.y}, Z=${l.z})</title>")
           .add("</rect>\n")
    case "triangle":
        svg.add("<polygon points='${x},${y - 6} ${x - 6},${y + 5} ${x + 6},${y + 5}' fill='${color}'>")
           .add("<title>${safeName} (X=${l.x}, Y=${l.y}, Z=${l.z})</title>")
           .add("</polygon>\n")
    case "diamond":
        svg.add("<polygon points='${x},${y - 6} ${x - 6},${y} ${x},${y + 6} ${x + 6},${y}' fill='${color}'>")
           .add("<title>${safeName} (X=${l.x}, Y=${l.y}, Z=${l.z})</title>")
           .add("</polygon>\n")
    default:
        svg.add("<circle cx='${x}' cy='${y}' r='6' fill='${color}'>")
           .add("<title>${safeName} (X=${l.x}, Y=${l.y}, Z=${l.z})</title>")
           .add("</circle>\n")
}

svg.add("<text x='${x + 8}' y='${y + 4}' font-size='12' fill='black'>${safeName}</text>\n")
        }

        svg.add("</svg>\n")
        return svg.toStr
    }

    private Void calculateZoom(Landmark[] landmarks) {
        minX = (landmarks.min |Landmark l1, Landmark l2 -> Int| {return l1.x <=> l2.x}).x.toFloat
        maxX = (landmarks.max |Landmark l1, Landmark l2 -> Int| {return l1.x <=> l2.x}).x.toFloat
        minZ = (landmarks.min |Landmark l1, Landmark l2 -> Int| {return l1.z <=> l2.z}).z.toFloat
        maxZ = (landmarks.max |Landmark l1, Landmark l2 -> Int| {return l1.z <=> l2.z}).z.toFloat
       
        Float rangeX := maxX - minX
        Float rangeZ := maxZ - minZ

        if (rangeX == 0.0f || rangeZ == 0.0f)
            throw Err("Landmarks do not form a valid range for scaling.")

        Float scaleX := (width - 2 * padding).toFloat / rangeX
        Float scaleZ := (height - 2 * padding).toFloat / rangeZ

        zoom = scaleX.min(scaleZ)
    }
}

