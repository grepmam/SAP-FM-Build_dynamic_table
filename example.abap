*&---------------------------------------------------------------------*
*& Report zexample
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zexample.


TYPES: BEGIN OF ty_global,
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
       END OF ty_global.

DATA: lt_global    TYPE TABLE OF ty_global,
      lv_tablename TYPE string,
      lv_fields    TYPE string,
      lv_where     TYPE string.


lv_tablename = 'BSEG'.
lv_fields    = 'BUKRS BELNR'.

CALL FUNCTION 'ZBUILD_DYNAMIC_TABLE'
  EXPORTING
    iv_tablename         = lv_tablename " Nombre de tabla
    iv_fields            = lv_fields    " Campos a rellenar
  IMPORTING
    et_table             = lt_global    " Resultados
  EXCEPTIONS
    db_empty             = 1
    tablename_not_set    = 2
    database_not_found   = 3
    columns_do_not_match = 4
    others               = 5.

IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
