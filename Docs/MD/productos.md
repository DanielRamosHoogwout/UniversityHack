En el gráfico dinámico de más arriba se puede observar la evolución de diferentes productos en función de una métrica determinada. Las diferentes métricas disponibles son el (1)
el volumen de producto total, (2) el precio medio del producto, (3) el consumo per cápita, y (4) el gasto per cápita. Todas las métricas han sido estandarizadas.

Durante el periodo anterior al COVID-19, la variación de estas métricas parece normal. A partir de Marzo del 2020, con el comienzo de la pandemia en España, se observan dos series
en el gráfico:
* Serie roja: Evolución de la métrica durante el periodo de pandemia.
* Serie discontinua: Predicción mediante un ARIMA (Modelo autorregresivo integrado de media móvil) utilizando los datos anteriores a la pandemia.

Con el supuesto de que en los periodos anteriores a la pandemia, el mercado de frutas y hortalizas no ha sido afectado por ningún shock externo, y que el shock durante el periodo
de pandemia ha sido debido al COVID-19, se ha estimado un índice del efecto del virus sobre los diferentes productos.

Intuitivamente, este índice es el área encerrada entre la serie roja y la discontinua. Si la serie roja está por encima de la discontinua, se puede decir que el efecto del COVID-19
ha sido el de aumentar la métrica en cuestión, por lo que el valor del índice es positivo. En el caso contrario, el índice es negativo. Los índices han sido creados para poderse
comparar entre diferentes productos, incluso en el caso de que tengan una cantidad de datos post-pandemia diferentes.

Es necesario comentar que en algún caso la predicción del ARIMA no es muy buena debido a que no se detecta estacionalidad. Para corergir esto, son necesarios datos de las métricas
anteriores a 2018.

### Cluster

Una vez se tienen los índices de todos los productos con las cuatro métricas, se puede realizar una clasificación en función de estos valores. Antes de hacer la agrupación, se ha
reducido la dimensión de los cuatro índices de cada producto a únicamente dos dimensiones. Esto se ha hecho mediante un Análisis de Componentes Principales, con el que se ha
obtenido un primer componente que relaciona los índices del volumen, el consumo per cápita y el gasto per cápita con la misma intensidad, y un segundo componente principal que solo
recoge información del índice del precio medio. Al estar tan relacionados el volumen total, el consumo y el gasto, a este indicador se le puede considerar simplemente como el
consumo general del producto.

Ahora, con los índices del consumo general y del precio de cada producto, se ha realizado un cluster jerárquico y se han dividido los productos en dos grupos diferentes en función
del efecto sufrido por el COVID-19. En el gráfico siguiente se pueden ver ambos grupos con sus respectivos índices.
