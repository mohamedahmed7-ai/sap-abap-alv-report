*&---------------------------------------------------------------------*
*& Include          ZALV_SHIPMENT_PRO_DEF
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZALV_SHIPMENT_PRO_DEF
*&---------------------------------------------------------------------*
TABLES: ekko.

SELECT-OPTIONS: PO_Num FOR ekko-ebeln,
                Vendor FOR ekko-lifnr,
                Date FOR ekko-bedat.

  IF PO_Num[] IS INITIAL AND PO_Num[] IS INITIAL.
    MESSAGE 'Please enter at least PO Number or Vendor' TYPE 'E'.
  ENDIF.


INITIALIZATION.
  DATA: FIRST_DAY TYPE D,
        LAST_DAY  TYPE D.

  FIRST_DAY = sy-datum.
  FIRST_DAY+6(2) = '01'.
  LAST_DAY  = FIRST_DAY - 1.

  FIRST_DAY = LAST_DAY.
  FIRST_DAY+6(2) = '01'.

  Date-low  = FIRST_DAY.
  Date-high = LAST_DAY.
  Date-sign = 'I'.
  Date-option = 'BT'.
  APPEND Date.

  TYPES: BEGIN OF LS_HEADER,
    ebeln      TYPE ekko-ebeln,
    lifnr      TYPE ekko-lifnr,
    name1      TYPE lfa1-name1,
    item_count TYPE i,
    total_qty  TYPE ekpo-menge,
    chk        TYPE char1,
    comment    TYPE char100,
    color_tab  TYPE lvc_t_scol,
       END OF LS_HEADER.

TYPES: BEGIN OF LS_ITEM,
    ebeln TYPE ekpo-ebeln,
    ebelp TYPE ekpo-ebelp,
    matnr TYPE ekpo-matnr,
    maktx TYPE makt-maktx,
    menge TYPE ekpo-menge,
       END OF LS_ITEM.

*&---------------------------------------------------------------------*

TYPE-POOLS : SLIS .
DATA: IT_HEADER   TYPE TABLE OF LS_HEADER,
      WA_HEADER   TYPE LS_HEADER,
      IT_ITEMS    TYPE TABLE OF LS_ITEM,
      WA_ITEMS     TYPE LS_ITEM,
      IT_FC TYPE slis_t_fieldcat_alv,
      WA_FC TYPE slis_fieldcat_alv,
      WA_LAYOUT   TYPE slis_layout_alv.
