# ----------------------------------------------------------------------
#  PURPOSE:  Handling counter operations via [incr Tcl].
#
#   AUTHOR:  Michael J. McLennan       Phone: (215)770-2842
#            AT&T Bell Laboratories   E-mail: aluxpo!mmc@att.com
#
#     SCCS:  @(#)counter.tcl	1.1 (7/22/93)
# ----------------------------------------------------------------------
#            Copyright (c) 1993  AT&T  All Rights Reserved
# ======================================================================

# ----------------------------------------------------------------------
#  Simple "counter" class
# ----------------------------------------------------------------------
itcl_class Counter {
    constructor {config} {
      set count $initvalue
    }
    method config {config} {}

    method value {} {
        return $count
    }
    method ++ {{val unspec}} {
        if {$val == "unspec"} {set val $by}
        return [+= $val]
    }
    method -- {{val unspec}} {
        if {$val == "unspec"} {set val $by}
        return [-= $val]
    }
    method += {val} {
        return [set count [expr $count+$val]]
    }
    method -= {val} {
        return [set count [expr $count-$val]]
    }
    method reset { } {
      return [set count $initvalue]
    }
    method = {val} {
      return [set count $val]
    }
    public by 1
    public initvalue 0
    protected count 0
}

# ----------------------------------------------------------------------
#  Add multiplying behavior to "counters"
# ----------------------------------------------------------------------
itcl_class Multiplier {
    inherit Counter

    constructor {config} {}
    method config {config} {}

    method ** {{val unspec}} {
        if {$val == "unspec"} {set val $by}
        return [*= $val]
    }
    method *= {val} {
        set count [expr $count*$val]
        return $count
    }
    method // {{val unspec}} {
        if {$val == "unspec"} {set val $by}
        return [/= $val]
    }
    method /= {val} {
        set count [expr $count/$val]
        return $count
    }
}

# ----------------------------------------------------------------------
#  Example usages
# ----------------------------------------------------------------------

# counter c -by 2
# c ++
# c += 2
# c config -by 1
# c ++

# multiplier m -by 2
# m ++
# m **
# m *= 3
# m --
