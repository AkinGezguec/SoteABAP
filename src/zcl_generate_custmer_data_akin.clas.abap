CLASS zcl_generate_custmer_data_akin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_generate_custmer_data_akin IMPLEMENTATION.
    METHOD if_oo_adt_classrun~main.
        DATA itab TYPE TABLE OF zcustomer_akin.

*  created_by, created_at, last_changed_by, last_changed_at, local_last_changed_at

*       fill internal travel table (itab)
        itab = VALUE #(
            ( customer_uuid = '92D5290E594C1EDA93815057FD946624' customer_id = '000077' firstname = 'Akin'    lastname = 'Gezguec'
              companyname = 'SAP'        postcode = '78464' street = 'Am Pfeiferhölzle 13' city = 'Konstanz' customersegment = 'B' )
            ( customer_uuid = '92D5290E594C1EDA93815C50CD7AE62A' customer_id = '070005' firstname = 'Bilal'   lastname = 'Oyman'
              companyname = 'Sybit GmbH' postcode = '78467' street = 'Berliner Strasse 1'  city = 'Singen'   customersegment = 'B' )
            ( customer_uuid = '92D5290E594C1EDA93858EED2DA2EB0B' customer_id = '000011' firstname = 'Henning' lastname = 'Themke'
                                         postcode = '78462' street = 'Singenerstrasse 14'  city = 'Singen'   customersegment = 'P' )
         ).

*       delete existing entries in the database table
        DELETE FROM zcustomer_akin.

*       insert the new table entries
        INSERT zcustomer_akin FROM TABLE @itab.

*       output the result as a console message
        out->write( |{ sy-dbcnt } customer entries inserted successfully!| ).
     ENDMETHOD.
ENDCLASS.
