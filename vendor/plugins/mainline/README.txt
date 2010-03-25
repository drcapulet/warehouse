Diff::Display
=============

Diff::Display::Unified renders unified diffs into various forms. The output is
based on a callback object that's passed into the renderer

Rewrite of an (unreleased) library by Marcel Molina Jr., who wrote this it 
probably back in 2004 or so.

Usage
======

irb(main):001:0> require 'diff-display'
=> true
irb(main):002:0> diff = <<EOS
irb(main):003:0" diff --git a/History.txt b/History.txt
irb(main):004:0" index 0ed7358..622c384 100644
irb(main):005:0" --- a/History.txt
irb(main):006:0" +++ b/History.txt
irb(main):007:0" @@ -1,4 +1,5 @@
irb(main):008:0"  == 0.0.1 2008-01-28
irb(main):009:0"  
irb(main):010:0" -* 1 major enhancement:
irb(main):011:0" -  * Initial release
irb(main):012:0" +* 2 major enhancements:
irb(main):013:0" +  * The Initial release
irb(main):014:0" +  * stuff added
irb(main):015:0" EOS
...
irb(main):016:0> diff_display = Diff::Display::Unified.new(diff)
=> #<Diff::Display::Unified:0x331c9c @data=...
# Be boring and render it back out as a diff
irb(main):017:0> puts diff_display.render(Diff::Renderer::Diff.new)
diff --git a/History.txt b/History.txt
index 0ed7358..622c384 100644
--- a/History.txt
+++ b/History.txt
@@ -1,4 +1,5 @@
 == 0.0.1 2008-01-28
 
-* 1 major enhancement:
-  * Initial release
+* 2 major enhancements:
+  * The Initial release
+  * stuff added

See Diff::Renderer::Base for what methods your callback needs to implement

Git Repository
===============

http://gitorious.org/projects/diff-display/


License
======

Please see License.txt
