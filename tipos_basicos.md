# Tipos básicos

## Tipos de datos

<!-- livebook:{"force_markdown":true} -->

```elixir
1 # entero 
1.0 # float
true # bool
[1,2,3] # listas
{1,2,3} # tuplas
"Strings" #strings
:atom # atomos o simbolos
```

## Operaciones aritmeticas

```elixir
# suma
1 + 5
```

```elixir
# multiplicacion
5 * 5
```

```elixir
# division con resultado float
10 / 2
```

```elixir
# division con resultado int
div(10, 2)
```

```elixir
# remanente de la division, osea, lo que sobra
rem(10, 3)
```

```elixir
# redondea hacia arriba
round(3.547)
```

```elixir
# redondea hacia abajo
trunc(3.547)
```

## Identificando funciones

h trunc/1  : cuando queremos saber que hace una funcion desde la iex en elixir podemos poner el comando h seguido de la funcion + / numero de parametros que recibe

Se puede acceder a la funcion por el nombre o por el numero de parametros, por ejemplo: trunc seria la funcion que solo toma el entero de un numero flotante, mientras que trunc/2 no existe

## Valores booleanos

```elixir
# elixir tiene dos valores booleanos true y false
true == false
```

```elixir
# para saber si un valor es booleano se usa la funcion is_boolean/1
is_boolean(true)
```

existen otras funciones en elixir como is_integer para enteros, is_float para flotantes, is_number para ambos casos

## Symbols o atomos

```elixir
:melon
:apple
:orange
```

```elixir
:melon == :apple
```

Segun la documentacion es para expresar estados de una operacion como :ok o :error (estudiar más sobre esto y preguntarle a Juan mañana).
Un atomo es un tipo de dato cuyo valor es su propio nombre. Sirven especialmente para codificar palabras.

!importante los valores booleanos son tambien atomos; las palabras que comienzan con mayusculas tambien son consideradas atomos; nil tambien es un atomo y es igual a null en otros lenguajes de programación.

```elixir
is_atom(Hola)
```

## String

```elixir
"hola"
```

```elixir
# puede tener interpolacion con atomos o numeros
string = :mundo
"Hola #{string}"
```

```elixir
# Se puede hacer saltos de linea
"Hola \nMundo"
```

```elixir
string = "hola"
string2 = "HOLAAAAA"
```

```elixir
# saber el tamaño de un string
String.length(string)
```

```elixir
# transformar en minusculas
String.upcase(string)
```

```elixir
# transformar en minusculas
String.downcase(string2)
```

```elixir
String.capitalize(string2)
```

## Funciones anónimas

Las funciones anonimas se pueden invocar con la palabra fn y siempre terminan con la palabra end.

```elixir
suma = fn a, b -> a + b end
suma.(5, 3)
```

Para verificar si es una funcion se puede usar la palabra is_function. Esta función recibe dos parametros, el primero es la función a evaluar y el segundo es el numero de parametros que tiene la funcion

```elixir
is_function(suma, 1)
```

```elixir
is_function(suma, 2)
```

!importante, Las funciones pueden recibir otras funciones como parametros o utilizar otras funciones dentro de ellas, pero, las funciones no pueden re-escribir variables que fueron definidas fuera de la función o re-escribir otras funciones

```elixir
otra_funcion = fn numero -> suma.(numero, numero) end
otra_funcion.(8)
```

```elixir
x = 50
funcion_con_error = (fn -> x = 10 end).()
```

## Listas

```elixir
# las listas pueden ser de cualquier tipo
lista1 = [1, 2, 3, 4, true, :masmelo]
```

```elixir
# función para saber la longitud
length(lista1)
```

```elixir
lista2 = [8, 9, 10, false]
lista_concatenada = lista1 ++ lista2
# Es posible concatenar dos listas
```

```elixir
lista3 = [3, 4, true, 10]
lista_sustraida = lista_concatenada -- lista3
# se pueden sustraer valores de una lista
```

```elixir
hd(lista_sustraida)
# hd o head sirve para conocer el primer elemento de una lista
```

```elixir
tl(lista1)
# tl o tail sirve para mirar los elementos de una lista sin contar con el head
```

## Tuplas

Las tuplas se almacenan de manera continua en memoria, por lo tanto, acceder a los elementos de las tuplas es mucho más rapido.

```elixir
tupla_nueva = {1, 2, 3, 4, true, :masmelo}
# Las tuplas como las listas pueden recibir cualquier elemento
```

```elixir
tuple_size(tupla_nueva)
# para saber el tamaño de una tupla
```

```elixir
elem(tupla_nueva, 0)
# para saber el elemento de una tupla se usa elem y empiezan a contar desde indice 0
```

```elixir
put_elem(tupla_nueva, 0, "nueva palabra")
# para añadir un elemento nuevo a una tupla
```

## Reto conversor de monedas

```elixir
valor_dolar_a_peso = 4411.48
conversor_dolares_a_pesos = fn dolares_a_convertir -> dolares_a_convertir * valor_dolar_a_peso end
trunc(conversor_dolares_a_pesos.(250))

# Funcion para convertir de dolares a pesos
```

```elixir
valor_peso_a_dolar = 0.00022731600613753
conversor_pesos_a_dolares = fn pesos_a_convertir -> pesos_a_convertir * valor_peso_a_dolar end
resultado = conversor_pesos_a_dolares.(1_102_870)
trunc(resultado)

# funcion para convertir de pesos a dolares
```
