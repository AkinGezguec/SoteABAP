CLASS lhc_Customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateCustomerID FOR DETERMINE ON SAVE
      IMPORTING keys FOR Customer~calculateCustomerID.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Customer RESULT result.

ENDCLASS.

CLASS lhc_Customer IMPLEMENTATION.

  METHOD calculateCustomerID.

    " check if CustomerID is already filled
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Customer
        FIELDS ( CustomerID ) WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    " remove lines where CustomerID is already filled.
    DELETE customers WHERE CustomerID IS NOT INITIAL.

    " anything left ?
    CHECK customers IS NOT INITIAL.

    " Select max customer ID
    SELECT SINGLE
        FROM  zcustomer_akin
        FIELDS MAX( customer_id ) AS customerID
        INTO @DATA(max_customerid).

    " Set the customer ID
    MODIFY ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
    ENTITY Customer
      UPDATE
        FROM VALUE #( FOR customer IN customers INDEX INTO i (
          %tky              = customer-%tky
          CustomerID          = max_customerid + i
          %control-CustomerID = if_abap_behv=>mk-on ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
