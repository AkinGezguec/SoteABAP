@EndUserText.label: 'Projection view for customer'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: ['CustomerID']

define root view entity ZC_CUSTOMER_M_AKIN
    as projection on ZI_CUSTOMER_M_AKIN as Customer
    {
        key CustomerUUID,
//            @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CUSTOMER_M_AKIN', element: 'CustomerID'} }]
            @Search.defaultSearchElement: true
            CustomerID,
            FirstName,
            LastName,
            Company,
            Postcode,
            Street,
            City,
            Customersegment,
            LastChangedAt,
            LocalLastChangedAt,
    
            /* Associations */
            _Order : redirected to composition child ZC_ORDER_M_AKIN
    }
