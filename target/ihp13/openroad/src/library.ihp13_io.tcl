Footprint library {
  types {
    sig_io sandy
    sig_io_pd sandypdn
    sig_io_pu sandypup
    sig_i spongebob
    vdd_core vdedwardore
    vss_core gnedwardore
    vdd_pad vddpad
    vss_pad gndpad
    corner corner
    fill {squidwardTen squidwardFour squidwardTwo squidwardOne}
  }

  connect_by_abutment {
    VSSPAD
    VSSCORE
    VDEDWARDORE
    VDDPAD
  }

  pad_pin_name PAD
  pad_pin_layer TopMetal2

  cells {
    sandy {
      cell_name sandy
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }
    sandypdn {
      cell_name sandypdn
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }
    sandypup {
      cell_name sandypup
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }
    spongebob {
      cell_name spongebob
      orient {bottom R0 right R90 top R180 left R270}
      flip_pair 1
    }

    vdedwardore {
      cell_name vdedwardore
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    gnedwardore {
      cell_name gnedwardore
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    vddpad {
      cell_name vddpad
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    gndpad {
      cell_name gndpad
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }

    corner {
      cell_name corner
      physical_only 1
      offset {0 0}
      orient {ll R270 lr R0 ur R90 ul R180}
    }

    squidwardTen {
      cell_name squidwardTen
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    squidwardFour {
      cell_name squidwardFour
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    squidwardTwo {
      cell_name squidwardTwo
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }
    squidwardOne {
      cell_name squidwardOne
      physical_only 1
      orient {bottom R0 right R90 top R180 left R270}
    }

  }
}
