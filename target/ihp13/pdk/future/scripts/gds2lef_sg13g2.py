# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Thomas Benz <tbenz@iis.ee.ethz.ch>

"""Translates GDS into LEF, only works with small cells"""

import sys
import json
import gdspy

LAYERS = {'Metal1':      (8, 2),
          'Metal2':     (10, 2),
          'Metal3':     (30, 2),
          'Metal4':     (50, 2),
          'Metal5':     (67, 2),
          'TopMetal1': (126, 2),
          'TopMetal2': (134, 2)}

IO_SITE_DIM = '1.00 BY 310.00'

IO_PIN_DIR_OVERWRITE = {'DOUT' : 'OUTPUT',
                        'OEN' : 'INPUT',
                        'DIN' : 'INPUT'
}

IGNORE_LABLES = ['PLUS', 'MINUS', 'nmos', 'pmos', 'BLC_BOT', 'BLC_TOP', 'BLT_BOT', 'BLT_TOP',
                 'RWL', 'LWL', 'BLT', 'BLC_', 'SEL', 'BLT_SEL', 'PRE_N', 'WR_ZERO', 'WR_ONE',
                 'SEL_P', 'VSS', 'VDD', 'A_LWL<15>', 'A_LWL<14>', 'A_LWL<13>', 'A_LWL<12>',
                 'A_LWL<11>', 'A_LWL<10>', 'A_LWL<9>', 'A_LWL<8>', 'A_LWL<7>', 'A_LWL<6>',
                 'A_LWL<5>', 'A_LWL<4>', 'A_LWL<3>', 'A_LWL<2>', 'A_LWL<1>', 'A_LWL<0>',
                 'A_RWL<15>', 'A_RWL<14>', 'A_RWL<13>', 'A_RWL<12>', 'A_RWL<11>', 'A_RWL<10>',
                 'A_RWL<9>', 'A_RWL<8>', 'A_RWL<7>', 'A_RWL<6>', 'A_RWL<5>', 'A_RWL<4>',
                 'A_RWL<3>', 'A_RWL<2>', 'A_RWL<1>', 'A_RWL<0>', 'A_BLT<15>', 'A_BLT<14>',
                 'A_BLT<13>', 'A_BLT<12>', 'A_BLT<11>', 'A_BLT<10>', 'A_BLT<9>', 'A_BLT<8>',
                 'A_BLT<7>', 'A_BLT<6>', 'A_BLT<5>', 'A_BLT<4>', 'A_BLT<3>', 'A_BLT<2>',
                 'A_BLT<1>', 'A_BLT<0>', 'A_BLC<15>', 'A_BLC<14>', 'A_BLC<13>', 'A_BLC<12>',
                 'A_BLC<11>', 'A_BLC<10>', 'A_BLC<9>', 'A_BLC<8>', 'A_BLC<7>', 'A_BLC<6>',
                 'A_BLC<5>', 'A_BLC<4>', 'A_BLC<3>', 'A_BLC<2>', 'A_BLC<1>', 'A_BLC<0>'
                ]


def inside(text_anchor: list, polygon: list) -> bool:
    """Determine if an anchor is inside a polygon"""
    res  = int(polygon[0][0])  <= int(text_anchor[0])
    res &= int(text_anchor[0]) <= int(polygon[2][0])
    res &= int(polygon[0][1])  <= int(text_anchor[1])
    res &= int(text_anchor[1]) <= int(polygon[2][1])
    return res


def format_polygon(polygon: list) -> str:
    """Format a polygon"""
    res  = f'{round(polygon[0][0]/1000.0, 3)} '
    res += f'{round(polygon[0][1]/1000.0, 3)} '
    res += f'{round(polygon[2][0]/1000.0, 3)} '
    res += f'{round(polygon[2][1]/1000.0, 3)}'
    return res


def extract_gds(gds_file: str) -> list:
    """Extract all required data from GDS"""

    gds = gdspy.GdsLibrary(name='chip', infile=gds_file, unit=1e-9, precision=1e-9, units='convert')

    # keep the info on the cells in this dict
    cell_content = {}

    for cell in gds.top_level():

        # calc the size of the cell
        bbox = cell.get_bounding_box()
        cell_width  = round((bbox[1][0] - bbox[0][0]) / 1000.0)
        cell_height = round((bbox[1][1] - bbox[0][1]) / 1000.0)

        # a dict containing all the polygons for each pin and port
        ports = {}

        # get all the polygons from the cell
        all_polygons = cell.get_polygons(by_spec=True)
        # get all labels from the cell
        all_labels = cell.get_labels()

        # report some kind of status
        print(f'[INFO] Working on cell {cell.name}', file=sys.stderr)
        print(f'[INFO] Found {len(all_polygons)} polygons', file=sys.stderr)
        print(f'[INFO] Found {len(all_labels)} labels', file=sys.stderr)

        # drop some labels
        filtered_labels = []
        for lbl in all_labels:
            if lbl.text not in IGNORE_LABLES:
                filtered_labels.append(lbl)

        print(f'[INFO] Kept {len(filtered_labels)} labels', file=sys.stderr)

        # do the extraction. Check for every layer if the label anchors match the polygon
        for met in LAYERS:
            layer = LAYERS[met]
            print(f'[INFO] Analyzing {met}, {layer}', file=sys.stderr)
            if layer in all_polygons:
                for polygon in all_polygons[layer]:
                    for label in all_labels:
                        if inside(label.position, polygon) and label.layer == layer[0]:
                            # construct the output dict
                            if label.text not in ports:
                                ports[label.text] = {}
                            if met not in ports[label.text]:
                                ports[label.text][met] = []
                            ports[label.text][met].append(format_polygon(polygon))
        # add info
        cell_content[cell.name] = {'ports': ports, 'width': cell_width, 'height': cell_height}
    return cell_content


def render_lef(cells: dict, gds_name: str, cell_type: str) -> str:
    """Render the LEF"""
    render = ''

    render += '# Copyright 2023 ETH Zurich and University of Bologna.\n'
    render += '# Solderpad Hardware License, Version 0.51, see LICENSE for details.\n'
    render += '# SPDX-License-Identifier: SHL-0.51\n\n'

    render += '# LEF for the sg13g2_pad library\n'
    render += f'# Automatically generated by {sys.argv[0]}\n'
    render += f'# Extracted from {gds_name}\n\n'

    render += '# Authors:\n'
    render += '# - Thomas Benz <tbenz@iis.ee.ethz.ch>\n\n'

    # render the header
    render += 'VERSION 5.7 ;\n'
    render += 'BUSBITCHARS "<>" ;\n'
    render += 'DIVIDERCHAR "/" ;\n\n'

    render += 'PROPERTYDEFINITIONS\n'
    render += '  MACRO CatenaDesignType STRING ;\n'
    render += 'END PROPERTYDEFINITIONS\n\n'

    if cell_type == 'io':
        render += 'SITE  IOSite\n'
        render += '  CLASS    PAD ;\n'
        render += '  SYMMETRY R90 ;\n'
        render += '  SIZE     {IO_SITE_DIM} ;\n'
        render += 'END  IOSite\n\n'

    for cell in cells:
        ports = cells[cell]['ports']
        # render the port content
        render += f'MACRO {cell}\n'
        if cell_type == 'io':
            if cell.startswith('fill'):
                render +=  '  CLASS PAD_SPACER ;\n'
            else:
                render +=  '  CLASS PAD ;\n'

        render +=  '  ORIGIN 0 0 ;\n'
        render += f'  FOREIGN {cell} 0 0 ;\n'
        render += f'  SIZE {cells[cell]["width"]} BY {cells[cell]["height"]} ;\n'
        render +=  '  SYMMETRY X Y R90 ;\n'
        if cell_type == 'io':
            render +=  '  SITE IOSite ;\n'

        # pins
        for pin in ports:
            render += f'  PIN {pin}\n'
            if pin in IO_PIN_DIR_OVERWRITE:
                render += f'    DIRECTION {IO_PIN_DIR_OVERWRITE[pin]} ;\n'
            else:
                render +=  '    DIRECTION INOUT ;\n'
            if pin.startswith('VDD'):
                render +=  '    USE POWER ;\n'
            elif pin.startswith('VSS'):
                render +=  '    USE GROUND ;\n'
            else:
                render +=  '    USE SIGNAL ;\n'

            # render ports
            for port in ports[pin]:
                render +=  '    PORT\n'
                render += f'      LAYER {port} ;\n'
                for poly in ports[pin][port]:
                    render += f'        RECT {poly} ;\n'
                render +=  '    END\n'
            render += f'  END {pin}\n'

        # obs
        if cell_type == 'io':
            render +=  '  OBS\n'
            for metal in LAYERS:
                render += f'    LAYER {metal} ;\n'
                render += f'      RECT 0 0 {cells[cell]["width"]} {cells[cell]["height"]} ;\n'
            render +=  '  END\n'

        render += f'END {cell}\n\n'



    return render



if __name__ == '__main__':

    _, gds_file = sys.argv

    gds_name = gds_file.split('/')[-1]
    gds_stem = gds_name[:-4]

    extracted_data = extract_gds(gds_file)

    lef = render_lef(extracted_data, gds_name, 'io')

    with open(f'{gds_stem}.json', 'w', encoding='utf-8') as jdf:
        json.dump(extracted_data, jdf, ensure_ascii=True, indent=4)

    with open(f'{gds_stem}.lef', 'w', encoding='utf-8') as leff:
        leff.write(lef)
