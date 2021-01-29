@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Data model for customers'
@Search.searchable: true
define root view entity ZI_CUSTOMER_M_AKIN 
    as select from zcustomer_akin as ZICustomer

    composition [0..*] of ZI_ORDER_M_AKIN as _Order
{    
    key customer_uuid         as CustomerUUID,
        @Search.defaultSearchElement: true
        customer_id           as CustomerID,
        @Search.defaultSearchElement: true
        firstname             as FirstName,
        @Search.defaultSearchElement: true
        lastname              as LastName,
        companyname           as Company,
        postcode              as Postcode,
        street                as Street,
        city                  as City,
        customersegment       as Customersegment,
        @Semantics.user.createdBy: true
        created_by            as CreatedBy,
        @Semantics.systemDateTime.createdAt: true
        created_at            as CreatedAt,
        @Semantics.user.lastChangedBy: true
        last_changed_by       as LastChangedBy,
        @Semantics.systemDateTime.lastChangedAt: true
        last_changed_at       as LastChangedAt,
        @Semantics.systemDateTime.localInstanceLastChangedAt: true
        local_last_changed_at as LocalLastChangedAt,
    
        // Make association public
        _Order
}
