@EndUserText.label: 'Projection view for order'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true

define view entity ZC_ORDER_M_AKIN 
    as projection on ZI_ORDER_M_AKIN as Order
    {
        key OrderUUID,
            CustomerUUID,
//            @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_ORDER_M_AKIN', element: 'OrderID'} }]
            @Search.defaultSearchElement: true
            OrderID,
            _Customer.CustomerID,
            DeliveryDate,
            PickupDate,
            Weight,
            Unitofmeasure,
            Category,
            Customercomment,
            Status,
            LocalLastChangedAt,
            
            /* Associations */
            _Customer : redirected to parent ZC_CUSTOMER_M_AKIN
    }
