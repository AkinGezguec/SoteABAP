@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Data model for orders'
@Search.searchable: true
define view entity ZI_ORDER_M_AKIN 
    as select from zorder_akin as ZIOrder
    
    association to parent ZI_CUSTOMER_M_AKIN as _Customer on $projection.CustomerUUID = _Customer.CustomerUUID
{
   
    key order_uuid            as OrderUUID,
        customer_uuid         as CustomerUUID,
        @Search.defaultSearchElement: true
        order_id              as OrderID,
        delivery_date         as DeliveryDate,
        pickup_date           as PickupDate,
        weight                as Weight,
        unitofmeasure         as Unitofmeasure,
        category              as Category,
        customercomment       as Customercomment,
        status                as Status,
        @Semantics.user.createdBy: true
        created_by            as CreatedBy,
        @Semantics.user.lastChangedBy: true
        last_changed_by       as LastChangedBy,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        local_last_changed_at as LocalLastChangedAt,
    
        // Make association public
        _Customer
}
