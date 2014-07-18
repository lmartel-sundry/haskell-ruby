require 'json'
require 'tempfile'

def haskell(source)
    Haskell.load(source)
end

module Haskell

    def method_missing(name, *args, &block)
        if block_given?
            Haskell.async(name, *args, &block)
        else
            Haskell.call(name, *args)
        end
    end

    class << self

    @@haskell_file_cache = {}

        # TODO module support
        # TODO flexible whitespace
        def load(source)
            len = file.write source
            len > 0
        end

        def call(func, *args)
            args = args.map { |arg| arg.to_json }.join(' ').gsub('"', '\\"') # json-ify args and escape double quotes

            file.flush # ensure all buffered source changes have been written
            `ghc #{file.path} -e "#{func} #{args}"`
        end

        def async(*args)
            Thread.new do
                yield Haskell.call(*args)
            end
        end

        def file(base='main')
            @@haskell_file_cache[base] = Tempfile.new([base, '.hs']) unless @@haskell_file_cache[base]
            @@haskell_file_cache[base]
        end

    end

    private_class_method :file
end

