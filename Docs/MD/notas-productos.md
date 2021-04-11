##### NOTA 1

La única fruta del *dataset1* que no se ha añadido al análisis ha sido la chirimoya debido a la gran cantidad de datos faltantes.

##### NOTA 2

Todas las métricas han sido estandarizadas, no nos parecen relevantes los valores nominales ni las escalas.

##### NOTA 3

Los índices han sido creados para poderse comparar entre diferentes productos, incluso en el caso de que tengan una cantidad de datos post-COVID diferentes.

##### NOTA 4

El primer componente del Análisis de Componentes Principales relaciona los índices del volumen y consumo con la misma intensidad, y el segundo recoge totalmente el precio. Esto ocurre debido al alto grado de relación entre el volumen y el consumo de un producto.

|         | PC1     | PC2   | PC3     |
|---------|:-------:|:-----:|:-------:|
|Volumen  | 0.707   | 0.021 | 0.707   |
|Consumo  | 0.707   | 0.016 | -0.707  |
|Precio   | -0.026  | 0.999 | -0.004  |

|                       | PC1   | PC2   | PC3   |
|-----------------------|:-----:|:-----:|:-----:|
|Standard deviation     | 1.41  | 0.999 | 0.111 |
|Proportion of Variance | 0.663 | 0.333 | 0.004 |
|Cumulative Proportion  | 0.663 | 0.996 | 1     |

##### NOTA 5

La agrupación de los productos se ha realizado con el algoritmo de K-Means Clustering. La elección de $K=3$ se ha obtenido con la regla del codo, queriendo minimizar la suma de los cuadrados dentro de cada grupo (Within-Cluster Sums of Squares / WCSS).

##### NOTA 6

Se han ajustado los ejes en el gráfico del Cluster, ya que los datos se han estandarizado nuevamente al hacer el Análisis de Componentes Principales.

##### NOTA 7

El Cluster se ha compilado fuera de la aplicación Shiny debido a la gran cantidad de computo necesario. Igualmente se ha mantenido el código comentado en el archivo `global.R` para una posible revisión.
