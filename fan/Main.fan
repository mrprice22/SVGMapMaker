using fwt
using gfx
@Js
class Main
{
  Landmark[] landmarks := Landmark[,]
  static const Size startWindowSize:=Size(800,600)
  static Void main()
  {
    echo ("SVG Map Maker")
     m:=Main()
     m.start
  }

  Void start()
  {
   Window{
    size=startWindowSize
    title="SVG Map Maker"
    content = EdgePane{center = SashPane{LandmarkEditor, Label{text = "right"},}
    }
   }.open 
  }

  Widget LandmarkEditor(){
    //CSV Tab
    

     ProcessLandmarks := |Str csv|{
      landmarks.clear
      lines := csv.splitLines
      echo("${lines->size} lines found")
      lines.each |line|{
        lm := Landmark.fromStr(line)
        if(lm != null)
          landmarks.add(lm)
      }
      
    }
    csvText := Text
    {
      multiLine = true
      font = Desktop.sysFontMonospace
      text =
        "# Format: Name, X, Y, Z, Color, Shape\n"+
        "# River's House, 344, 64, 571, pink, circle\n"+
        "World Spawn, 267, 66, 547, gray, diamond\n"+
        "Nolan's House, 279, 66, 622, blue, circle\n"+
        "Gramdma's House, 495, 71, 831, purple,circle\n"+
        "Lava Pillar Village, 862, 63, 854, red, circle\n"+
        "Water Pillar Village, 1225, 62, 656, blue, circle\n"+
        "Cat Village, -272, 68,  1902, brown, circle\n"+
        "Iceland/NetherKeep, 454, 74, -2768, blue, diamond\n"+
        "CooCoo Land, -790, 43, -1959, orange, circle\n"
    }
    
    csvButtons := InsetPane{Button{text="Convert to Data Model";onAction.add {ProcessLandmarks(csvText.text)}},}
    csvTab := Tab{text=".CSV"; EdgePane{top=csvButtons;center=csvText},}
   
    //Table (Data Model)/validation tab
     table := Table
    {
      multi = true
      model = LandmarkTableModel {it.landmarks = this.landmarks}
      onAction.add |e| { echo(e) }
      onSelect.add |e| { echo(e); echo("selected=${e->widget->selected}") }
      //onPopup.add |e|  { echo(e); e.popup = makePopup }
      // onMouseMove.add |e| { Int? row := e->widget->rowAt(e.pos); Int? col := e->widget->colAt(e.pos); echo("Row: $row Col: $col " + ((row != null && col != null) ? e->widget->model->text(col, row) : "")) }
      // hbar.onModify.add |e| { onScroll("Tree.hbar", e) }
      // vbar.onModify.add |e| { onScroll("Tree.vbar", e) }
    }
    tableTab := Tab{text="Table"}

    //SVG Tab
    svgButtons :=InsetPane{Label{text="example3"},Button{text="example4"}}
    svgText := Text
    {
      multiLine = true
      font = Desktop.sysFontMonospace
      text =""
    }
    svgTab := Tab{text=".SVG"; EdgePane{top=svgButtons;center=svgText},}
    //Tab Pane
    return TabPane{csvTab,svgTab}
    
  }


  
}