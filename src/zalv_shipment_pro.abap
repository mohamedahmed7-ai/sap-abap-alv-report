*&---------------------------------------------------------------------*
*& Report ZALV_SHIPMENT_PRO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZALV_SHIPMENT_PRO.
*&---------------------------------------------------------------------*
INCLUDE ZALV_SHIPMENT_PRO_DEF .
*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
PERFORM build_field_catalog.
*&---------------------------------------------------------------------*
PERFORM GET_DATA.
*&---------------------------------------------------------------------*
PERFORM DISPLAY_DATA.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .
  SELECT k~ebeln, k~lifnr, l~name1, p~ebelp, p~matnr, p~menge, m~maktx
    FROM ekko AS k
    INNER JOIN ekpo AS p ON k~ebeln = p~ebeln
    LEFT OUTER JOIN lfa1 AS l ON k~lifnr = l~lifnr
    LEFT OUTER JOIN makt AS m ON p~matnr = m~matnr AND m~spras = 'E'
    INTO TABLE @DATA(IT_RAW_DATA)
    WHERE k~ebeln IN @PO_Num
      AND k~lifnr IN @Vendor.

  IF IT_RAW_DATA IS INITIAL.
    MESSAGE 'لا توجد بيانات مطابقة لشروط البحث' TYPE 'S' DISPLAY LIKE 'W'.
    EXIT.
  ENDIF.

  LOOP AT IT_RAW_DATA INTO DATA(LS_RAW).
    WA_ITEMS-ebeln = LS_RAW-ebeln.
    WA_ITEMS-ebelp = LS_RAW-ebelp.
    WA_ITEMS-matnr = LS_RAW-matnr.
    WA_ITEMS-maktx = LS_RAW-maktx.
    WA_ITEMS-menge = LS_RAW-menge.
    APPEND WA_ITEMS TO IT_ITEMS.
  ENDLOOP.

  LOOP AT IT_RAW_DATA INTO LS_RAW.
  READ TABLE IT_HEADER ASSIGNING FIELD-SYMBOL(<fs_hdr>) WITH KEY ebeln = LS_RAW-ebeln.
IF sy-subrc <> 0.
  CLEAR WA_HEADER.

  WA_HEADER-ebeln     = LS_RAW-ebeln.
  WA_HEADER-lifnr = LS_RAW-lifnr.
  WA_HEADER-name1   = LS_RAW-name1.
  WA_HEADER-item_count    = 1.
  WA_HEADER-total_qty     = LS_RAW-menge.
  APPEND WA_HEADER TO IT_HEADER.
ELSE.
  <fs_hdr>-item_count  = <fs_hdr>-item_count + 1.
  <fs_hdr>-total_qty = <fs_hdr>-total_qty + LS_RAW-menge.
ENDIF.
  ENDLOOP.
*
  DATA: ls_scol TYPE lvc_s_scol.
  LOOP AT IT_HEADER ASSIGNING <fs_hdr>.
    CLEAR ls_scol.
    ls_scol-fname = 'TOTAL_QTY'.

    IF <fs_hdr>-total_qty <= 1000.
      ls_scol-color-col = 6.
      ls_scol-color-int = 1.
    ELSEIF <fs_hdr>-total_qty <= 10000.
      ls_scol-color-col = 3.
      ls_scol-color-int = 1.
    ELSE.
      ls_scol-color-col = 5.
      ls_scol-color-int = 1.
    ENDIF.

    APPEND ls_scol TO <fs_hdr>-color_tab.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .
WA_LAYOUT-coltab_fieldname = 'COLOR_TAB'.
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
   I_CALLBACK_PROGRAM                = SY-repID
*   I_CALLBACK_PF_STATUS_SET          = ' '
   I_CALLBACK_USER_COMMAND           = 'USER_COMMAND'
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
   IS_LAYOUT                         =  WA_LAYOUT
   IT_FIELDCAT                       = IT_FC
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
*   O_PREVIOUS_SRAL_HANDLER           =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    t_outtab                          = IT_HEADER
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


ENDFORM.

FORM build_field_catalog .
 wa_fc-fieldname = 'EBELN'.
  WA_FC-seltext_m = 'PO Number'.
  WA_FC-hotspot   = 'X'.
  APPEND WA_FC TO IT_FC.
  CLEAR WA_FC.

  WA_FC-fieldname = 'LIFNR'.
  WA_FC-seltext_m = 'Vendor No.'.
  APPEND WA_FC TO IT_FC.
  CLEAR WA_FC.

  WA_FC-fieldname = 'NAME1'.
  WA_FC-seltext_m = 'Vendor Name'.
  APPEND WA_FC TO IT_FC.
  CLEAR WA_FC.

  WA_FC-fieldname = 'ITEM_COUNT'.
  WA_FC-seltext_m = 'Count PO Items'.
  APPEND WA_FC TO IT_FC.
  CLEAR WA_FC.

  WA_FC-fieldname = 'TOTAL_QTY'.
  WA_FC-seltext_m = 'Total Quantity'.
  APPEND WA_FC TO IT_FC.
  CLEAR WA_FC.

  WA_FC-fieldname = 'CHK'.
  WA_FC-seltext_m = 'Select'.
  WA_FC-checkbox  = 'X'.
  WA_FC-edit      = 'X'.
  APPEND WA_FC TO IT_FC.
  CLEAR WA_FC.

  WA_FC-fieldname = 'COMMENT'.
  WA_FC-seltext_m = 'Comment'.
  WA_FC-edit      = 'X'.
  APPEND WA_FC TO IT_FC.
ENDFORM.

FORM USER_COMMAND USING COMMAND LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  IF COMMAND = '&IC1' AND rs_selfield-fieldname = 'EBELN'.
    DATA: IT_SUB_ITEM TYPE TABLE OF LS_ITEM  .

    LOOP AT IT_ITEMS INTO WA_ITEMS WHERE ebeln = rs_selfield-value.
      APPEND WA_ITEMS TO IT_SUB_ITEM.
    ENDLOOP.

    IF IT_SUB_ITEM IS NOT INITIAL.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          it_fieldcat = VALUE slis_t_fieldcat_alv(
                          ( fieldname = 'EBELN' seltext_m = 'PO Number' )
                          ( fieldname = 'EBELP' seltext_m = 'Item Number' )
                          ( fieldname = 'MATNR' seltext_m = 'Material No' )
                          ( fieldname = 'MAKTX' seltext_m = 'Material Description (EN)' )
                          ( fieldname = 'MENGE' seltext_m = 'Quantity' ) )
        TABLES
          t_outtab    = IT_SUB_ITEM.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
  IF command = '&DATA_SAVE' OR command = 'SAVE' OR command = '&DATA_SAVE_FULL'.

    rs_selfield-refresh = 'X'.

    DATA: IT_DB_SAVE TYPE TABLE OF ZTA_PO_SAVED,
          WA_DB_SAVE TYPE ZTA_PO_SAVED.


    LOOP AT IT_HEADER INTO WA_HEADER WHERE chk = 'X'.
      CLEAR WA_DB_SAVE.
      WA_DB_SAVE-mandt      = sy-mandt.
      WA_DB_SAVE-ebeln      = WA_HEADER-ebeln.
      WA_DB_SAVE-lifnr      = WA_HEADER-lifnr.
      WA_DB_SAVE-item_count = WA_HEADER-item_count.
      WA_DB_SAVE-total_qty  = WA_HEADER-total_qty.
      WA_DB_SAVE-saved_date = sy-datum.
      WA_DB_SAVE-saved_time = sy-uzeit.
      WA_DB_SAVE-saved_user = sy-uname.
      WA_DB_SAVE-comments   = WA_HEADER-comment.

      APPEND WA_DB_SAVE TO IT_DB_SAVE.
    ENDLOOP.


    IF IT_DB_SAVE IS NOT INITIAL.
      MODIFY ZTA_PO_SAVED FROM TABLE IT_DB_SAVE.
      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE 'تم حفظ البيانات المحددة بنجاح' TYPE 'S'.
      ELSE.
        ROLLBACK WORK.
        MESSAGE 'حدث خطأ أثناء حفظ البيانات' TYPE 'E'.
      ENDIF.
    ELSE.
      MESSAGE 'برجاء تحديد سطر واحد على الأقل للحفظ' TYPE 'W'.
    ENDIF.

  ENDIF.


ENDFORM.
