using fwt
using gfx
@Js
class Main
{
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
    content = EdgePane{
      center = SashPane{
        //weights = [1,3]
        LandmarkEditor,
        Label{text = "right"},
      }
    }
   }.open 
  }

  Widget LandmarkEditor(){
    //CSV Tab
    csvButtons := InsetPane{Label{text="example1"},Button{text="example2"}}
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
    csv := Tab{text=".CSV"; EdgePane{top=csvButtons;center=csvText},}
    //SVG Tab
    svgButtons :=InsetPane{Label{text="example3"},Button{text="example4"}}
    svgText := Text
    {
      multiLine = true
      font = Desktop.sysFontMonospace
      text =""
    }
    svg := Tab{text=".SVG"; EdgePane{top=svgButtons;center=svgText},}
    //Tab Pane
    return TabPane{csv,svg}
    
  }
}