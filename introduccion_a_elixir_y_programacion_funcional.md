# introduccion a elixir y programacion funcional

## Que es elixir ?

Elixir es un lenguaje de programación funcional, concurrente, de propósito general que se ejecuta sobre la máquina virtual de Erlang. Elixir está escrito sobre Erlang y comparte las mismas abstracciones para desarrollar aplicaciones distribuidas y tolerantes de fallos.

## Programacion Imperactiva vs declarativa

Declarativo: Describe que hace el código. Cuando se quiere usar el código en múltiples lugares, las funciones declarativas, son fáciles de usar y útiles en estos casos.

```elixir
const arr = [2, 4, 6]
const arraySum = arrayReducer(arr)
console.log(`El sumatorio resulta en ${arraySum}`)  
// El sumatorio resulta en 12
```

imperactivo: Describe como se hace el código.

```elixir
const arr = [2, 4, 6]
let acc = 0
for (let i = 0; i < arr.length; i++){
  acc += arr[i]
}
console.log(`El sumatorio resulta en ${acc}`)  
// El sumatorio resulta en 12
```

Ambos códigos hacen lo mismo solo que el primero se basa en hacer las cosas y el segundo en como hacerlas. Elixir es un lenguaje declarativo.

## Programación funcional

La programación funcional busca crear funciones puras lo maximo posible. Una funcion es pura cuando recibe ciertos valores y estos valores no cambian y siempre conseguimos los mismos resultados  y no se tienen efectos colaterales.

## Bases de la programación funcional

Separación: Mantener las funciones pequeñas. Hacer una cosa a la vez y hacerla bien.

Composición: Escribir funciones que retornen imputs para otras funciones.

inmutabilidad: "La verdadera constante es el cambio. La mutación oculta el cambio. El cambio oculto manifiesta el caos. Por eso, los sabios abrazan la historia."

Memoization: La memoización es una técnica de optimización que se utiliza principalmente para acelerar los programas informáticos almacenando los resultados de las costosas llamadas a funciones y devolviendo el resultado almacenado en caché cuando vuelven a producirse las mismas entradas.

Higher Order Functions: se considera una función de orden superior cuando toma una o mas funciones como parámetros o cuando retorna una función como resultado.

Currying: "es la técnica de traducir la evaluación de una función que toma múltiples argumentos (o una tupla de argumentos) en la evaluación de una secuencia de funciones, cada una con un solo argumento"
