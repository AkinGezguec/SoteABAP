CLASS ZCM_RAP_AKIN DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .
    INTERFACES if_abap_behv_message.

    CONSTANTS:
      BEGIN OF date_interval,
        msgid TYPE symsgid VALUE 'ZRAP_MSG_AKIN',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'DELIVERYDATE',
        attr2 TYPE scx_attrname VALUE 'PICKUPDATE',
        attr3 TYPE scx_attrname VALUE 'ORDERID',
        attr4 TYPE scx_attrname VALUE '',
      END OF date_interval .
    CONSTANTS:
      BEGIN OF begin_date_before_system_date,
        msgid TYPE symsgid VALUE 'ZRAP_MSG_AKIN',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'DELIVERYDATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF begin_date_before_system_date .
    CONSTANTS:
      BEGIN OF status_is_not_valid,
        msgid TYPE symsgid VALUE 'ZRAP_MSG_AKIN',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'STATUS',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_is_not_valid .

    METHODS constructor
      IMPORTING
        severity        TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid          LIKE if_t100_message=>t100key OPTIONAL
        previous        TYPE REF TO cx_root OPTIONAL
        delivery_date   TYPE timestamp OPTIONAL
        pickup_date     TYPE timestamp OPTIONAL
        order_id        TYPE z_order_id  OPTIONAL
        status          TYPE z_status OPTIONAL
        customer_id     TYPE z_customer_id OPTIONAL
      .

    DATA delivery_date  TYPE timestamp READ-ONLY.
    DATA pickup_date    TYPE timestamp READ-ONLY.
    DATA order_id       TYPE z_order_id READ-ONLY.
    DATA status         TYPE z_status READ-ONLY.
    DATA customer_id    TYPE z_customer_id READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCM_RAP_AKIN IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.

    me->delivery_date = delivery_date.
    me->pickup_date = pickup_date.
    me->order_id = |{ order_id ALPHA = OUT }|.
    me->status = status.
    me->customer_id = |{ customer_id ALPHA = OUT }|.
  ENDMETHOD.
ENDCLASS.

