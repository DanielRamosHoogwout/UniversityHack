Se puede ver como en la mayoría de los casos los efectos del COVID-19 son positivos. Intuitivamente, el índice es el área roja encerrada entre los valores reales y los predichos.

Hay que tener cuidado con las conclusiones debido a dos posibles problemas:

* Adelanto o atraso de la serie: El efecto del COVID-19 podría ser el de adelantar o atrasar los valores de la serie, por lo que se podría estar contabilizando un efecto negativo (positivo) cuando ha habido un atraso (adelanto) de la serie. Esto podría ocurrir si aun no contamos con todos los periodos en los que el COVID-19 ha tenido efecto, así que habría que actualizar la base de datos una vez dispongamos de ellos.

* Predicción pobre: Los datos más antiguos usados para estimar la predicción son del 2018. Por lo tanto, al disponer tan solo de 2 años no siempre es posible detectar la estacionariedad de las series, en estos casos la mejor predicción posible es simplemente la media de la serie. Para arreglar este problema y obtener mejores predicciones, son necesarios datos más antiguos de las series temporales.


## Cluster

Una vez se tienen los índices de todos los productos con las diferentes métricas se puede realizar una clasificación en función de éstos. Primero se ha reducido la dimensión mediante un Análisis de Componentes Principales, con el que se ha obtenido un índice que representa el efecto en la cantidad de producto, y otro que representa el efecto en el precio.

Después se han agrupado los productos en tres grupos diferentes en función del efecto que ha tenido el COVID-19.
