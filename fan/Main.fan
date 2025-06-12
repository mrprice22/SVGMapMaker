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

     //Table (Data Model)/validation tab
     table := Table {
      multi = true
      model = LandmarkTableModel {it.landmarks = this.landmarks}
      onAction.add |e| { echo(e) }
      onSelect.add |e| { echo(e); echo("selected=${e->widget->selected}") }
      //onPopup.add |e|  { echo(e); e.popup = makePopup }
      // onMouseMove.add |e| { Int? row := e->widget->rowAt(e.pos); Int? col := e->widget->colAt(e.pos); echo("Row: $row Col: $col " + ((row != null && col != null) ? e->widget->model->text(col, row) : "")) }
      // hbar.onModify.add |e| { onScroll("Tree.hbar", e) }
      // vbar.onModify.add |e| { onScroll("Tree.vbar", e) }
    }

    updateTable := |Landmark[] marks| {
      table.model->landmarks = marks
      table.refreshAll
    }
    table.onAction.add |e| {echo("Something happend; ${e}")}
    //table.onAction.add |e| {echo("..updating table"); updateTable(this->landmarks) }

    tableTab := Tab{text="Table"; InsetPane{table,},}

    //CSV Tab
     ProcessLandmarks := |Str csv|  {
      landmarks.clear
      lines := csv.splitLines
      echo("${lines->size} lines found")
      lines.each |line|{
        lm := Landmark.fromStr(line)
        if(lm != null)
          landmarks.add(lm)
      }
      updateTable(landmarks)
    }
    csvText := Text {
      multiLine = true
      font = Desktop.sysFontMonospace
      text =
        "# Format: Name, X, Y, Z, Color, Shape\n"+
        "# River's House, 344, 64, 571, Pink, circle\n"+
        "World Spawn, 267, 66, 547, Gray, diamond\n"+
        "Nolan's House, 279, 66, 622, Blue, circle\n"+
        "Gramdma's House, 495, 71, 831, Purple,circle\n"+
        "Lava Pillar Village, 862, 63, 854, Red, circle\n"+
        "Water Pillar Village, 1225, 62, 656, Blue, circle\n"+
        "Cat Village, -272, 68,  1902, Brown, circle\n"+
        "Iceland/NetherKeep, 454, 74, -2768, Blue, diamond\n"+
        "CooCoo Land, -790, 43, -1959, Orange, circle\n"
    }
    csvButtons := InsetPane{Button{text="Convert to Data Model";onAction.add {ProcessLandmarks(csvText.text)}},}
    csvTab := Tab{text=".CSV"; EdgePane{top=csvButtons;center=csvText},}
   
   

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
    tabPane := TabPane{csvTab,tableTab,svgTab}
    tabPane.onSelect.add |e| {
      echo("tab selected: ${e.index}")
      if(e.index ==1){
        updateTable(landmarks)
      }
    } 
    return tabPane
    
  }


  
}