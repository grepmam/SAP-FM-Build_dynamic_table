FUNCTION zbuild_dynamic_table.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(IV_TABLENAME) TYPE  STRING
*"     REFERENCE(IV_FIELDS) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(ET_TABLE) TYPE  ANY
*"  EXCEPTIONS
*"      DB_EMPTY
*"      TABLENAME_NOT_SET
*"      DATABASE_NOT_FOUND
*"      COLUMNS_DO_NOT_MATCH
*"----------------------------------------------------------------------



* ----------------------------------------------------

  TYPES: BEGIN OF ty_fieldnames,
           fieldname TYPE dd03l-fieldname,
         END OF ty_fieldnames.

* ----------------------------------------------------

  DATA: lt_dynamic   TYPE REF TO data,
        lt_fields1   TYPE TABLE OF ty_fieldnames,
        lt_fields2   TYPE TABLE OF ty_fieldnames,
        lv_tablename TYPE dd03l-tabname,
        lv_fields    TYPE string,
        lv_db_exists TYPE i,
        lv_count_tb1 TYPE i,
        lv_count_tb2 TYPE i.

  FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE.

* ----------------------------------------------------

  lv_tablename = iv_tablename.
  lv_fields    = iv_fields.

  " En caso de que las cadenas no vengan en mayúsculas

  TRANSLATE lv_fields    TO UPPER CASE.
  TRANSLATE lv_tablename TO UPPER CASE.

  " Meter cada campo en una tabla

  SPLIT lv_fields AT space INTO TABLE lt_fields1.

  " Verificar que la tabla haya sido seteada

  IF lv_tablename IS INITIAL.

    RAISE TABLENAME_NOT_SET.

  ELSE.
    
    " Verificar si existe la tabla transparente y esté activa
    
    CLEAR lv_db_exists.

    SELECT COUNT(*)
      FROM dd02l
        INTO lv_db_exists
          WHERE tabname  EQ lv_tablename
            AND as4local EQ 'A'.

    IF lv_db_exists EQ 0.

      RAISE DATABASE_NOT_FOUND.

    ENDIF.

  ENDIF.

  CREATE DATA lt_dynamic TYPE TABLE OF (lv_tablename).
  ASSIGN lt_dynamic->* TO <lt_table>.

  " Chequear y extraer los registros que serían las columnas de la tabla solicitada
  
  REFRESH lt_fields2.

  SELECT fieldname
    FROM dd03l
      INTO TABLE lt_fields2
        FOR ALL ENTRIES IN lt_fields1
          WHERE tabname   EQ lv_tablename
            AND fieldname EQ lt_fields1-fieldname.

  IF lt_fields2 IS NOT INITIAL.
    
    " Chequear si las columnas de la tabla de cadenas es igual a la tabla de tipo campo
    
    lv_count_tb1 = lines( lt_fields1 ).
    lv_count_tb2 = lines( lt_fields2 ).

    IF lv_count_tb1 NE lv_count_tb2.

      RAISE COLUMNS_DO_NOT_MATCH.

    ENDIF.

  ELSE.

    RAISE COLUMNS_DO_NOT_MATCH.

  ENDIF.

  " Extraer registros de la tabla solicitada

  SELECT (lt_fields2)
    FROM (lv_tablename)
      INTO CORRESPONDING FIELDS OF TABLE <lt_table>.

  IF sy-subrc NE 0.

    RAISE DB_EMPTY.

  ENDIF.

  " Mover valores a la tabla de resultados

  MOVE-CORRESPONDING <lt_table> TO et_table.

ENDFUNCTION.
