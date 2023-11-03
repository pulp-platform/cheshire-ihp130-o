# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter <phsauter@ethz.ch>

# Some useful functions for floorplaning

#Add Placement blockage
proc add_macro_blockage {negative_padding name1 name2} {
  set block [ord::get_db_block]
  set inst1 [odb::dbBlock_findInst $block $name1]
  set inst2 [odb::dbBlock_findInst $block $name2]
  set bb1 [odb::dbInst_getBBox $inst1]
  set bb2 [odb::dbInst_getBBox $inst2]
  # Find min max of X and Y
  set minx [expr min( [odb::dbBox_xMin $bb1], [odb::dbBox_xMin $bb2]) + [ord::microns_to_dbu $negative_padding]]
  set miny [expr min( [odb::dbBox_yMin $bb1], [odb::dbBox_yMin $bb2]) + [ord::microns_to_dbu $negative_padding]]
  set maxx [expr max( [odb::dbBox_xMax $bb1], [odb::dbBox_xMax $bb2]) - [ord::microns_to_dbu $negative_padding]]
  set maxy [expr max( [odb::dbBox_yMax $bb1], [odb::dbBox_yMax $bb2]) - [ord::microns_to_dbu $negative_padding]]

  set blockage [odb::dbBlockage_create [ord::get_db_block] $minx $miny $maxx $maxy]
  return $blockage
}

# place_macro only allows R0, R180, MX, MY -> doesn't work for us
proc placeInstance { name x y orient } {
  puts "placing $name at {$x $y} $orient"

  set block [ord::get_db_block]
  set inst [$block findInst $name]
  if {$inst == "NULL"} {
    error "Cannot find instance $name"
  }
  
  # ASK: adopted from iguna, why is this necessary?
  if {$orient == "R90"} {
    set orient MX
  }
  if {$orient == "MXR90"} {
    set orient R0
  }

  $inst setLocationOrient $orient
  $inst setLocation [ord::microns_to_dbu $x] [ord::microns_to_dbu $y]
  $inst setPlacementStatus FIRM
}


proc addHaloToBlock {left bottom right top name} {
  set block [ord::get_db_block]
  set inst [odb::dbBlock_findInst $block $name]

  set bbox [odb::dbInst_getBBox $inst]
  set minx [odb::dbBox_xMin $bbox]
  set miny [odb::dbBox_yMin $bbox]
  set maxx [odb::dbBox_xMax $bbox]
  set maxy [odb::dbBox_yMax $bbox]

  set minx [expr $minx - [ord::microns_to_dbu $left]]
  set miny [expr $miny - [ord::microns_to_dbu $bottom]]
  set maxx [expr $maxx + [ord::microns_to_dbu $right]]
  set maxy [expr $maxy + [ord::microns_to_dbu $top]]
}