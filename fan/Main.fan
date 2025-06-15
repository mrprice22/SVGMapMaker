using fwt
using gfx
@Js
class Main
{
  Landmark[] landmarks := Landmark[,]
  static const Size startWindowSize:=Size(1400,900)
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
    csvFile := File("file:///C:/Users/homel/OneDrive/Documents/SVGMapMaker/PriceRealm/landmarks.txt".toUri) 
    browser := WebBrowser.make
    browser.load("file:///C:/Users/homel/OneDrive/Documents/SVGMapMaker/PriceRealm/index.html".toUri)
    Window window := Window{
    size=startWindowSize
    title="SVG Map Maker"
    content = EdgePane{center = SashPane{weights=[1,2];LandmarkEditor(browser, svgFile, csvFile),EdgePane{center=browser},}}
   }.open 
   
  }

  Widget LandmarkEditor(WebBrowser browser, File svgFile, File csvFile){
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
    //Event when button is clicked to process csv landmarks
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
      csvFile.out.printLine(csv).close //save csv to local diskm
    }
    csvText := Text {
      multiLine = true
      font = Desktop.sysFontMonospace
      text = csvFile.readAllStr
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