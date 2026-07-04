

main = putStrLn simple3

-- Une lambda : 
-- \argument -> expression
testons = (\test -> test) "Hello !"

-- autres lambdas simples, qui rappellent qu'une
-- expression est ce qui renvoie une valeur,
-- calculée ou non :
simple = (\x -> x <> ", n'est-ce pas ?") "Pas mal"
simple2 = (\x -> x * 3) 4
simple3 = (\x -> \y -> \z-> x <> y <> z) "Tu " "vas " "bien ?" 
-- String -> (String -> String)
-- \x -> (\y -> \z [qui renvoie la concaténation])

helloWorld = (\word1 -> \word2 -> word1 <> word2) "hello" "world"
-- prend un argument word1
-- puis retourne une fonction qui prend word2
-- et retourne une fonction qui concatène
-- en gros
-- la fonction fait
-- String -> String -> String
-- ce qui équivaut à
-- String -> (String -> String)



