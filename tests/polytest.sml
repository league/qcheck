PolyML.Compiler.printTypesWithStructureName := false;
PolyML.print_depth 0;
OS.FileSys.chDir "src";
PolyML.make "QCheck";
OS.FileSys.chDir "../tests";
use "from-to-str.sml";
use "from-to-poly.sml";
use "reverse.sml";
use "compose.sml";
