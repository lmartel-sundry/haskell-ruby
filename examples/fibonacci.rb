require('haskell-ruby')

class Fibonacci
    include Haskell

    def pretty_print_fib(n)
        res = fib n
        puts "Fib(#{n}) = #{res.empty? ? '[too big]' : res}"
    end

    def usage!
        puts <<-EOS
            Usage: 
            fibonacci.rb [n]    |   Print the nth fibonacci number
            fibonacci.rb        |   Start a fibonacci number REPL
        EOS
        exit 1
    end

    def repl
        loop do
            print "λ "
            input = gets
            if input.nil? || input.chomp!.empty?
                puts "Bye!"
                exit 0
            end
            pretty_print_fib input.to_i
        end
    end

    def main
        case ARGV.length
        when 0
            repl
        when 1
            begin
                pretty_print_fib Integer(ARGV.first)
            rescue ArgumentError
                usage!
            end
        else
            usage!
        end
    end
end

haskell """
{-# OPTIONS_GHC -fno-warn-missing-methods #-}
data Matrix = Matrix Integer Integer Integer Integer
instance Num Matrix where
    (*) (Matrix a b c d) (Matrix e f g h) = Matrix (a*e+b*g) (a*f+b*h) (c*e+d*g) (c*f+d*h)

fib :: Integer -> Integer
fib n | n <= 0      = 0
      | n == 1      = 1
      | otherwise   = extract $ (Matrix 1 1 1 0)^(n - 1)
      where extract (Matrix ul _ _ _) = ul
"""


Fibonacci.new.main
