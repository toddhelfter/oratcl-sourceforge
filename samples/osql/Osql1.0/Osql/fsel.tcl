proc selectFile { w } {
  if { [itcl_info objects $w] != "$w" } {
    FileSelector $w -title "OSQL File Selector"
  }
  return [$w display]
}
