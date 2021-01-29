CLASS lhc_order DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    CONSTANTS:
       BEGIN OF status,
         open     TYPE c LENGTH 1  VALUE 'O', " Open
         accepted TYPE c LENGTH 1  VALUE 'A', " Accepted
         canceled TYPE c LENGTH 1  VALUE 'C', " Canceled
         finished TYPE c LENGTH 1  VALUE 'F', " Finished
       END OF status.


    METHODS calculateOrderID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Order~calculateOrderID.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Order~validateDates.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Order RESULT result.

    METHODS acceptOrder FOR MODIFY
      IMPORTING keys FOR ACTION Order~acceptOrder RESULT result.

    METHODS rejectOrder FOR MODIFY
      IMPORTING keys FOR ACTION Order~rejectOrder RESULT result.

    METHODS finishOrder FOR MODIFY
      IMPORTING keys FOR ACTION Order~finishOrder RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Order~setInitialStatus.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Order~validateStatus.

ENDCLASS.

CLASS lhc_order IMPLEMENTATION.

  METHOD calculateOrderID.
    DATA max_orderid TYPE z_order_id.
    DATA update TYPE TABLE FOR UPDATE ZI_CUSTOMER_M_AKIN\\Order.

    " Read all customers for the requested orders.
    " If multiple orders of the same customer are requested, the customer is returned only once.
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
    ENTITY Order BY \_Customer
      FIELDS ( CustomerUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(customers).

    " Process all affected Customers. Read respective orders, determine the max-id and update the orders without ID.
    LOOP AT customers INTO DATA(customer).
      READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
        ENTITY Customer BY \_Order
          FIELDS ( OrderID )
        WITH VALUE #( ( %tky = customer-%tky ) )
        RESULT DATA(orders).

      " Find max used OrderID in all orders of this customer
      max_orderid ='0000'.
      LOOP AT orders INTO DATA(order).
        IF order-OrderID > max_orderid.
          max_orderid = order-OrderID.
        ENDIF.
      ENDLOOP.

      " Provide a order ID for all orders that have none.
      LOOP AT orders INTO order WHERE OrderID IS INITIAL.
        max_orderid += 10.
        APPEND VALUE #( %tky      = order-%tky
                        OrderID = max_orderid
                      ) TO update.
      ENDLOOP.
    ENDLOOP.

    " Update the Order ID of all relevant orders
    MODIFY ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
    ENTITY Order
      UPDATE FIELDS ( OrderID ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.


  METHOD validateDates.
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
        FIELDS ( OrderID DeliveryDate PickupDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    LOOP AT orders INTO DATA(order).
      " Clear state messages that might exist
      APPEND VALUE #(  %tky        = order-%tky
                       %state_area = 'VALIDATE_DATES' )
        TO reported-order.

      IF order-PickupDate < order-DeliveryDate.
        APPEND VALUE #( %tky = order-%tky ) TO failed-order.
        APPEND VALUE #( %tky               = order-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW ZCM_RAP_AKIN(
                                                 severity      = if_abap_behv_message=>severity-error
                                                 textid        = ZCM_RAP_AKIN=>date_interval
                                                 delivery_date = order-DeliveryDate
                                                 pickup_date   = order-PickupDate
                                                 order_id      = order-OrderID )
                        %element-DeliveryDate = if_abap_behv=>mk-on
                        %element-PickupDate   = if_abap_behv=>mk-on ) TO reported-order.

      ELSEIF order-DeliveryDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky               = order-%tky ) TO failed-order.
        APPEND VALUE #( %tky               = order-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW ZCM_RAP_AKIN(
                                                 severity       = if_abap_behv_message=>severity-error
                                                 textid         = ZCM_RAP_AKIN=>begin_date_before_system_date
                                                 delivery_date  = order-DeliveryDate )
                        %element-DeliveryDate = if_abap_behv=>mk-on ) TO reported-order.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance_features.
        " Read the order status of the existing orders
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(orders)
      FAILED failed.

    result =
      VALUE #(
        FOR order IN orders
          LET is_accepted =   COND #( WHEN order-Status = status-accepted
                                      THEN if_abap_behv=>fc-o-disabled
                                      ELSE if_abap_behv=>fc-o-enabled  )
              is_rejected =   COND #( WHEN order-Status = status-canceled
                                      THEN if_abap_behv=>fc-o-disabled
                                      ELSE if_abap_behv=>fc-o-enabled )
              is_finished =   COND #( WHEN order-Status = status-finished
                                      THEN if_abap_behv=>fc-o-disabled
                                      ELSE if_abap_behv=>fc-o-enabled )
          IN
            ( %tky                = order-%tky
              %action-acceptOrder = is_accepted
              %action-rejectOrder = is_rejected
              %action-finishOrder = is_finished
             ) ).
  ENDMETHOD.


  METHOD acceptOrder.
     " Set the new status
    MODIFY ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
         UPDATE
           FIELDS ( Status )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             Status = status-accepted ) )
      FAILED failed
      REPORTED reported.

    " Fill the response table
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    result = VALUE #( FOR order IN orders
                        ( %tky   = order-%tky
                          %param = order ) ).
  ENDMETHOD.


  METHOD rejectOrder.
    " Set the new status
    MODIFY ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
         UPDATE
           FIELDS ( Status )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             Status = status-canceled ) )
      FAILED failed
      REPORTED reported.

    " Fill the response table
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    result = VALUE #( FOR order IN orders
                        ( %tky   = order-%tky
                          %param = order ) ).
  ENDMETHOD.


  METHOD finishOrder.
    " Set the new status
    MODIFY ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
         UPDATE
           FIELDS ( Status )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             Status = status-finished ) )
      FAILED failed
      REPORTED reported.

    " Fill the response table
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    result = VALUE #( FOR order IN orders
                        ( %tky   = order-%tky
                          %param = order ) ).
  ENDMETHOD.


  METHOD setInitialStatus.
    " Read relevant order instance data
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
        FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(orders).

    " Remove all order instance data with defined status
    DELETE orders WHERE Status IS NOT INITIAL.
    CHECK orders IS NOT INITIAL.

    " Set default order status
    MODIFY ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
    ENTITY Order
      UPDATE
        FIELDS ( Status )
        WITH VALUE #( FOR order IN orders
                      ( %tky         = order-%tky
                        Status = status-open ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.


  METHOD validateStatus.
    READ ENTITIES OF ZI_CUSTOMER_M_AKIN IN LOCAL MODE
      ENTITY Order
          FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_order_result).

      LOOP AT lt_order_result INTO DATA(ls_order_result).
          CASE ls_order_result-Status.
              WHEN 'O'. " Open
              WHEN 'A'. " Accepted
              WHEN 'C'. " Canceled
              WHEN 'F'. " Finished

              WHEN OTHERS.
                  APPEND VALUE #( %key = ls_order_result-%key ) TO failed-order.

                  APPEND VALUE #( %key = ls_order_result-%key
                                  %msg = new_message( id       = ZCM_RAP_AKIN=>status_is_not_valid-msgid
                                                      number   = ZCM_RAP_AKIN=>status_is_not_valid-msgno
                                                      v1       = ls_order_result-Status
                                                      severity = if_abap_behv_message=>severity-error )
                                  %element-status = if_abap_behv=>mk-on ) TO reported-order.
         ENDCASE.

      ENDLOOP.

  ENDMETHOD.

ENDCLASS.
