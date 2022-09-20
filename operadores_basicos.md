# Operadores basicos

## concatenar strings

Para poder concatenar strings en elixir se usa el operador <>

```elixir
"Hola" <> " " <> "Mundo"
```

## Operadores sobre booleanos

Se pueden usar los operadores and, or, not; estrictamente tienen que ser sobre valores booleanos.

Se les llama "cortocircuito" porque solo evaluan el lado derecho si el lado izquierdo no es suficiente por si mismo para dar el resultado.

```elixir
false or is_atom(:masmelo)
```

```elixir
true or is_boolean("no es boleano")

# en este caso por ejemplo el operador or da como resultado true si al menos uno de los elementos es true por lo tanto no entra a evaluar el segundo elemento
```

```elixir
false and raise('Este mensaje no deberia aparecer')
# raise sirve para crear excepciones 
```

## And, or, not flexibles

Elixir provee los operadores || && !. Son lo mismo que or, and y not pero son flexibles a cualqueir tipo de dato, por ende, si se requiere operar con dos booleanos se usan los estrictos mientras que si se quiere operar con cualquier otro tipo de dato se usa estos operadores.

```elixir
1 || false
```

```elixir
nil && 13
# nil es considerado como valor falso, por eso, imprime el valor nil
```

```elixir
!13
# 13 es considerado como verdadero por eso al negarlo da falso
```

## Operadores de comparacion

Elixir tiene operadores de comparación como:

'==' : para comparar si el lado izqueirdo es igual al derecho.

'!=' : para comparar si el lado izquierdo es distinto al derecho.

'===' : para comparar si el lado izquierdo es estrictamente igual al derecho.

'!==' : .... es estrictamente diferente al izquierdo.

'<=' : .... es menor o igual al derecho.

'>=' : .... es mayor o igual al derecho.

'<' : ....... menor ......

'>' : ...... mayor .....

```elixir
1 === 1.0
# da falso porque uno es un entero y el otro es un flotante 
```

```elixir
nil != false
# nil es considerado como un valor falso mas no es falso,por ende, da falso
```

```elixir
5 < :atom
```

El orden de clasificación de menor a mayor es:

number < atom < reference < function < port < pid < tuple < map < list < bitstring

```elixir
"Hola como estas? " > ["Hola como estas?"]
```
