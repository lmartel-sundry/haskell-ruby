require('haskell-ruby')

class Fibonacci
    include Haskell

    def pretty_print(n, res)
        res.chomp!
        if res.length == 1000
            puts "Fib(#{n}) = ...#{res}"
            puts "[Truncated to last thousand digits]"
        else
            puts "Fib(#{n}) = #{res}"
        end
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

            n, cmd = input.split(' ')
            n = n.to_i
            if cmd == "async"
                fibSummary(n) do |res|
                    puts
                    pretty_print n, res
                    print "λ "
                end
            else
                pretty_print n, fibSummary(n)
            end
        end
    end

    def main
        case ARGV.length
        when 0
            repl
        when 1
            begin
                n = Integer(ARGV.first)
                pretty_print n, fib(n)
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

-- Stick to the last few digits to avoid crashing my poor shell
fibSummary :: Integer -> Integer
fibSummary n = (fib n) `mod` (10^1000)
"""

Fibonacci.new.main
