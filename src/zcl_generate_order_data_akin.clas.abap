CLASS zcl_generate_order_data_akin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_generate_order_data_akin IMPLEMENTATION.
    METHOD if_oo_adt_classrun~main.
        DATA itab TYPE TABLE OF zorder_akin.

*created_by, last_changed_by, local_last_changed_at

*       fill internal travel table (itab)
        itab = VALUE #(
            ( order_uuid = '02D5290E594C1EDA93815057FD946624' customer_uuid = '92D5290E594C1EDA93815057FD946624' order_id = '00000022'  delivery_date = '20210221180000'
              pickup_date = '20210226180000' weight = 10000 unitofmeasure = 'KG' category = 'CW'                                                      status = 'A' )
            ( order_uuid = '02D5290E594C1EDA93858EED2DA2EB0B' customer_uuid = '92D5290E594C1EDA93858EED2DA2EB0B' order_id = '00000103'  delivery_date = '20210105180000'
              pickup_date = '20210103180000' weight = 500   unitofmeasure = 'KG' category = 'PCW' customercomment = 'Hallo, ich bitte um Rückmeldung' status = 'O' )
         ).

*       delete existing entries in the database table
        DELETE FROM zorder_akin.

*       insert the new table entries
        INSERT zorder_akin FROM TABLE @itab.

*       output the result as a console message
        out->write( |{ sy-dbcnt } order entries inserted successfully!| ).
     ENDMETHOD.
ENDCLASS.
