require 'json'
require 'tempfile'

class Haskell

    class << self

        @@temp = {}

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
            @@temp[base] = Tempfile.new([base, '.hs']) unless @@temp[base]
            @@temp[base]
        end
    end

    private_class_method :file
end
