# 
# cleanup.tcl
#
# Finalize the tests.
#
# Copyright (c) 2000 Todd M. Helfter
# All rights reserved.

puts "\n\ncleaning up oratcl test objects"
puts "\t(dropping table and procedures, deleting test file)"

catch {drop_table}
catch {file delete oratcl.dat}
catch {oralogoff $ora_lda}

# if memory debugging turned on, checkpoint memory usage
catch {checkmem oratcl.mem}
