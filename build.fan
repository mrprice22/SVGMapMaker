using build

class Build : build::BuildPod
{
  new make()
  {
    podName = "SVGMapMaker"
    summary = "Make simple maps from a list of landmarks using SVG"
    depends = ["sys 1.0.79+", "fwt 1.0.79+","gfx 1.0.79+", "concurrent 1.0.79+"]
    srcDirs = [`fan/`]
  }

  @Target { help = "build testSys pod as a single JAR dist" }
  override Void test()
  {
    dist := JarDist(this)
    dist.outFile = `./testSys.jar`.toFile.normalize
    dist.podNames = Str["concurrent", "testSys"]
    dist.mainMethod = "[java]fanx.tools::Fant.fanMain"
    dist.run
  }
  @Target { help = "build FWT test app as JAR; must put swt.jar into classpath!" }
  Void jar()
  {
    dist := JarDist(this)
    dist.outFile = `./SVGMapMaker.jar`.toFile.normalize
    dist.podNames = Str["SVGMapMaker", "gfx", "fwt", "concurrent"]
    dist.mainMethod = "SVGMapMaker::Main.main"
    dist.run

    // test example:
    // java -cp lib\java\ext\win32-x86_64\swt.jar;SVGMapMaker.jar fanjardist.Main
  }
}