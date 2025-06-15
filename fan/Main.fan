using fwt
using gfx
@Js
class Main
{
  Landmark[] landmarks := Landmark[,]
  static const Size startWindowSize:=Size(800,600)
  static Void main()
  {
    //dirs() 
    echo ("SVG Map Maker")
    m:=Main()
    m.start
  }

  Void start()
  {
    svgFile := File("file:///C:/Users/homel/OneDrive/Documents/SVGMapMaker/PriceRealm/overworld.svg".toUri)
    browser := WebBrowser.make
    browser.load("file:///C:/Users/homel/OneDrive/Documents/SVGMapMaker/PriceRealm/index.html".toUri)
    Window{
    size=startWindowSize
    title="SVG Map Maker"
    content = EdgePane{center = SashPane{LandmarkEditor(browser, svgFile),EdgePane{center=browser},}}
   }.open 
  }

  Widget LandmarkEditor(WebBrowser browser, File svgFile){
    renderer := MapRenderer.make 
    //## SVG Tab
    svgButtons :=InsetPane{Label{text="example3"},Button{text="example4"}}
    svgText := Text{
      multiLine = true
      font = Desktop.sysFontMonospace
      text =""
    }

    //Conversion GO Time
    UpdateSVGText := |Landmark[] marks|{
      //Encode SVG
      Str svgEncoded := renderer.renderSvg(marks)
      //Update text widget to display encoded svg
      svgText->text = svgEncoded
      //Also write encouded svg to file
      svgFile.out.printLine(svgEncoded).close
      //and refresh web browser
      browser.refresh
    }
    svgTab := Tab{text=".SVG"; EdgePane{top=svgButtons;center=svgText},}

     //## Table (Data Model)/validation tab
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
      UpdateSVGText(marks)
      table.refreshAll
    }
    table.onAction.add |e| {echo("Something happend; ${e}")}
    //table.onAction.add |e| {echo("..updating table"); updateTable(this->landmarks) }
    tableTab := Tab{text="Table"; InsetPane{table,},}

    //## CSV Tab
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
        "# Format: Name, X, Y, Z, color, Shape\n"+
        "# River's House, 344, 64, 571, #FF00FF, circle\n"+
        "World Spawn, 267, 66, 547, 	#808080, diamond\n"+
        "#Nolan's House, 279, 66, 622, #0000FF, circle\n"+
        "#Gramdma's House, 495, 71, 831, #800080, circle\n"+
        "Lava Pillar Village, 862, 63, 854, #FF0000, circle\n"+
        "Water Pillar Village, 1225, 62, 656, #0000FF, circle\n"+
        "Cat Village, -272, 68,  1902, #8b4513, circle\n"+
        "Iceland/NetherKeep, 454, 74, -2768, #0000FF, diamond\n"+
        "CooCoo Land, -790, 43, -1959, #ff7f50, circle\n"+
        "Safety Zone Mining Camp, -126, 79, 1588, #800080, square\n"+
        "Haunted Village by Pillage Tower1 (looted), 1768, 71, 2033, #55ff55, circle\n"+
        "Broken Portal by Pillage Tower2 (looted), 1962, 66, 2726, #55ff55, circle\n"+
        "Spruce Forest Pillage Tower3, 1831, 64, 3920, #ff0f0f, circle\n"+
        "Acai Village Pillage Tower4, 1770, 65, 5622,  #ff2f2f, circle\n"
    }
    csvButtons := InsetPane{Button{text="Convert to Data Model";onAction.add {ProcessLandmarks(csvText.text)}},}
    csvTab := Tab{text=".CSV"; EdgePane{top=csvButtons;center=csvText},}
   
    
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

  static Void dirs()
  {
    echo("\n--- Variables ---")
    map := Env.cur.vars
    map.each |v, k| { show(v, k) }
   
    echo("\n--- Directories ---")
    Str userDir :=map["user.dir"]
    show(userDir,"User Directory")

    File[] toTest := [Env.cur.homeDir, Env.cur.tempDir, Env.cur.workDir, File(userDir.toUri)]
    toTest.each |dir|{
      show(dir,"\n[using ${dir}]")
      show(dir.isDir,  "dir.isDir")
      // list all files in a directory (files and dirs)
      show(dir.list, "dir.list")
      // list file names in a directory
      show(dir.list.map |f->Str| { f.name }, "dir.list mapped to names")
      // get sub directories (filter out files)
      show(dir.list.findAll |f| { f.isDir }, "list sub-directories hard way")
      show(dir.listDirs,                     "list sub-directories easy way")
    }
  }  

  static Void show(Obj? result, Str what)
  {
    resultStr := "" + result
    if (resultStr.size > 100) resultStr = resultStr[0..100] + "..."
    echo(what.padr(40) + " => " + resultStr)
  }
}