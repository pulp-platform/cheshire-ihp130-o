Footprint library {
  types {
    sig_io sg13g2_pad_io
    sig_io_pd sg13g2_pad_io_pd
    sig_io_pu sg13g2_pad_io_pu
    sig_i sg13g2_pad_in
    vdd_core vddcore
    vss_core gndcore
    vdd_pad vddpad
    vss_pad gndpad
    corner sg13g2_pad_corner
    fill {sg13g2_pad_fill_10 sg13g2_pad_fill_4 sg13g2_pad_fill_2 sg13g2_pad_fill_1}
  }

  connect_by_abutment {
    VSSPAD
    VSSCORE
    VDDCORE
    VDDPAD
  }

  pad_pin_name pad_io
  pad_pin_layer TopMetal2

  cells {
    sg13g2_pad_io {
      cell_name sg13g2_pad_io
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }
    sg13g2_pad_io_pd {
      cell_name sg13g2_pad_io_pd
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }
    sg13g2_pad_io_pu {
      cell_name sg13g2_pad_io_pu
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }
    sg13g2_pad_in {
      cell_name sg13g2_pad_in
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }

    vddcore {
      cell_name sg13g2_pad_vddco
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    gndcore {
      cell_name sg13g2_pad_gndco
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    vddpad {
      cell_name sg13g2_pad_vddio
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    gndpad {
      cell_name sg13g2_pad_gndio
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }

    corner {
      cell_name sg13g2_pad_corner
      physical_only 1
      offset {0 0}
      orient {ll R270 lr R0 ur R90 ul R180}
    }

    sg13g2_pad_fill_10 {
      cell_name sg13g2_pad_fill_10
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    sg13g2_pad_fill_4 {
      cell_name sg13g2_pad_fill_4
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    sg13g2_pad_fill_2 {
      cell_name sg13g2_pad_fill_2
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    sg13g2_pad_fill_1 {
      cell_name sg13g2_pad_fill_1
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }

  }
}
