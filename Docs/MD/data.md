Los datos utilizados para realizar el análisis han sido facilitados por la competición, [Cajamar](https://www.cajamardatalab.com/datathon-cajamar-universityhack-2021/retos/visualizacion/). Se han utilizado dos conjuntos de datos diferentes:

El primer conjunto de datos, *dataset1*, incluye información mensual sobre el consumo de frutas y hortalizas en España y está compuesto por las siguientes variables:
* `Año`: Año de la observación.
* `Mes`: Mes de la observación.
* `CCAA`: Comunidad autónoma de la observación. Puede ser cualquier comunidad autónoma o el total de España.
* `Producto`: Producto al que hace referencia la observación. Hay diferentes frutas y verduras.
* `Volumen (miles de kg)`: Cantidad del producto en miles de kilos.
* `Valor (miles de €)`: Valor del producto en miles de €.
* `Precio medio kg`: Precio medio del kilo de producto en €.
* `Penetración (%)`: Porcentaje de hogares que compran este producto. Faltan muchos datos del último año, por lo que no se tiene en cuenta esta variable.
* `Consumo per capita`: Cantidad de producto consumido por habitante.
* `Gasto per capita`: Cantidad de gasto por habitante.

Por otra parte, el segundo conjunto de datos, *dataset4*, contiene información mensual del comercio exterior de España con el resto de países de Europa. Está compuesto por las siguientes
variables:
* `PERIOD`: Mes y año de la observación.
* `REPORTER`: País europeo con el que se comercia.
* `PARTNER`: País comerciante. En todas las observaciones es España, por lo que no se tiene en cuenta esta vaiable.
* `PRODUCT`: Tipo de producto que se comercia.
* `FLOW`: Tipo de comercio. Puede ser importación (`IMPORT`) o exportación (`EXPORT`).
* `INDICATORS`: Tipo de métrica. Puede ser valor (`VALUE_IN_EUROS`) o cantidad (`QUANTITY_IN_100KG`).
* `Value`: Valor de la métrica especificada por la variable `INDICATORS`.
