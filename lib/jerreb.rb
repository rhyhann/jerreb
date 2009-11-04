require 'pp'
require 'rubygems'
require 'active_support/basic_object'
class Jerreb
  class << self
    # The array of the tests
    def tajribaat #:nodoc:
      @tajribaat ||= []; @tajribaat
    end
    
    # Use this method to setup the environment.
    def setup(&setup)
      @setup = setup
    end
    def object
      @setup.call
    end
    
    def he(description, &block)
      Tajriba.new(self, :description => description, :block => block)
    end
    def she
      Tajriba.new(self)
    end
    def her
      Tajriba::ChainedTajribaWithGuessing.new(self)
    end
    def his
      Tajriba::ChainedTajribaWithoutGuessing.new(self)
    end
    
    def run
      tajribaat.each {|tajriba| pp tajriba.family.last; pp tajriba.block.call, ''}
    end
    
  end
  class Tajriba < ::ActiveSupport::BasicObject
    attr_accessor :description, :block
    def initialize(master, options = {})
      @description = options.delete(:description)
      @block = options.delete(:block)
      (@master = master).tajribaat << self
    end
    def method_missing(method, *arguments)
      p 'test'
      @description = "The object: #{method} #{arguments.map(&:inspect).join(' ')}"
      @block = Proc.new{self.object.send(method, *arguments)}
    end
    def object
      @master.object
    end
    def family; [@master]; end
    
    class ChainedTajriba
      attr_accessor :family, :method, :arguments
      def initialize(family, method = nil, *arguments)
        @family = family.to_a
        @family[1..-1].each {|member| member.family = family}
        @method, @arguments = method, arguments
        @family.first.tajribaat << self unless @family.size > 1
      end
      def method_missing(method, *arguments)
        p method
        ChainedTajriba.new(family+self.to_a, method, *arguments)
      end
      def members
        @family[1..-1]
      end
      def object
        succession = members.map{|m| p m; m.method}.join('.')
        succession = '.'+succession unless succession.empty?
        a = ("@family.first.object#{succession}")
        p a
        eval a
      end
    end
    class ChainedTajribaWithoutGuessing < ChainedTajriba
      def description
        @family.last.arguments.first
      end
      def block
        @family.last.arguments.last
      end
    end
    class ChainedTajribaWithGuessing < ChainedTajriba
      def description
        "The #{@family[0..-2].map(&:method).sort.reverse.join(' of the ')
        } of the object: #{@family.last.method
        }  #{@family.last.arguments.map(&:inspect).join(' ')}"
      end
      def block
        pp @family
        Proc.new {object.send(@family.last.method, *@family.last.arguments)}
      end
    end
  end
end


class Object
  # The default to_a will be obsolete 
  def to_a
    [self]
  end
end