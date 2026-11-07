# Interactive Purchase Order ALV Report (SAP ABAP)

An interactive ALV report for reviewing Purchase Orders in SAP, built as a hands-on project after learning ALV Grid. It combines header, item, vendor, and material data, adds visual cues and drill-down, and lets users flag rows and save comments to a custom Z table.

## Features

- **Selection screen** with select-options for PO Number (`EBELN`), Vendor (`LIFNR`), and Document Date (`BEDAT`)
- **Dynamic default date range:** the date filter is pre-filled in `INITIALIZATION` with the first and last day of the previous month
- **Input validation** in `AT SELECTION-SCREEN` (at least a PO Number or a Vendor is required)
- **Open SQL join** across `EKKO`, `EKPO`, `LFA1`, and `MAKT` (INNER and LEFT OUTER JOINs, material descriptions in English)
- **Header-level aggregation:** item count and total quantity per Purchase Order
- **Color-coded quantities** using a color table (`LVC_S_SCOL`) based on thresholds:

  | Total Quantity | Color |
  |---|---|
  | up to 1,000 | Color 6 |
  | up to 10,000 | Color 3 |
  | above 10,000 | Color 5 |

- **Drill-down:** clicking the PO number (hotspot, `&IC1`) opens a secondary ALV with the PO items
- **Editable columns:** Checkbox (`CHK`) and Comment (`COMMENT`)
- **Persistence:** selected rows are saved to `ZTA_PO_SAVED` using `MODIFY`, with audit fields (user, date, time)
- **User feedback** via status messages for success, error, and empty selection


## Project Structure

| Object | Type | Description |
|---|---|---|
| `ZALV_SHIPMENT_PRO` | Report | Main program (flow control, data retrieval, ALV display, user commands) |
| `ZALV_SHIPMENT_PRO_DEF` | Include | Selection screen, type definitions, and global data |
| `ZTA_PO_SAVED` | Transparent table | Stores saved PO rows and comments |

### Program Flow

```
INITIALIZATION (default date range)
      |
      v
AT SELECTION-SCREEN (validation)
      |
      v
START-OF-SELECTION
      |
build_field_catalog --> get_data --> display_data (main ALV)
                                           |
                               user_command (callback)
                                |                  |
                        Hotspot (&IC1)       Save (&DATA_SAVE)
                                |                  |
                      Items ALV (drill-down)  ZTA_PO_SAVED
```

## Table `ZTA_PO_SAVED`

| Field | Key | Data Element | Type | Length | Description |
|---|---|---|---|---|---|
| `MANDT` | ✔ | `MANDT` | CLNT | 3 | Client |
| `EBELN` | ✔ | `EBELN` | CHAR | 10 | Purchasing Document Number |
| `LIFNR` | | `LIFNR` | CHAR | 10 | Account Number of Supplier |
| `ITEM_COUNT` | | `INT4` | INT4 | 10 | Number of items in the PO |
| `TOTAL_QTY` | | `BSTMG` | QUAN | 13,3 | Total PO quantity |
| `SAVED_DATE` | | `DATUM` | DATS | 8 | Save date (`SY-DATUM`) |
| `SAVED_TIME` | | `UZEIT` | TIMS | 6 | Save time (`SY-UZEIT`) |
| `SAVED_USER` | | `UNAME` | CHAR | 12 | User who saved (`SY-UNAME`) |
| `COMMENTS` | | `CHAR100` | CHAR | 100 | User comment |

> Saving the same PO again overwrites its record (`MODIFY` on the key `MANDT` + `EBELN`).

## Technical Highlights

- ALV via `REUSE_ALV_GRID_DISPLAY` with a manually built Field Catalog
- Callback event `USER_COMMAND` handling both hotspot click and save
- Cell coloring through `coltab_fieldname` in the layout
- Dynamic date defaults calculated in `INITIALIZATION`
- Modular code using `INCLUDE` and `FORM` routines

## How to Run

1. Create the table `ZTA_PO_SAVED` in SE11 (fields as above) and activate it.
2. Create the include `ZALV_SHIPMENT_PRO_DEF` and the report `ZALV_SHIPMENT_PRO`, then paste the code.
3. Activate all objects.
4. Run the report from SE38 or T-Code : ZALV_PRO .
5. Enter a PO number and/or vendor, adjust the date range if needed, then execute.

**Requirements:** SAP system with MM data (`EKKO`, `EKPO`, `LFA1`, `MAKT`) and ABAP 7.40 or higher (inline declarations and new Open SQL syntax).

## Planned Improvements

- [ ] Migrate to OO ALV (`CL_SALV_TABLE` / `CL_GUI_ALV_GRID`)
- [ ] Add authorization checks (`AUTHORITY-CHECK`)
- [ ] Move messages to Text Elements (multi-language support)
- [ ] Add sorting and default layout variants

## What I Learned

- How the Field Catalog, Layout, and callback events work together in ALV
- Building a drill-down using hotspot and `USER_COMMAND`
- Making ALV columns editable and persisting the changes to a custom table
- Handling selection-screen defaults and validation
- Structuring a report with includes and forms

## Author

**[Mohamed Ahmed Abdelwahab]**
[[LinkedIn](https://www.linkedin.com/in/mohamed-abdelwahab-a14a20241/) | [mohamedahmed501366@gmail.com]
